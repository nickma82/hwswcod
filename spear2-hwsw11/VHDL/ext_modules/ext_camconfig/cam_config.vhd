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
		clk     : in  	std_logic;
		extsel  : in  	std_ulogic;
		exti    : in  	module_in_type;
		exto    : out 	module_out_type;
		sclk	: out	std_logic;
		sdata	: inout	std_logic
    );
end ;

architecture rtl of ext_camconfig is
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	type state_type is (reset, idle, send_startbit, wait_until_low, pre_id, hold_id, pre_address, hold_address, pre_data, hold_data, done);
	
	type reg_type is record
  		ifacereg	: register_set;
		address		: std_logic_vector(7 downto 0);
		value		: std_logic_vector(15 downto 0);
		cmd			: std_logic_vector(7 downto 0);
		ready		: std_logic;
		state		: state_type;
		i			: integer range 0 to 15;
		clkgen		: integer range 0 to 125;
		sclk		: std_logic;
		sdata		: std_logic;
		ret_state	: state_type;
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		address => (others => '0'),
		value => (others => '0'),
		cmd => (others => '0'),
		ready => '0',
		state => reset,
		i => '0',
		clkgen => '0',
		sclk => '0',
		sdata => '0',
		ret_state => reset
	);
	
	signal i_next : integer range 0 to 15;
	signal rstint : std_ulogic;
begin
	
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, exti, extsel)
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
				-- address übernehmen => 0. byte; cmd => 1. byte;
    			when "001" =>
    				if ((exti.byte_en(0) = '1')) then
			    		v.address(7 downto 0) := exti.data(7 downto 0);
			    	end if;
			    	if ((exti.byte_en(1) = '1')) then
			    		v.cmd(7 downto 0) := exti.data(15 downto 8);
						v.ready := '0';
			    	end if;
				-- daten zu schreiben übernehmen
				when "010" =>
					if ((exti.byte_en(0) = '1')) then
			    		v.value(7 downto 0) := exti.data(7 downto 0);
			    	end if;
			    	if ((exti.byte_en(1) = '1')) then
			    		v.value(15 downto 8) := exti.data(15 downto 8);
			    	end if;
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
				-- ob fertig, cmd und address auslesen
				when "001" =>
					exto.data <= (16 => r.ready, 15 downto 8 => r.cmd, 7 downto 0 => r.address, others=>'0');
				-- gelesene/geschriebene daten auslesen
				when "010" =>
					exto.data <= (15 downto 0 => r.value, others=>'0');
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
		--- Statemachine um Übertragung zu starten und aktionen unabhängig vom sclk durchzuführen
		------------------
		case r.state is
			when reset =>
				v.addres := (others => '0');
				v.value := (others => '0');
				v.cmd := CMD_IDLE;
				v.state := idle;
				v.i := 0;
				v.clkgen := '0';
				v.sdata := '1';
				v.sclk := '1';		
			when idle =>
				-- sobald aktion ausgeführt werden soll Start Bit senden
				if r.cmd /= IDLE then
					v.state := start;
					v.ready := '0';
				end if;
			when send_start_bit =>
				-- start bit wird nur gesendet wenn sclock high ist
				if r.sclk = '1' then
					v.state := wait_until_low;
					v.ret_state := pre_id;
					v.sdata := '0';
				end if;
			when wait_until_low =>
				-- warten bis takt low wird
				if r.sclk = '0' then
					v.state := r.ret_state;
				end if;	
			when wait_low_ack =>
				if r.sclk = '0' then
					v.state := wait_ack;					
					v.sdata := 'Z';
				end if;
			when restore_read =>
				v.sdata := 'Z';
				v.state := read2;
			when done =>
				v.state := r.idle;
				v.ready := '1';
				v.sdata := '1';
			when 
				others => null;
		end case;
		
		------------------
		-- Takt für two wire generieren, nur wenn übertragung läuft sonst bus auf idle stellen
		------------------
		if r.cmd /= reset and r.cmd /= idle then
			if r.clkgen = CLK_COUNT then
				v.clkgen := 0;
				v.sclk := not r.sclk;
			else
				v.clkgen := r.clkgen + 1;
			end if;
		else
			v.sclk := '1';
			v.sdata := '1';
		end if;
		
		
		------------------
		-- Veränderungen immer zu halben taktflanken
		------------------
		if r.clkgen = CLK_HALF then
			
			-- bei low takt nächsten signale anlegen
			if r.sclk = '0' then			
				-- restlichen aktionen passieren getaktet mit langsamen takt immer zur hälfte der low phase
				case r.state is
					when pre_id =>
						v.state := send_id;
						v.sdata := id(r.i);
					when send_id =>
						-- 7 bit hinaus schicken
						if r.i <= 7 then
							v.state := pre_id;
						-- dann auf ack bit warten
						else
							v.state := wait_low_ack;
							v.ret_state := pre_address;
						end if;
					-- address bits der reihe nach hinaus schicken
					when pre_address =>
						v.state := hold_address;
						v.sdata := r.address(r.i);
					when hold_address =>
						if r.i <= 7 then
							v.state := pre_address;
						else
							v.state := wait_low_ack;
							-- write mode
							if r.id(7) = '0' then
								v.ret_state := pre_write1;
							else
								v.ret_state := read1;
							end if;
							
						end if;
					
					-- WRITE: daten nacheinander hinaus schicken, dazwischen ack bit abwarten			
					when pre_write1 =>
						v.state := hold_write1;
						v.sdata := r.data1(r.i);
					when pre_data2 =>
						v.state := hold_data2;
						v.sdata := r.data2(r.i);
					when hold_data1 =>
						if r.i <= 7 then
							v.state := pre_write1;
						else
							v.state := wait_low_ack;
							v.ret_state := pre_write2;
						end if;
					when hold_write2 =>
						if r.i <= 7 then
							v.state := pre_write2;
						else
							v.state := wait_low_ack;
							v.ret_state := done;
						end if;
					when send_ack =>
						v.sdata := '0';
						v.state := wait_until_high;
					when others => null;		
				end case;
			-- sampeln zur mitte des high takt
			else				
				case r.sate is
					when wait_ack =>
						-- weiter wenn das ack bit auf low gezogen wird
						if sdata = '0' then
							v.state := r.ret_state;
						end if;
					
					-- READ: daten nacheinander lesen, jedes byte bestätigen
					when read1 =>
						v.data1(r.i) := sdata;
						if r.i = 7 then
							v.state := send_ack;
						end if;
					when read2 =>
						v.data2(r.i) := sdata;
						if r.i = 7 then						
							--v.state := send_ack;
							--v.ret_state := done;
							v.state := done;
						end if;
					when wait_until_high =>
						v.state := wait_until_low;
						v.ret_state := restore_read;
					when others => null;
				end case;				
			end if;
		end if;	
		
		------------
		--- i index immer vor nächsten auslesen/schreiben modifizieren
		------------
		if r.clkgen = (CLK_HALF-1) and r.sclk = '1' then
			if r.i <= 8 then
				v.i := r.i + 1;
			else
				v.i := 0;
			end if;			
		end if;
		
		sclk <= r.sclk;
		sdata <= r.sdata;
		r_next <= v;
    end process;	

	------------------------
	---	Sync Daten übernehmen
	------------------------
    reg : process(clk,sclk)
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