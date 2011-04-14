library ieee;
use ieee.std_logic_1164.all;
use work.sync_pkg.all;
use work.debounce_pkg.all;
use work.math_pkg.all;

architecture struct of debounce is
  signal data_sync : std_logic;
begin
  sync_inst : sync
    generic map
    (
      SYNC_STAGES => SYNC_STAGES,
      RESET_VALUE => RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      data_in => data_in,
      data_out => data_sync
    );

  fsm_inst : debounce_fsm
    generic map
    (
      CLK_FREQ => CLK_FREQ,
      TIMEOUT => TIMEOUT,
      RESET_VALUE => RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      i => data_sync,
      o => data_out,
      reinit => reinit,
      reinit_value => reinit_value
    );
end architecture struct;
