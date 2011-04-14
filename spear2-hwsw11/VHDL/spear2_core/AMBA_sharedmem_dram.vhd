-------------------------------------------------------------------------------
-- Company:		  Institut f�r Technische Informatik - Abteilung ECS
-- Engineer:	  Martin Fletzer
-- Reused from: Josef Mosser, 0126655
--
-- Create Date:	 
-- Design Name:	 ext_sm_dram
-- Module Name:	 32 bit dual ported memory - Behavioral
-- Project Name: AMBA4Spear
-- Target Devices:
-- Tool versions:
-- Description:	 definition of a 32 bit dual ported memory
--
-- Dependencies: used in ext_ambadram
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

entity AMBA_sharedmem_dram is
  generic (
    CONF : spear_conf_type);
  port (
    clk     : in  std_ulogic;
    dramsel : in  std_ulogic;

    write_en  : in  std_ulogic;
    byte_en   : in  std_logic_vector(3 downto 0);
    data_in   : in  std_logic_vector(CONF.word_size-1 downto 0);
    addr      : in  std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    data_out  : out std_logic_vector(CONF.word_size-1 downto 0));
end AMBA_sharedmem_dram;

architecture behaviour of AMBA_sharedmem_dram is

constant WORD_W : natural := CONF.amba_word_size;
constant ADDR_W : natural := CONF.amba_shm_size - CONF.amba_word_size/16;

subtype WORD is std_logic_vector(WORD_W-1 downto 0);

signal ram0i_wdata       : std_logic_vector(7 downto 0);
signal ram0i_waddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram0i_wen         : std_ulogic;
signal ram0i_raddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram1i_wdata       : std_logic_vector(7 downto 0);
signal ram1i_waddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram1i_wen         : std_ulogic;
signal ram1i_raddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram2i_wdata       : std_logic_vector(7 downto 0);
signal ram2i_waddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram2i_wen         : std_ulogic;
signal ram2i_raddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram3i_wdata       : std_logic_vector(7 downto 0);
signal ram3i_waddr       : std_logic_vector(ADDR_W-1 downto 0);
signal ram3i_wen         : std_ulogic;
signal ram3i_raddr       : std_logic_vector(ADDR_W-1 downto 0);

signal ram0o_rdata       : std_logic_vector(7 downto 0);
signal ram1o_rdata       : std_logic_vector(7 downto 0);
signal ram2o_rdata       : std_logic_vector(7 downto 0);
signal ram3o_rdata       : std_logic_vector(7 downto 0);

--signal wdata_s : WORD;


begin


  comb : process(dramsel, write_en, byte_en, data_in, addr, ram0o_rdata, ram1o_rdata, ram2o_rdata, ram3o_rdata)
  begin
  
    ram0i_wdata <= (others => '0');
    ram1i_wdata <= (others => '0');
    ram2i_wdata <= (others => '0');
    ram3i_wdata <= (others => '0');
    ram0i_raddr <= (others => '0');
    ram1i_raddr <= (others => '0');
    ram2i_raddr <= (others => '0');
    ram3i_raddr <= (others => '0');
    ram0i_waddr <= (others => '0');
    ram1i_waddr <= (others => '0');
    ram2i_waddr <= (others => '0');
    ram3i_waddr <= (others => '0');
    
    if (dramsel = '1') then
      ram0i_wen <= byte_en(0) and write_en;
      ram1i_wen <= byte_en(1) and write_en;
      ram2i_wen <= byte_en(2) and write_en;
      ram3i_wen <= byte_en(3) and write_en;
    else
      ram0i_wen <= not MEM_WR;
      ram1i_wen <= not MEM_WR;
      ram2i_wen <= not MEM_WR;
      ram3i_wen <= not MEM_WR;
    end if;

    if CONF.amba_word_size = 32 then
      ram0i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram1i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram2i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram3i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram0i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram1i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram2i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram3i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    else
      ram0i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram1i_raddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram0i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      ram1i_waddr(ADDR_W-1 downto 0) <= addr(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    end if;
    
    ram3i_wdata <= data_in(WORD_W-1 downto WORD_W-8);
    ram2i_wdata <= data_in(WORD_W-9 downto WORD_W-16);
    ram1i_wdata <= data_in(15 downto 8);
    ram0i_wdata <= data_in(7 downto 0);
    
    if (dramsel = '1') then
      data_out(WORD_W-1 downto WORD_W-8) <= ram3o_rdata;
      data_out(WORD_W-9 downto WORD_W-16) <= ram2o_rdata;
      data_out(15 downto 8) <= ram1o_rdata;
      data_out(7 downto 0) <= ram0o_rdata;
    else
      data_out <= (others => '0');
    end if;
    
  end process;


  ram0 : AMBA_sharedmem_byteram
  generic map(CONF => CONF)
  port map (wclk => clk,
            rclk => clk,
            wdata => ram0i_wdata,
            waddr => ram0i_waddr,
            wen   => ram0i_wen,
            raddr => ram0i_raddr,
            rdata => ram0o_rdata);

  ram1 : AMBA_sharedmem_byteram
  generic map(CONF => CONF)
  port map (wclk => clk,
            rclk => clk,
            wdata => ram1i_wdata,
            waddr => ram1i_waddr,
            wen   => ram1i_wen,
            raddr => ram1i_raddr,
            rdata => ram1o_rdata);

  ramcfg : if CONF.amba_word_size = 32 generate
    ram2 : AMBA_sharedmem_byteram
      generic map(CONF => CONF)
      port map (wclk => clk,
                rclk => clk,
                wdata => ram2i_wdata,
                waddr => ram2i_waddr,
                wen   => ram2i_wen,
                raddr => ram2i_raddr,
                rdata => ram2o_rdata);

    ram3 : AMBA_sharedmem_byteram
      generic map(CONF => CONF)
      port map (wclk => clk,
                rclk => clk,
                wdata => ram3i_wdata,
                waddr => ram3i_waddr,
                wen   => ram3i_wen,
                raddr => ram3i_raddr,
                rdata => ram3o_rdata);

  end generate;

end behaviour;
