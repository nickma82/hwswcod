library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity debounce_fsm is
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
end entity debounce_fsm;
