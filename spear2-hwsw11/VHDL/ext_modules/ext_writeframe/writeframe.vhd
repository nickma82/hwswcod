------------------------------------------------------------------------------
--  
-----------------------------------------------------------------------------
-- Entity:      write frame buffer
-- File:        frame_controller.vhd
-- Author:      Hans Soderlund
-- Description: Vga Controller main file
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;

USE work.spear_pkg.all;
use work.pkg_writeframe.all;

entity ext_writeframe is
	port (
		clk       : in  std_logic;
		extsel    : in  std_ulogic;
		exti      : in  module_in_type;
		exto      : out module_out_type;
		ahbi      : in  ahb_mst_in_type;
		ahbo      : out ahb_mst_out_type
    );
end ;

architecture rtl of ext_writeframe is
	-- AMBA Signale 
	signal dmai               : ahb_dma_in_type;
	signal dmao               : ahb_dma_out_type;
  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	type reg_type is record
  		ifacereg	: register_set;
		getframe	: std_logic;
  	end record;

	type amba_reg_type is record
		adress		: std_logic_vector(31 downto 0);
		wdata		: std_logic_vector(31 downto 0);
		start		: std_logic;
		done		: std_logic;
		running		: std_logic;
	end record;
	
	--type state_type is (running, not_running, reset);

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		getframe => '0'
	);
	
	signal amba_r_next : amba_reg_type;
	signal amba_r : amba_reg_type := 
	(
		adress 	=> (others => '0'),
		wdata  	=> (others => '0'),
		start  	=> '0',
		done 	=> '0',
		running => '0'
	);
	
	signal rstint : std_ulogic;
  
begin
	ahb_master : ahbmst generic map (2, 0, VENDOR_WIR, WIR_WRITEFRAME, 0, 3, 1)
	port map (rstint, clk, dmai, dmao, ahbi, ahbo);
  
	------------------------
	---	ASync Über Ambabus Daten 
	------------------------
	amba_logic : process(r,dmao,rstint)
	variable v : amba_reg_type;
	begin
		v := amba_r;
		v.start := '0';
		
		if rstint = '1' then
			v.running := '0';
			v.start := '0';
			v.done := '0';
		else
			-- übertragung eines bildes starten
			if (r.getframe and amba_r.running) = '0' then
				v.running := '1';
				v.adress := FRAMEBUFFER_BASE_ADR;
				v.start := '1';
				v.done := '0';
			end if;

			-- ein pixel übertragen
			if (amba_r.running and dmao.ready) = '1' then
				-- ein bild übertragen => aufhören
				if amba_r.adress = FRAMEBUFFER_END_ADR then
					v.done := 1;
					v.running := 0;
				-- sonst nächsten pixel senden
				else
					v.adress := amba_r.adress + 1;
					v.start := 1;
				end if;
			end if;
			
			-- wenn getframe nicht mehr high und done noch gesetzt zurück setzen
			if  (not r.getframe and amba_r.done) = '1' then
				v.done := '0';
			end if;
		end if;
		 
		amba_r_next <= v;
		
		-- Werte auf Interface zu Bus legen
		dmai.wdata  <= (24 downto 16 => '1', others=>'0'); --amba_r.wdata;
	    dmai.burst  <= '0';
	    dmai.irq    <= '0';
	    dmai.size   <= "10";
	    dmai.write  <= '1';
	    dmai.busy   <= '0';
	    dmai.start    <= amba_r.start;
	    dmai.address  <= amba_r.adress;
	end process;

	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, exti, extsel,amba_r)
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
				-- commando word => bit 0 übernehmen
    			when "001" =>
    				if ((exti.byte_en(0) = '1') and (exti.data(0) = '1')) then
    					v.getframe := '1';
    				end if;
   				when others =>
					null;
			end case;
		end if;

		--auslesen
		exto.data <= (others => '0');
		if ((extsel = '1') and (exti.write_en = '0')) then
			case exti.addr(4 downto 2) is
				when "000" =>
					exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
				when "001" =>
					if ((exti.byte_en(0) = '1')) then
    					exto.data(0) <= r.getframe;
    				end if;
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
		
		-- wenn ein bild übertragen getframe wieder auf 0 setzen um programm weiter arbeiten zu lassen
		if (amba_r.done and amba_r.running and r.getframe) = '1' then
			v.getframe := '0';
		end if;
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
			else
				r <= r_next;
				amba_r <= amba_r_next;
			end if;
		end if;
	end process;

    -- Default Zuweisungen
	--dmai.address <= "11100000000000000000000000000000";
	--dmai.wdata  <= (others => '0');
    --dmai.burst  <= '0';
    --dmai.irq    <= '0';
    --dmai.size   <= "10";                    
    --dmai.write  <= '0';
    --dmai.busy   <= '0';
    --dmai.start    <= '0';
end ;

