library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity spear_regfram is
  generic (
    CONF : spear_conf_type); 
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;
    enable      : in  std_ulogic;
    
    wdata       : in  std_logic_vector(CONF.word_size-1 downto 0);
    waddr       : in  std_logic_vector(REGADDR_W-1 downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector(REGADDR_W-1 downto 0);
    rdata       : out std_logic_vector(CONF.word_size-1 downto 0)
    );
end spear_regfram;

architecture behaviour of spear_regfram is

constant WORD_W : natural := CONF.word_size;

subtype WORD is std_logic_vector(WORD_W-1 downto 0);
type ram_array is array (0 to 15) of WORD;

signal ram : ram_array := (others => (others => '0'));

begin

  process(wclk)
  begin
    if rising_edge(wclk) then 
      if enable = '1' then
        if wen = '1' then
          ram(to_integer(unsigned(waddr))) <= wdata(WORD_W-1 downto 0);
        end if;
      end if;
    end if;
  end process;

  process(rclk)
  begin
    if rising_edge(rclk) then 
      if enable = '1' then
        rdata <= (others => '0');
        rdata(WORD_W-1 downto 0) <= ram(to_integer(unsigned(raddr)));
      end if;
    end if;
  end process;

end behaviour;
