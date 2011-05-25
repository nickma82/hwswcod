-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger
-- Description: Ein Bild in Framebuffer übertragen
-- Date:		15.05.2011
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
		ahbo      : out ahb_mst_out_type;
		
		cm_d		: in std_logic_vector(11 downto 0); --pixel data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		--cm_xclkin	: out std_logic;
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic 	--Snapshot strobe
    );
end ;

architecture rtl of ext_writeframe is
	-- AMBA Signale 
	signal dmai               : ahb_dma_in_type;
	signal dmao               : ahb_dma_out_type;
  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;
	type state_type is (idle, adr, data, done, reset);
	
	type reg_type is record
  		ifacereg	: register_set;
		getframe	: std_logic;
		address		: std_logic_vector(31 downto 0);
		wdata		: std_logic_vector(31 downto 0);
		state		: state_type;
		start		: std_logic;
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		getframe => '0',
		address 	=> (others => '0'),
		wdata  	=> (others => '0'),
		state	=> reset,
		start	=> '0'
	);
	
	signal rstint : std_ulogic;
  
	--ccd Handle Signals
	type state_ccd_type is (idle, lineread, linenext, finisher, reset);
	--type state_ccd is record
		
	--end record;
	
begin
	ahb_master : ahbmst generic map (2, 0, VENDOR_WIR, WIR_WRITEFRAME, 0, 3, 1)
	port map (rstint, clk, dmai, dmao, ahbi, ahbo);
	
	------------------------
	---	CCD Handler
	------------------------
    reg : process(cm_lval, cm_fval)
	begin
		if ((cm_lval = '1') and (cm_fval = '1')) then 
			--if rstint = RST_ACT then
			--	r.ifacereg <= (others => (others => '0'));
			--	r.state <= reset;
			--else
			--	r <= r_next;
			--end if;
		end if;
	end process;
	
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
    					exto.data(7 downto 0) <= (0 => r.getframe, others=>'0');
    				end if;
				when others =>
					null;
			end case;
		end if;
    	
    	--berechnen der neuen status flags
		v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
		v.ifacereg(STATUSREG)(STA_FSS)	:= '0';		-- failsafe
		v.ifacereg(STATUSREG)(STA_RESH) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_RESL) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_BUSY) := '0';		-- busy
		v.ifacereg(STATUSREG)(STA_ERR)	:= '0';		-- fehler
		v.ifacereg(STATUSREG)(STA_RDY)	:= '1';		-- immer bereit
		
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
		--- Statemachine
		------------------
		case r.state is
			when reset =>
				v.start := '0';
				v.state := idle;
			when idle =>
				if r.getframe = '1' then
					v.state := adr;
					v.start := '1';
				else
					v.address := FRAMEBUFFER_BASE_ADR;
				end if;
			when adr =>
				if dmao.ready = '1' then
					v.state := data;
				end if;
				v.wdata := "00000000111111110000000000000000";
			when data =>
				if r.address = FRAMEBUFFER_END_ADR then
					v.state := done;
					v.start := '0';
				else					
					v.address := r.address + 4;
					v.state := adr;
				end if;
			when done =>
				v.state := idle;
				v.getframe := '0';
		end case;
		
		-- Werte auf Interface zu Bus legen
		dmai.wdata  <=  r.wdata;
	    dmai.burst  <= '0';
	    dmai.irq    <= '0';
	    dmai.size   <= "10";
	    dmai.write  <= '1';
	    dmai.busy   <= '0';
	    dmai.start    <= r.start;
	    dmai.address  <= r.address;
		
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
			else
				r <= r_next;
			end if;
		end if;
	end process;
	
	
end ;

