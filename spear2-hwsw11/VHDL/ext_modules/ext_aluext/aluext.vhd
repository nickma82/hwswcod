-----------------------------------------------------------------------------
-- Entity:      alu extension
-- Author:      Johannes Kasberger
-- Description: Erweiterung für spear2 um Multiplikation in HW durchzuführen
-- Date:		15.04.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
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
		r		: std_logic_vector(8 downto 0);
		g		: std_logic_vector(8 downto 0);
		b		: std_logic_vector(8 downto 0);
		rf		: signed(31 downto 0);
		gf		: signed(31 downto 0);
		bf 		: signed(31 downto 0);
		--op_a	: unsigned(31 downto 0);
		--op_b	: unsigned(31 downto 0);
		--mult	: unsigned(31 downto 0);
		--div		: unsigned(31 downto 0);
  	end record;

	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		r => (others => '0'),
		g => (others => '0'),
		b => (others => '0'),
		rf => (others => '0'),
		gf => (others => '0'),
		bf => (others => '0')
		--op_a => (others => '0'),
		--op_b => (others => '0'),
		--mult => (others => '0'),
		--div => (others => '0')
	);
	
	signal rstint : std_ulogic;
	signal result,result_next : std_logic;
begin
	
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, exti, extsel,result)
	variable v : reg_type;
	variable tmp_rf,tmp_gf,tmp_bf : signed(31 downto 0);
	
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
    				if ((exti.byte_en(2) = '1')) then
			    		v.r(8 downto 0) := "0" & exti.data(23 downto 16);
			    	end if;
			    	if ((exti.byte_en(1) = '1')) then
			    		v.g(8 downto 0) := "0" & exti.data(15 downto 8);
			    	end if;
			    	if ((exti.byte_en(0) = '1')) then
			    		v.b(8 downto 0) := "0" & exti.data(7 downto 0);
			    	end if;
			    --when "011" =>
			    --	v.op_a(31 downto 0) := UNSIGNED(exti.data(31 downto 0));
			    --when "100" =>
			    --	v.op_b(31 downto 0) := UNSIGNED(exti.data(31 downto 0));
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
				when "010" =>
					exto.data(0) <= result;
				--when "101" =>
				--	exto.data(31 downto 0) <= STD_LOGIC_VECTOR(r.mult);
				--when "111" =>
				--	exto.data(31 downto 0) <= STD_LOGIC_VECTOR(r.div);
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
		
		--v.mult := RESIZE(r.op_a * r.op_b,32);
		--v.div  := RESIZE(r.op_a / r.op_b,32);
		
		tmp_rf := RESIZE(signed(r.r)*to_signed(1000,16),32);
		tmp_gf := RESIZE(signed(r.g)*to_signed(1000,16),32);
		tmp_bf := RESIZE(signed(r.b)*to_signed(1000,16),32);
		
		v.rf := SHIFT_RIGHT(tmp_rf,8);
		v.gf := SHIFT_RIGHT(tmp_gf,8);
		v.bf := SHIFT_RIGHT(tmp_bf,8);
				
		r_next <= v;
    end process;	

    
    color : process(r)
    variable tmp_y,tmp_cb,tmp_cr : signed(63 downto 0);
    
    begin
    			
		tmp_y :=  to_signed(299000,32)  * r.rf + to_signed(587000,32) * r.gf + to_signed(114000,32) * r.bf;
		tmp_cb := to_signed(500000,32)  * r.bf - to_signed(168736,32) * r.rf - to_signed(331264,32) * r.gf;
		tmp_cr := to_signed(500000,32)  * r.rf - to_signed(418688,32) * r.gf - to_signed(81312,32)  * r.bf;
		
		if tmp_y >= Y_LOW and tmp_y <= Y_HIGH and 
			tmp_cb >= CB_LOW and tmp_cb <= CB_HIGH and 
			tmp_cr >= CR_LOW and tmp_cr <= CR_HIGH then
			result_next <= '1';
		else
			result_next <= '0';
		end if;
    end process;
	
    ------------------------
	---	Sync Daten übernehmen
	------------------------
    reg : process(clk)
	begin
		if rising_edge(clk) then 
			if rstint = RST_ACT then
				r.ifacereg <= (others => (others => '0'));
				result <= '0';
			else
				r <= r_next;
				result <= result_next;
			end if;
		end if;
	end process;
end;