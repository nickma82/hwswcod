-----------------------------------------------------------------------------
-- Entity:      cam_config
-- Author:      Johannes Kasberger
-- Description: Kamera Parameter über two-wire-bus schicken
-- Date:		24.05.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all ;
use work.spear_pkg.all;
use work.pkg_camconfig.all;

entity ext_camconfig is
	port (
		clk     		: in  	std_logic;
		extsel  		: in  	std_ulogic;
		exti    		: in  	module_in_type;
		exto    		: out 	module_out_type;
		sclk			: out	std_logic;
		sdata_in		: in	std_logic;
		sdata_out		: out	std_logic;
		sdata_out_en 	: out 	std_logic;
		led_red			: out 	std_logic_vector(17 downto 0)
    );
end ;

architecture rtl of ext_camconfig is
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	
	type reg_type is record
  		ifacereg	: register_set;
		w_id		: BYTE;
		r_id		: BYTE;
		address		: BYTE;
		data1		: BYTE;
		data2		: BYTE;
		
		ready		: std_logic;
		r_en		: std_logic;
		w_sent		: std_logic;
		state		: cam_state_type;
		ret_state	: cam_state_type;
		
		i			: integer range -1 to 7;
		clkgen		: integer range 0 to CLK_COUNT;
		
		sclk		: std_logic;
		sdata_out	: std_logic;
		leds		: std_logic_vector(17 downto 0);
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		w_id => (others => '0'),
		r_id => (others=>'0'),
		address => (others => '0'),
		data1 => (others => '0'),
		data2 => (others => '0'),
		ready => '0',
		r_en => '0',
		w_sent => '0',
		state => reset,
		ret_state => reset,
		i => 0,
		clkgen => 0,
		sclk => '1',
		sdata_out => '1',
		leds => (others=>'1')
	);
	
	signal rstint : std_ulogic;
