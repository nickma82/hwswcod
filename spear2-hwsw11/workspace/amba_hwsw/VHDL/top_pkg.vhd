library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;

package top_pkg is

  constant CLK_FREQ : integer range 1 to integer'high := 50000000;

  constant AHB_SLAVE_COUNT : natural := 2;
  constant APB_SLAVE_COUNT : natural := 1;

  constant VENDOR_TEST     : amba_vendor_type := 16#FF#;
  constant TEST_SPEAR2     : amba_device_type := 16#000#;
  constant SPEAR2_VERSION  : amba_version_type := 16#00#;
  constant AMBA_MASTER_CONFIG : ahb_config_type := (
    0 => ahb_device_reg(VENDOR_TEST, TEST_SPEAR2, 0, SPEAR2_VERSION, 0),
    others => (others => '0'));
  
end top_pkg;
