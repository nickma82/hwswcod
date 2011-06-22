-----------------------------------------------------------------------------
-- Entity:      alu extension
-- Author:      Johannes Kasberger
-- Description: Erweiterung für spear2 um Skinfilter in HW durchzuführen
-- Date:		15.04.2011
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;
use work.spear_pkg.all;

package pkg_aluext is

constant Y_LOW   : signed(63 downto 0) := to_signed( 100000000,64);
constant CB_LOW  : signed(63 downto 0) := to_signed(-150000000,64);
constant CR_LOW  : signed(63 downto 0) := to_signed(  50000000,64);

constant Y_HIGH  : signed(63 downto 0) := to_signed(1000000000,64);
constant CB_HIGH : signed(63 downto 0) := to_signed(  50000000,64);
constant CR_HIGH : signed(63 downto 0) := to_signed( 200000000,64);

component ext_aluext
  port (
  	clk        : IN  std_logic;
    extsel     : in   std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type
  );
end component;
  
end pkg_aluext;
