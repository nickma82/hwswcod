library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;


entity spear_byteram is
  generic (
    CONF : spear_conf_type);
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;
    enable      : in  std_ulogic;

    wdata       : in  std_logic_vector(7 downto 0);
    waddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
    rdata       : out std_logic_vector(7 downto 0)
    );
end spear_byteram;

architecture behaviour of spear_byteram is

-- FIXME (jl): is this correct?
constant WORD_CNT : natural := 2**(CONF.data_ram_size - CONF.word_size/16);

subtype WORD is std_logic_vector(7 downto 0);
type ram_array is array (0 to WORD_CNT-1) of WORD;

signal ram : ram_array := (others => (others => '0'));

begin

  process(wclk)
  begin
    if rising_edge(wclk) then 
      if (enable = '1') then
        if wen = '1' then
          ram(to_integer(unsigned(waddr))) <= wdata;
        end if;
      end if;
    end if;
  end process;

  process(rclk)
  begin
    if rising_edge(rclk) then 
      if (enable = '1') then
        rdata <= (others => '0');
        rdata <= ram(to_integer(unsigned(raddr)));
      end if;
    end if;
  end process;

end behaviour;
