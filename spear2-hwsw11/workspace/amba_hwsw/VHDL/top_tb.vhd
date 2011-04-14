library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_pkg.all;
use work.pkg_dis7seg.all;

use std.textio.all;

entity top_tb is
end top_tb;

architecture behaviour of top_tb is

  constant  cc    : TIME := 20 ns;
  constant  bittime    : integer := 434; --8.681 us / 20 ns ;

  type parity_type is (none, even, odd);

  signal clk      : std_ulogic;
  signal rst      : std_ulogic;
  signal D_RxD    : std_logic;
  signal D_TxD    : std_logic;
  signal digits   : digit_vector_t(7 downto 0);
  -- SDRAM Interface (AMBA)
  signal sdcke    : std_logic;
  signal sdcsn    : std_logic;
  signal sdwen    : std_logic;
  signal sdrasn   : std_logic;
  signal sdcasn   : std_logic;
  signal sddqm    : std_logic_vector(3 downto 0);
  signal sdclk    : std_logic;
  signal sa       : std_logic_vector(14 downto 0);
  signal sd       : std_logic_vector(31 downto 0);
  
  file appFile : text  open read_mode is "app.srec";

  component top
    port (
      db_clk      : in    std_ulogic;
      rst      : in    std_ulogic;
      D_RxD    : in    std_logic;
      D_TxD    : out   std_logic;
      -- 7Segment Anzeige
      digits      : out digit_vector_t(7 downto 0);
      -- SDRAM Controller Interface (AMBA)
      sdcke       : out std_logic;
      sdcsn       : out std_logic;
      sdwen       : out std_logic;
      sdrasn      : out std_logic;
      sdcasn      : out std_logic;
      sddqm       : out std_logic_vector(3 downto 0);
      sdclk       : out std_logic;
      sa          : out std_logic_vector(14 downto 0);
      sd          : inout std_logic_vector(31 downto 0)
      );    
  end component;
  
  
begin

  top_1: top
    port map (
      db_clk         => clk,
      rst            => rst,
      D_RxD          => D_RxD,
      D_TxD          => D_TxD,
      digits         => digits,
      sdcke          => sdcke,
      sdcsn          => sdcsn,
      sdwen          => sdwen,
      sdrasn         => sdrasn,
      sdcasn         => sdcasn,
      sddqm          => sddqm,
      sdclk          => sdclk,
      sa             => sa,
      sd             => sd);

  clkgen : process
  begin
    clk <= '1';
    wait for cc/2;
    clk <= '0'; 
    wait for cc/2;
  end process clkgen;
  
  
  test: process
    
    procedure icwait(cycles: Natural) is
    begin 
      for i in 1 to cycles loop 
	wait until clk= '0' and clk'event;
      end loop;
    end ;

    procedure ser_send(send: Natural; parity: parity_type) is
      variable parityBit : std_logic;
    begin
      parityBit := '0';
      D_RxD <= '0';-- startbit(0)
      icwait(bittime);  

      -- send data bits
      for i in 0 to 7 loop 
        D_RxD <= to_unsigned(send,8)(i); icwait(bittime);
        parityBit := parityBit xor to_unsigned(send,8)(i);
      end loop;

      -- optional parity bit
      if parity /= none then
        if parity = odd then
          parityBit := not parityBit;
        end if;
        D_Rxd <= parityBit;
        icwait(bittime);
      end if;

      -- Stop1
      D_Rxd <= '1';
      icwait(bittime);
    end;
    
    variable l : line;
    variable c : character;
    variable neol : boolean;
    
  begin

    rst <= RST_ACT;
    D_Rxd <= '1';
    icwait(100);
    rst <= not RST_ACT;

    -- wait until bootloader is ready to receive program
    icwait(2000);
  
    while not endfile(appFile) loop
      readline(appFile, l);
      loop
        read(l, c, neol);
        exit when not neol;
        ser_send(character'pos(c), even);
      end loop;
      -- newline
      ser_send(10, even);
    end loop;

    wait;
  
  end process test;

  

end behaviour; 

