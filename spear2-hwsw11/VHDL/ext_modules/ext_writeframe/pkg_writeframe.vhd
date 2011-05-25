-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger
-- Description: Ein Bild in Framebuffer übertragen
-- Date:		15.05.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.spear_pkg.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;

library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.misc.all;


package pkg_writeframe is

	constant SCREEN_W					: integer := 800;
	constant SCREEN_H					: integer := 480;
	constant PIXEL_COUNT				: integer := SCREEN_W*SCREEN_H;
	constant FRAMEBUFFER_BASE_ADR : std_logic_vector(31 downto 0) := "11100000000000000000000000000000";
	constant FRAMEBUFFER_END_ADR	: std_logic_vector(31 downto 0) := FRAMEBUFFER_BASE_ADR+(PIXEL_COUNT*4);
	
	component ext_writeframe
	  port (
		clk        : IN  std_logic;
		extsel     : in   std_ulogic;
		exti       : in  module_in_type;
		exto       : out module_out_type;
		ahbi      : in  ahb_mst_in_type;
		ahbo      : out ahb_mst_out_type;
		cm_d		: in std_logic_vector(11 downto 0);
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		--cm_xclkin	: out std_logic;
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic 	--Snapshot strobe
		);
	end component;
  
  
end pkg_writeframe;
