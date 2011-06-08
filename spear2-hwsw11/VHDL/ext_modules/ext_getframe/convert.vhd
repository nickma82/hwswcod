-----------------------------------------------------------------------------
-- Entity:      convert
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Bilder von der Kamera einlesen und in ein Ram speichern
-- Date:		8.06.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.misc.all;

USE work.spear_pkg.all;
use work.pkg_getframe.all;

entity convert is
	port (
		clk       			: in  std_logic;
		rst					: in  std_logic;		
		start_conv			: in  std_logic;
		line_ready			: in  std_logic;
		next_burst			: out std_logic;
		            		
		rd_en				: out std_logic;
		rd_address			: out dot_addr_type;
		rd_data_even		: in  dot_type;
		rd_data_odd			: in  dot_type;
		            		
		wr_en_burst			: out std_logic;
		wr_address_burst	: out pix_addr_type;
		wr_data_burst		: out pix_type	
    );
end ;

architecture rtl of convert is
	type raw_read_dot_type is record
		enable		: std_logic;
		data_odd	: dot_type;
		data_even	: dot_type;
		address		: dot_addr_type;
	end record;
	
	signal rd_raw_dot_next : raw_read_dot_type;
	signal rd_raw_dot : raw_read_dot_type := 
	(
		enable		=> '0',
		data_odd	=> (others => '0'), 
		data_even	=> (others => '0'),
		address		=> (others => '0')
	);
begin

end;
