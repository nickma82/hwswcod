-------------------------------------------------------------------------------
-- Title      : 7 Segment Display Architecture
-- Project    : SPEAR - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_sysctrl_ent.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr technische Informatik
-- Created    : 2002-02-11
-- Last update: 2011-03-20
-- Platform   : SUN Solaris 
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-02-11  1.0      delvai	Created
-------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.spear_pkg.all;

use work.pkg_dis7seg.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------

entity ext_Dis7Seg is
  generic (
    DIGIT_COUNT : integer range 1 to 8;
    MULTIPLEXED : integer range 0 to 1);
  port (
    clk        : IN  std_logic;
    extsel     : in   std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type;
    digits     : out digit_vector_t((DIGIT_COUNT-1) * (1-MULTIPLEXED) downto 0);
    DisEna     : OUT std_logic;
    PIN_select : OUT std_logic_vector(DIGIT_COUNT-1 downto 0));
end entity ext_Dis7Seg;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------


