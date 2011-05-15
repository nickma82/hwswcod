-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger
-- Description: Ein Bild in Framebuffer übertragen
-- Date:		15.05.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;

use work.spear_pkg.all;

package pkg_writeframe is

constant SCREEN_W					: integer := 800;
constant SCREEN_H					: integer := 480;
constant PIXEL_COUNT				: SCREEN_W*SCREEN_H;
constant FRAMEBUFFER_BASE_ADR 		: 16#E0000000#;
constant FRAMEBUFFER_END_ADR		: FRAMEBUFFER_BASE_ADR+PIXEL_COUNT;

component ext_writeframe
  port (
  	clk        : IN  std_logic;
    extsel     : in   std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type;
    ahbi      : in  ahb_mst_in_type;
    ahbo      : out ahb_mst_out_type);
end component;
  
  
end pkg_writeframe;
