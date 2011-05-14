------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package: 	misc
-- File:	misc.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Misc models
------------------------------------------------------------------------------

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
