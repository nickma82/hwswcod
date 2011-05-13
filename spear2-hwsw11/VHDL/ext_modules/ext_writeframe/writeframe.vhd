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
	type register_set is array (0 to 7) of BYTE;

	type reg_type is record
  		ifacereg	: register_set;
  		getframe	: std_logic;
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0'))
	);
	
	signal rstint : std_ulogic;
  
begin
	ahb_master : ahbmst generic map (2, 0, VENDOR_WIR, WIR_WRITEFRAME, 0, 3, 1)
	port map (rstint, clk, dmai, dmao, ahbi, ahbo);
  
	-- Core Ext Interface
	comb : process(r, exti, extsel)
	variable v : reg_type;
	begin
    	v := r;
    	   	
    	--schreiben
    	if ((extsel = '1') and (exti.write_en = '1')) then
    		case exti.addr(4 downto 2) is
    			when "000" =>
    				if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
    					v.ifacereg(STATUSREG)(STA_INT) := '1';
    					v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
    				else
    					if ((exti.byte_en(2) = '1')) then
    						v.ifacereg(2) := exti.data(23 downto 16);
    					end if;
    					if ((exti.byte_en(3) = '1')) then
    						v.ifacereg(3) := exti.data(31 downto 24);
    					end if;
    				end if;
    			when "001" =>
    				if ((exti.byte_en(0) = '1')) then
    					v.ifacereg(4) := exti.data(7 downto 0);
    				end if;
    				if ((exti.byte_en(1) = '1')) then
    					v.ifacereg(5) := exti.data(15 downto 8);
    				end if;
    				if ((exti.byte_en(2) = '1')) then
    					v.ifacereg(6) := exti.data(23 downto 16);
    				end if;
    				if ((exti.byte_en(3) = '1')) then
    					v.ifacereg(7) := exti.data(31 downto 24);
    				end if;
    			when "010" =>
    				if ((exti.byte_en(0) = '1')) then
    					v.getframe := exti.data(0);
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
					if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
						exto.data <= MODULE_VER & MODULE_ID;
					else
						exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
					end if;
				when "010" =>
					if ((exti.byte_en(0) = '1')) then
    					exto.data(0) <= r.getframe;
    				end if;
				when others =>
					null;
			end case;
		end if;
    	
    	--berechnen der neuen status flags
		v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
		v.ifacereg(STATUSREG)(STA_FSS) := '0';
		v.ifacereg(STATUSREG)(STA_RESH) := '0';
		v.ifacereg(STATUSREG)(STA_RESL) := '0';
		v.ifacereg(STATUSREG)(STA_BUSY) := '0';
		v.ifacereg(STATUSREG)(STA_ERR) := '0';
		v.ifacereg(STATUSREG)(STA_RDY) := '1';
		
		-- Output soll Defaultmassig auf eingeschalten sie 
		v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
				
		--soft- und hard-reset vereinen
		rstint <= not RST_ACT;
		if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
		  rstint <= RST_ACT;
		end if;
			
		-- Interrupt
		if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
		  v.ifacereg(STATUSREG)(STA_INT) := '0';
		end if; 
		exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);
		
		
		r_next <= v;
    end process;
  
    
    reg : process(clk)
	begin
		if rising_edge(clk) then 
			if rstint = RST_ACT then
				r.ifacereg <= (others => (others => '0'));
			else
				r <= r_next;
			end if;
		end if;
	end process;

    -- Default Zuweisungen
	dmai.address <= "11100000000000000000000000000000";
	dmai.wdata  <= (others => '0');
    dmai.burst  <= '0';
    dmai.irq    <= '0';
    dmai.size   <= "10";                    
    dmai.write  <= '0';
    dmai.busy   <= '0';
    dmai.start    <= '0';
end ;

