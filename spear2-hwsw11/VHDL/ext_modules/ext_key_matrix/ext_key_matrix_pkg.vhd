

LIBRARY IEEE;
use IEEE.std_logic_1164.all;

use work.spear_pkg.all;


package ext_key_matrix_pkg is


  
  component ext_key_matrix
    generic
    (
      CLK_FREQ  : integer range 1 to integer'high;
      COLUMN_COUNT       : integer range 1 to integer'high;
      ROW_COUNT          : integer range 1 to integer'high
    );  
    port
    (
      clk       : in std_logic;
      extsel    : in std_ulogic;
      exti      : in  module_in_type;
      exto      : out module_out_type;
      columns   : out std_logic_vector(COLUMN_COUNT - 1 downto 0);
      rows      : in  std_logic_vector(ROW_COUNT - 1 downto 0)
    );
  end component ext_key_matrix;


end ext_key_matrix_pkg;

