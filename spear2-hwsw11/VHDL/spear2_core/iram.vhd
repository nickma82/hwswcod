library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity spear_iram is
  generic (
    CONF : spear_conf_type);    
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;
    hold        : in  std_ulogic;

    wdata       : in  INSTR;
    waddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
    rdata       : out INSTR);
end spear_iram;

architecture behaviour of spear_iram is

  constant NWORDS : integer  := 2**CONF.instr_ram_size;
  type ram_array is array (0 to NWORDS-1) of INSTR;

  signal ram : ram_array := (others => NOP);
  signal enable    : std_ulogic;
  signal data_int       : INSTR;

begin

  enable <= not hold;

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
        data_int <= (others => '0');
        data_int <= ram(to_integer(unsigned(raddr)));
      end if;
    end if;
  end process;

  -- little-endianness used for storing instructions in memory
  -- => swap bytes
  rdata(15 downto 8) <= data_int(7 downto 0);
  rdata(7 downto 0) <= data_int(15 downto 8);
  
end behaviour;
