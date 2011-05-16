-----------------------------------------------------------------------------
-- Entity:      alu extension
-- Author:      Johannes Kasberger
-- Description: Erweiterung für spear2 um Multiplikation in HW durchzuführen
-- Date:		15.04.2011
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.spear_pkg.all;

package pkg_aluext is

component ext_aluext
  port (
  	clk        : IN  std_logic;
    extsel     : in   std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type
  );
end component;
  
end pkg_aluext;
