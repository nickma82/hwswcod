library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

entity spear_regf is
  generic (
    CONF : spear_conf_type); 
  port (
    wclk    : in  std_ulogic;
    rclk    : in  std_ulogic;
    hold    : in  std_ulogic;

    wdata   : in  std_logic_vector(CONF.word_size-1 downto 0);
    waddr   : in  std_logic_vector(REGADDR_W-1 downto 0);
    wen     : in  std_ulogic;
    raddr1  : in  std_logic_vector(REGADDR_W-1 downto 0);
    raddr2  : in  std_logic_vector(REGADDR_W-1 downto 0);

    rdata1  : out std_logic_vector(CONF.word_size-1 downto 0);
    rdata2  : out std_logic_vector(CONF.word_size-1 downto 0));
end spear_regf;

architecture behaviour of spear_regf is

  signal regfram1i_wdata       : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfram1i_waddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram1i_wen         : std_ulogic;
  signal regfram1i_raddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram1o_rdata       : std_logic_vector(CONF.word_size-1 downto 0);

  signal regfram2i_wdata       : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfram2i_waddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram2i_wen         : std_ulogic;
  signal regfram2i_raddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram2o_rdata       : std_logic_vector(CONF.word_size-1 downto 0);

  signal enable : std_ulogic;

begin

  enable <= not hold;

  regfram1i_wdata <= wdata;
  regfram1i_waddr <= waddr;
  regfram1i_wen   <= wen;
  regfram1i_raddr <= raddr1;

  regfram2i_wdata <= wdata;
  regfram2i_waddr <= waddr;
  regfram2i_wen   <= wen;
  regfram2i_raddr <= raddr2;
  
  rdata1 <= regfram1o_rdata;
  rdata2 <= regfram2o_rdata;

  ram1 : spear_regfram
  generic map (CONF => CONF)
  port map (wclk   => wclk,
            rclk   => rclk,
            enable => enable,
            wdata  => regfram1i_wdata,
            waddr  => regfram1i_waddr,
            wen    => regfram1i_wen,
            raddr  => regfram1i_raddr,
            rdata  => regfram1o_rdata);
  
  ram2 : spear_regfram
  generic map (CONF => CONF)
  port map (wclk   => wclk,
            rclk   => rclk,
            enable => enable,
            wdata  => regfram2i_wdata,
            waddr  => regfram2i_waddr,
            wen    => regfram2i_wen,
            raddr  => regfram2i_raddr,
            rdata  => regfram2o_rdata);
  
end behaviour;
