library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_pkg.all;
use work.pkg_dis7seg.all;

use work.pkg_writeframe.all;
use work.pkg_aluext.all;

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
  -- LCD (AMBA)
  signal ltm_hd      : std_logic;
  signal ltm_vd      : std_logic;
  signal ltm_r       : std_logic_vector(7 downto 0);
  signal ltm_g       : std_logic_vector(7 downto 0);
  signal ltm_b       : std_logic_vector(7 downto 0);
  signal ltm_nclk    : std_logic;
  signal ltm_den     : std_logic;
  signal ltm_grest   : std_logic;
  
 
  signal led_red	: std_logic_vector(17 downto 0);
  
  signal cm_d		: std_logic_vector(11 downto 0); --pixel data
  signal cm_lval 	: std_logic; 	--Line valid
  signal cm_fval 	: std_logic; 	--Frame valid
  signal cm_pixclk	: std_logic; 	--pixel Clock
  signal cm_xclkin	: std_logic; 	--External input clock
  signal cm_reset	: std_logic;	--D5M reset
  signal cm_trigger	: std_logic;	--Snapshot trigger
  signal cm_strobe	: std_logic; 	--Snapshot strobe
  signal cm_sdata	: std_logic; 	--Serial data
  signal cm_sclk	: std_logic;		--Serial clk
  
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
      sd          : inout std_logic_vector(31 downto 0);
      -- LCD (AMBA)
      ltm_hd      : out std_logic;
      ltm_vd      : out std_logic;
      ltm_r       : out std_logic_vector(7 downto 0);
      ltm_g       : out std_logic_vector(7 downto 0);
      ltm_b       : out std_logic_vector(7 downto 0);
      ltm_nclk    : out std_logic;
      ltm_den     : out std_logic;
      ltm_grest   : out std_logic;
      
      -- Leds
	  led_red		: out std_logic_vector(17 downto 0);
	  
	  -- Cam
	  cm_d		: in std_logic_vector(11 downto 0); --pixel data
	  cm_lval 	: in std_logic; 	--Line valid
	  cm_fval 	: in std_logic; 	--Frame valid
	  cm_pixclk	: in std_logic; 	--pixel Clock
	  cm_xclkin	: out std_logic; 	--External input clock
	  cm_reset	: out std_logic;	--D5M reset
	  cm_trigger	: out std_logic;	--Snapshot trigger
	  cm_strobe	: in std_logic; 	--Snapshot strobe
	  cm_sdata	: inout std_logic; 	--Serial data
	  cm_sclk		: out std_logic		--Serial clk
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
		sd             => sd,
		ltm_hd         => ltm_hd,
		ltm_vd         => ltm_vd,
		ltm_r          => ltm_r,
		ltm_g          => ltm_g,
		ltm_b          => ltm_b,
		ltm_nclk       => ltm_nclk,
		ltm_den        => ltm_den,
		ltm_grest      => ltm_grest,
		led_red		=> led_red,
      	cm_d		=> cm_d,
		cm_lval 	=> cm_lval,
		cm_fval 	=> cm_fval,
		cm_pixclk	=> cm_pixclk,	
		cm_xclkin	=> cm_xclkin,	
		cm_reset	=> cm_reset,
		cm_trigger	=> cm_trigger,
		cm_strobe	=> cm_strobe,	
		cm_sdata	=> cm_sdata,
		cm_sclk	    => cm_sclk
      );

  clkgen : process
  begin
    clk <= '1';
    cm_pixclk <= '0';
    wait for cc/2;
    clk <= '0'; 
    cm_pixclk <= '1';
    wait for cc/2;
  end process clkgen;
  
  camgen : process
  	variable col_cnt : integer;
  	variable row_cnt : integer;
  begin
  	col_cnt := 0;
  	row_cnt := 0;
  	
  	
  	cm_lval <= '0';
  	cm_fval <= '0';
  	
  	wait for 300*cc;
  	
  	cm_fval <= '1';
	wait for 20*cc;
	
  	for row_cnt in 1 to 480 loop
  		cm_lval <= '1';
  		for col_cnt in 1 to 640 loop
  			cm_d <= "111111111111";
  			wait for cc;
  		end loop;
  		cm_lval <= '0';
  		wait for 5*cc;
  	end loop;
  	cm_fval <= '0';
  end process camgen;
  
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
      --cm_sdata <= 'L';
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