begin
	
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, exti, extsel,sdata_in,rstint)
	variable v : reg_type;
	begin
    	v := r;
    	   	
    	--schreiben
    	if ((extsel = '1') and (exti.write_en = '1')) then
    		case exti.addr(4 downto 2) is
				-- byte 0 => status&config word
    			when "000" =>
					-- wenn byte 0 oder 1 dann interrupt anfordern? und int_ack zurück setzten
    				if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
    					v.ifacereg(STATUSREG)(STA_INT) := '1';
    					v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
    				else
						-- config byte schreiben
    					if ((exti.byte_en(2) = '1')) then
    						v.ifacereg(2) := exti.data(23 downto 16);
    					end if;
						-- ?
    					if ((exti.byte_en(3) = '1')) then
    						v.ifacereg(3) := exti.data(31 downto 24);
    					end if;
    				end if;
				-- id => byte 0 (letztes bit bestimmt read oder write); address => 1 byte; daten 1 und 2 bytes 2 und 3;
				
    			when "001" =>
					-- write wird hier gestartet
    				if ((exti.byte_en(0) = '1')) then
			    		v.data2(7 downto 0) := exti.data(7 downto 0);
			    	end if;
			    	if ((exti.byte_en(1) = '1')) then
			    		v.data1(7 downto 0) := exti.data(15 downto 8);
			    	end if;
					if ((exti.byte_en(2) = '1')) then
			    		v.address(7 downto 0) := exti.data(23 downto 16);
			    	end if;
					if ((exti.byte_en(3) = '1')) then
			    		v.w_id(7 downto 0) := exti.data(31 downto 24);
			    	end if;
					-- wenn geschrieben wird übertragung starten
					v.ready := '0';
					v.r_en  := '0';
					v.w_sent := '0';
					
				when "010" =>
					-- read wird hier gestartet
    				
			    	v.data1(7 downto 0) := (others=>'0');
			    	v.data2(7 downto 0) := (others=>'0');
			
			    	if ((exti.byte_en(1) = '1')) then
						v.address(7 downto 0) := exti.data(15 downto 8);
			    	end if;
					if ((exti.byte_en(2) = '1')) then
			    		v.r_id(7 downto 0) := exti.data(23 downto 16);
			    	end if;
					if ((exti.byte_en(3) = '1')) then
			    		v.w_id(7 downto 0) := exti.data(31 downto 24);
			    	end if;
					-- wenn geschrieben wird übertragung starten
					v.ready := '0';
					v.r_en  := '1';
					v.w_sent := '0';
   				when others =>
					null;
			end case;
		end if;

		--auslesen
		exto.data <= (others => '0');
		if ((extsel = '1') and (exti.write_en = '0')) then
			case exti.addr(4 downto 2) is
				-- status byte auslesen
				when "000" =>
					exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
				-- ids und addressen daten auslesen
				when "001" =>
					exto.data <= r.w_id & r.r_id & r.address & "00000000";
				-- empfangene/gesendete daten auslesen
				when "011" => 
					--exto.data <= (15 downto 8 => r.data1, 7 downto 0 => r.data2, others => '0');
					exto.data <= (others => '0');
					exto.data(15 downto 8) <= r.data1;
					exto.data(7 downto 0) <= r.data2;
				-- ob fertig auslesen
				when "100" =>
					exto.data <= (0 => r.ready, others=>'0');
				when others =>
					null;
			end case;
		end if;
    	
    	--berechnen der neuen status flags
		v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
		v.ifacereg(STATUSREG)(STA_FSS) := '0';		-- failsafe
		v.ifacereg(STATUSREG)(STA_RESH) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_RESL) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_BUSY) := '0';		-- busy
		v.ifacereg(STATUSREG)(STA_ERR) := '0';		-- fehler
		v.ifacereg(STATUSREG)(STA_RDY) := '1';		-- immer bereit
		
		-- Output soll Defaultmassig auf eingeschalten sein
		v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
				
		--soft- und hard-reset vereinen
		rstint <= not RST_ACT;
		if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
		  rstint <= RST_ACT;
		end if;
			
		-- Interrupt
		-- wenn interrupt von modul verlangt und noch nicht bestätigt
		if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
		  v.ifacereg(STATUSREG)(STA_INT) := '0';
		end if; 
		exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);
		
		
		------------------
		-- Takt für two wire generieren, nur wenn übertragung läuft sonst bus auf idle stellen
		------------------
		if r.state /= reset then --and r.state /= idle
			if r.clkgen = CLK_COUNT then
				v.clkgen := 0;
				v.sclk := not r.sclk;
			else
				v.clkgen := r.clkgen + 1;
			end if;		
		end if;
				
		------------------
		--- Statemachine um Übertragung zu starten und aktionen unabhängig vom sclk durchzuführen
		------------------
		case r.state is
			when reset =>
				v.w_id := (others => '0');
				v.r_id := (others => '0');
				v.address := (others => '0');
				v.data1 := (others => '0');
				v.data2 := (others => '0');
				v.state := idle;
				v.i := 0;
				v.clkgen := 0;				
				v.ready := '1';
				v.leds := (others => '1');
				v.sclk := '1';
				v.sdata_out := '1';
				v.clkgen := 0;
			when idle =>
				v.sdata_out := '1';
				-- sobald aktion ausgeführt wird => start bit senden
				if r.ready = '0' then
					v.state := send_start_bit;
				end if;
				v.leds(3) := '0';
			when send_start_bit =>
				-- start bit wird nur gesendet wenn sclock high ist
				if (r.sclk = '1' and r.clkgen < 20) then
					v.state := wait_until_low;
					v.sdata_out := '0';
					-- wenn write id noch nicht gesendet das tun
					if r.w_sent = '0' then
						v.ret_state := send_w_id;
					-- wenn noch einmal hier => lesemodus id schicken
					else
						v.ret_state := send_r_id;
					end if;
					v.leds(4) := '0';
				end if;
			when send_stop_bit =>
				if r.sclk = '1' then
					v.sdata_out := '1';
					v.state := wait_until_low;
					v.ret_state := send_start_bit;
				end if;
			when wait_until_low =>
				-- warten bis takt low wird hängt hier
				if r.sclk = '0' then
					v.state := r.ret_state;
				end if;
				
			when restore_read =>
				v.state := read2;
				v.leds(6) := '0';
			when done =>
				v.state := idle;
				v.ready := '1';
				v.leds(7) := '0';
			when error_state =>
				v.state := idle;
				v.ready := '1';
				v.leds(17) := '0';
			when 
				others => null;
		end case;		
		
		------------------
		-- Veränderungen immer zu halben taktflanken
		------------------
		if r.clkgen = CLK_HALF then
			
			-- bei low takt nächsten signale anlegen
			if r.sclk = '0' then			
				-- restlichen aktionen passieren getaktet mit langsamen takt immer zur hälfte der low phase
				case r.state is
					when send_w_id =>	
						-- 8 bit hinaus schicken
						if r.i >= 0 then
							v.sdata_out := r.w_id(r.i);
						else
							-- nach 8. bit auf ack bit warten
							v.state := wait_ack;
							v.ret_state := send_address;
							v.w_sent := '1';
						end if;
						v.leds(8) := '0';
						
					when send_r_id =>
						-- 8 bit hinaus schicken
						if r.i >= 0 then
							v.sdata_out := r.r_id(r.i);
						else
							-- nach 8. bit auf ack bit warten
							v.state := wait_ack;
							v.ret_state := read1;
						end if;
						v.leds(5) := '0';
					-- address bits der reihe nach hinaus schicken
					when send_address =>
						-- 8 bit hinaus schicken
						if r.i >= 0 then
							v.sdata_out := r.address(r.i);
						else
							v.state := wait_ack;
							-- write mode
							if r.r_en = '0' then
								v.ret_state := write1;
							else
								v.ret_state := send_stop_bit;
							end if;
						end if;
						v.leds(9) := '0';
					-- WRITE: daten nacheinander hinaus schicken, dazwischen ack bit abwarten			
					when write1 =>	
						sdata_out_en <= '1';
						if r.i >= 0 then
							v.sdata_out := r.data1(r.i);
						else
							v.state := wait_ack;
							v.ret_state := write2;
						end if;	
						v.leds(10) := '0';
					when write2 =>
						sdata_out_en <= '1';
						if r.i >= 0 then
							v.sdata_out := r.data2(r.i);
						else
							v.state := wait_ack;
							v.ret_state := done;
						end if;
						v.leds(11) := '0';
					-- ack bit anlegen
					when send_ack =>
						v.sdata_out := '0';
						v.state := wait_until_high;
						v.leds(12) := '0';
					when others => null;		
				end case;
			else
				-- sampeln zur mitte des high takt
				case r.state is
					when wait_ack =>
						-- weiter wenn das ack bit auf low gezogen wird
						if sdata_in = '0' then
							v.state := wait_until_low;
						else
							v.state := error_state;
							--v.state := wait_until_low;
						end if;
						v.leds(13) := '0';
					-- READ: daten nacheinander lesen, jedes byte bestätigen
					when read1 =>
						if r.i >= 0 then
							v.data1(r.i) := sdata_in;
						end if;
						if r.i = 0 then
							v.state := send_ack;
						end if;
						v.leds(14) := '0';
					when read2 =>
						if r.i >= 0 then
							v.data2(r.i) := sdata_in;
						end if;
						if r.i = 0 then
							v.state := done;
						end if;
						v.leds(15) := '0';
					when wait_until_high =>
						v.state := wait_until_low;
						v.ret_state := restore_read;
						v.leds(16) := '0';
					when others => null;
				end case;				
			end if;
		end if;	
		
		------------
		--- i index immer nach auslesen/schreiben modifizieren aber nur wenn in states in denen daten gelesen/geschrieben werden
		------------
		if r.clkgen = (CLK_HALF+1) and r.sclk = '1' then
			if r.i >= 0  and (r.state = send_w_id or r.state = send_r_id or r.state = send_address or r.state = read1 or r.state = read2 or r.state = write1 or r.state = write2 ) then
				v.i := r.i - 1;
			else
				v.i := 7;
			end if;
		end if;
		
		sclk <= r.sclk;
		sdata_out <= r.sdata_out;

		if r.state = reset or r.state = wait_ack or r.state = read1 or r.state = read2  or r.state = restore_read then
			sdata_out_en <= '0';
		else
			sdata_out_en <= '1';
		end if;
		
		led_red(0) <= r.sclk;
		led_red(1) <= r.sdata_out;
		led_red(2) <= rstint;
		led_red(17 downto 3) <= r.leds(17 downto 3);
		r_next <= v;
    end process;	

	------------------------
	---	Sync Daten übernehmen
	------------------------
    reg : process(clk)
	begin
		if rising_edge(clk) then 
			if rstint = RST_ACT then
				r.ifacereg <= (others => (others => '0'));
				r.state <= reset;
				r.clkgen <= 0;
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;