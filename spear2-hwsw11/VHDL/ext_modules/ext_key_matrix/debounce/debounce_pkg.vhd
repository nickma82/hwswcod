library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

package debounce_pkg is
  component debounce_fsm is
    generic
    (
      CLK_FREQ    : integer;
      TIMEOUT     : time range 100 us to 100 ms := 1 ms;
      RESET_VALUE : std_logic
    );
    port
    (
      sys_clk : in std_logic;
      sys_res_n : in std_logic;
      i : in std_logic;
      o : out std_logic;
      reinit  : in std_logic;
      reinit_value  : in std_logic
    );
  end component debounce_fsm;

  component debounce is
    generic
    (
      CLK_FREQ    : integer;
      TIMEOUT     : time range 100 us to 100 ms := 1 ms;
      RESET_VALUE : std_logic := '0';
      SYNC_STAGES : integer range 2 to integer'high
    );
    port
    (
      sys_clk : in std_logic;
      sys_res_n : in std_logic;

      data_in : in std_logic;
      data_out : out std_logic;

      reinit  : in std_logic;
      reinit_value  : in std_logic
    );
  end component debounce;
end package debounce_pkg;