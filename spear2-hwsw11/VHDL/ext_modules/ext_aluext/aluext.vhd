-----------------------------------------------------------------------------
-- Entity:      alu extension
-- Author:      Johannes Kasberger
-- Description: Erweiterung für spear2 um Multiplikation in HW durchzuführen
-- Date:		15.04.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;
use work.spear_pkg.all;
use work.pkg_aluext.all;

entity ext_aluext is
	port (
		clk       : in  std_logic;
		extsel    : in  std_ulogic;
		exti      : in  module_in_type;
		exto      : out module_out_type
    );
end ;

architecture rtl of ext_aluext is
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	type reg_type is record
  		ifacereg	: register_set;
		op_a		: signed(31 downto 0);
		op_b		: signed(31 downto 0);
		result		: signed(31 downto 0);
		cmd			: std_logic_vector(1 downto 0);
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		op_a => (others => '0'),
		op_b => (others => '0'),
		result => (others => '0'),
		cmd => (others => '0')
	);
	
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
				-- op_a übernehmen
    			when "001" =>
    				if ((exti.byte_en(0) = '1')) then
			    		v.op_a(7 downto 0) := signed(exti.data(7 downto 0));
			    	end if;
			    	if ((exti.byte_en(1) = '1')) then
			    		v.op_a(15 downto 8) := exti.data(15 downto 8);
			    	end if;
			    	if ((exti.byte_en(2) = '1')) then
			    		v.op_a(23 downto 16) := exti.data(23 downto 16);
			    	end if;
			    	if ((exti.byte_en(3) = '1')) then
			    		v.op_a(31 downto 24) := exti.data(31 downto 24);
			    	end if;
				when "010" =>
	    			if ((exti.byte_en(0) = '1')) then
		    			v.op_b(7 downto 0) := exti.data(7 downto 0);
		    		end if;
		    		if ((exti.byte_en(1) = '1')) then
		    			v.op_b(15 downto 8) := exti.data(15 downto 8);
		    		end if;
		    		if ((exti.byte_en(2) = '1')) then
		    			v.op_b(23 downto 16) := exti.data(23 downto 16);
		    		end if;
		    		if ((exti.byte_en(3) = '1')) then
		    			v.op_b(31 downto 24) := exti.data(31 downto 24);
		    		end if;
				when "100" =>
					if ((exti.byte_en(0) = '1')) then
						v.cmd(1 downto 0) := exti.data(1 downto 0);
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
				-- ergebnis auslesen
				when "011" =>
					exto.data(31 downto 0) <= std_logic_vector(r.result(31 downto 0));
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

		-- unabhängig vom commando multiplizieren
		v.result = r.op_a * r.op_b;
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
				r.op_a = (others => '0');
				r.op_b = (others => '0');
				r.result = (others => '0');
				r.cmd = (others =>'0');
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;