library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity spear_vectab is
  generic (
    CONF : spear_conf_type);
  port (
    clk         : in  std_ulogic;
    hold        : in  std_ulogic;
    
    data_in     : in  std_logic_vector(CONF.word_size-1 downto 0);
    interruptnr : in  std_logic_vector(EXCADDR_W-2 downto 0);
    trapnr      : in  std_logic_vector(EXCADDR_W-1 downto 0);
    wrvecnr     : in  std_logic_vector(EXCADDR_W-1 downto 0);
    intcmd      : in  std_ulogic;
    wrvecen     : in  std_ulogic;

    data_out    : out std_logic_vector(CONF.word_size-1 downto 0));
end spear_vectab;

architecture behaviour of spear_vectab is

subtype WORD is std_logic_vector(CONF.word_size-1 downto 0);
type ram_array is array (0 to EXCVECTAB_S-1) of WORD;

signal ram : ram_array := (others => (others => '0'));                           

signal raddr : std_logic_vector(EXCADDR_W-1 downto 0);

signal enable : std_ulogic;

begin


  comb : process(intcmd, interruptnr, trapnr)
  begin
    
    raddr <= (others => '0');
    if intcmd = EXC_ACT then
      raddr(EXCADDR_W-2 downto 0) <= interruptnr;
      raddr(EXCADDR_W-1) <= '1';
    else
      raddr <= trapnr;
    end if;
   
  end process;
  
  enable <= not hold;

  no_target_gen : if (CONF.tech = NO_TARGET) generate
    process(clk)
    begin
      if rising_edge(clk) then 
        if (enable = '1') then
          if wrvecen = '1' then
            ram(to_integer(unsigned(wrvecnr))) <= data_in;
          end if;
        end if;
      end if;
    end process;
  
    process(clk)
    begin
      if rising_edge(clk) then 
        if (enable = '1') then
          data_out <= ram(to_integer(unsigned(raddr)));
        end if;
      end if;
    end process;
  end generate;

--  xilinx_gen : if (CONF.tech = XILINX) generate
--    vectab_ram_inst: xilinx_vectab_ram
--      port map (
--        clk     => clk,
--        enable  => enable,
--        raddr   => raddr,
--        rdata   => data_in,
--        waddr   => wrvecnr,
--        wdata   => data_out,
--        wen     => wrvecen
--      );
--  end generate;

  altera_gen : if (CONF.tech = ALTERA) generate
    process(clk)
    begin
      if rising_edge(clk) then 
        if (enable = '1') then
          if wrvecen = '1' then
            ram(to_integer(unsigned(wrvecnr))) <= data_in;
          end if;
        end if;
      end if;
    end process;
  
    process(clk)
    begin
      if rising_edge(clk) then 
        if (enable = '1') then
          data_out <= ram(to_integer(unsigned(raddr)));
        end if;
      end if;
    end process;
  end generate;
							
end behaviour;
