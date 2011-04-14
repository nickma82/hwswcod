library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity spear_brom is
  generic (
    CONF : spear_conf_type);                
  port (
    clk   : in  std_ulogic;
    hold  : in  std_ulogic;
    addr  : in  std_logic_vector(CONF.word_size-1 downto 0);
    data  : out INSTR);
end spear_brom;

architecture behaviour of spear_brom is

signal enable : std_ulogic;
signal data_int  :  INSTR;

begin

  enable <= not hold;

--  xilinx_gen : if (CONF.tech = XILINX) generate
 --   instr_rom_inst: xilinx_instr_rom
 --     port map (
 --       clk     => clk,
 --       enable  => enable,
 --       addr    => addr(15 downto 0),
 --      data    => data_int
 --     );
 -- end generate;
    
  altera_gen : if (CONF.tech = ALTERA) generate
    boot_rom_inst: altera_boot_rom
      generic map (
        CONF => CONF)
      port map (
        address => addr(15 downto 0),
        clken   => enable,
        clock   => clk,
        q       => data_int
      );
  end generate;


  -- little-endianness used for storing instructions in memory
  -- => swap bytes
  data(15 downto 8) <= data_int(7 downto 0);
  data(7 downto 0) <= data_int(15 downto 8);
  
end behaviour;
