-------------------------------------------------------------------------------
-- Title      : miniUART Baud Rate Generator
-- Module     : ext_miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : miniUART_brg.vhd
-- Author     : Roman Seiger
-- Company    : TU Wien - Institut f�r Technische Informatik
-- Created    : 2005-03-08
-- Last update: 2007-05-28
-------------------------------------------------------------------------------

-- TODO: OVERFLOWWIDTH ist nicht konsistent!!!

----------------------------------------------------------------------------------
-- LIBRARY
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use IEEE.std_logic_UNSIGNED.all;
use work.pkg_basic.all;
use work.pkg_miniUART.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
entity miniUART_BRG is
  
  port (
    clk : in std_logic;
    reset : in std_logic;
    StartTrans : in std_logic;          -- Transmitterpulse eingeschaltet?
    StartRec : in std_logic;            -- Receiverpulse eingeschaltet?
    UBRS : in std_logic_vector(15 downto 0);  -- Baud Rate Selection Register 
                                              -- (12 bit ganzzahlig, 4 bit fraction)
    
    tp : out std_logic;                 -- Transmitterpulse
    rp : out std_logic                  -- Receiverpulse
    );
  
end miniUART_BRG;

----------------------------------------------------------------------------------
-- ARCHITECTURE
----------------------------------------------------------------------------------
architecture behaviour of miniUART_BRG is
  
  -- Z�hlerbreite (11bit aus UBRS + 1bit �berlaufschutz)
  constant COUNTERWIDTH : integer := 12;
  -- Z�hlerkonstanten
  constant COUNTER_ZERO : std_logic_vector(COUNTERWIDTH-1 downto 0) := (0 => '1', others => '0');
  -- �berlaufregisterbreite (4bit aus UBRS + 1bit �berlauf)
  constant OVERFLOWWIDTH : integer := 6;

  
  -- interne Signale zur Zwischenspeicherung der Eing�nge
  signal UBRS_i, UBRS_nxt : std_logic_vector(16 downto 0);
  
  -- Z�hler
  signal counter : std_logic_vector(COUNTERWIDTH-1 downto 0);
  signal next_counter : std_logic_vector(COUNTERWIDTH-1 downto 0);

  -- �berlaufregister
  signal overflow : std_logic_vector(OVERFLOWWIDTH-1 downto 0);
  signal next_overflow : std_logic_vector(OVERFLOWWIDTH-1 downto 0);

  -- Transmitpulse oder Receivepulse?
  signal pulse_toggle : std_logic;
  signal next_pulse_toggle : std_logic;
  
begin  -- behaviour

  BRG_COUNTER: process (clk, reset)
  begin  -- process BRG_COUNTER
    
    -- ausgeschaltet, entspricht reset
    if reset = RST_ACT then
      counter <= COUNTER_ZERO;
      overflow(4 downto 0) <= (others => '0');-- UBRS(4 downto 0);
      overflow(OVERFLOWWIDTH-1) <= '0';
      UBRS_i(16) <= '0';
      UBRS_i(15 downto 0) <= (others => '1'); --UBRS;          -- UBRS �bernehmen
      pulse_toggle <= '0';              -- Transmitter zuerst!
      -- in Betrieb, runterz�hlen
    elsif (clk'event and clk = '1') then
      counter <= next_counter;
      overflow <= next_overflow;
      UBRS_i <= UBRS_nxt;
      pulse_toggle <= next_pulse_toggle;
    end if;
  end process BRG_COUNTER;


  BRG_CALC_NEXT: process (counter, overflow, UBRS_i, UBRS, StartTrans,
                          StartRec, pulse_toggle)
  begin  -- process BRG_CALC_NEXT
    -- Defaultwerte

    tp <= '0';
    rp <= '0';
    UBRS_nxt <= UBRS_i;
     -- counter weiterz�hlen
    next_counter <= counter - '1';
    next_overflow <= overflow;
    -- pulse_toggle halten
    next_pulse_toggle <= pulse_toggle;

    if (StartTrans /= BRG_ON) and (StartRec /= BRG_ON) then
      next_counter <= COUNTER_ZERO;
      next_overflow(4 downto 0) <= UBRS(4 downto 0);
      next_overflow(OVERFLOWWIDTH-1) <= '0';
      next_pulse_toggle <= '0';
      UBRS_nxt(16) <= '0';
      UBRS_nxt(15 downto 0) <= UBRS; 
 -- counter zur�cksetzen, neues overflow berechnen
    elsif counter = COUNTER_ZERO then
      next_counter <= UBRS_i(16 downto 5) + overflow(5);
      next_overflow <= (overflow and "011111") + UBRS_i(4 downto 0);
      -- Pulses ausgeben
      tp <= (not pulse_toggle) and StartTrans;
      rp <= pulse_toggle and StartRec;
      next_pulse_toggle <= not pulse_toggle;
    end if;
    
  end process BRG_CALC_NEXT;




end behaviour;














