library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

entity key_matrix is
  generic
  (
    CLK_FREQ           : integer range 1 to integer'high;
    SCAN_TIME_INTERVAL : time range 1 ms to 100 ms;
    DEBOUNCE_TIMEOUT   : time range 100 us to 1 ms;
    SYNC_STAGES        : integer range 2 to integer'high;
    COLUMN_COUNT       : integer range 1 to integer'high;
    ROW_COUNT          : integer range 1 to integer'high
  );
  port
  (
    sys_clk   : in  std_logic;
    sys_res_n : in  std_logic;
    columns   : out std_logic_vector(COLUMN_COUNT - 1 downto 0);
    rows      : in  std_logic_vector(ROW_COUNT - 1 downto 0);
    key       : out std_logic_vector(log2c(ROW_COUNT * COLUMN_COUNT) - 1 downto 0)
  );
end entity key_matrix;