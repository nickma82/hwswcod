-------------------------------------------------------------------------------
-- Company:		  Institut für Technische Informatik - Abteilung ECS
-- Engineer:	  Martin Fletzer
-- Reused from: Josef Mosser, 0126655
--
-- Create Date:	 
-- Design Name:	 ext_sm_byteram
-- Module Name:	 8 bit dual ported memory - Behavioral
-- Project Name: AMBA4Spear
-- Target Devices:
-- Tool versions:
-- Description:	 definition of an 8 bit dual ported memory
--
-- Dependencies: used in ext_sm_dram
--
-- Revision:		 0.8 - ready for testing
-- Additional Comments:
--	todo: 
--
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity AMBA_sharedmem_byteram is
  generic (
    CONF : spear_conf_type);
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;

    wdata       : in  std_logic_vector(7 downto 0);
    waddr       : in  std_logic_vector((CONF.amba_shm_size - CONF.amba_word_size/16-1) downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector((CONF.amba_shm_size - CONF.amba_word_size/16-1) downto 0);

    rdata       : out std_logic_vector(7 downto 0));
end AMBA_sharedmem_byteram;

architecture behaviour of AMBA_sharedmem_byteram is

constant WORD_CNT : natural := 2**(CONF.amba_shm_size - CONF.amba_word_size/16);

subtype WORD is std_logic_vector(7 downto 0);
type ram_array is array (0 to WORD_CNT-1) of WORD;

signal ram : ram_array := (others => (others => '0'));

begin

  process(wclk)
  begin
    if rising_edge(wclk) then 
      if wen = '1' then
        ram(to_integer(unsigned(waddr))) <= wdata;
      end if;
    end if;
  end process;

  process(rclk)
  begin
    if rising_edge(rclk) then 
      rdata <= (others => '0');
      rdata <= ram(to_integer(unsigned(raddr)));
    end if;
  end process;

end behaviour;
