-----------------------------------------------------------------------------
-- Entity:      getframe
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Ein Spear2 Extension Modul um Bild von der Kamera einlesen und in Framebuffer übertragen
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


package pkg_getframe is

	constant SCREEN_W					: integer := 800;
	constant SCREEN_H					: integer := 480;
	
	constant CAM_W						: integer := 640;
	constant CAM_H						: integer := SCREEN_H;
	constant CAM_PIXEL_COUNT			: integer := CAM_W*CAM_H;
	
	constant PIXEL_COUNT				: integer := SCREEN_W*SCREEN_H;
	constant FRAMEBUFFER_BASE_ADR : std_logic_vector(31 downto 0) := "11100000000000000000000000000000";
	constant FRAMEBUFFER_END_ADR	: std_logic_vector(31 downto 0) := FRAMEBUFFER_BASE_ADR+(PIXEL_COUNT*4);
	
	-- 	constante für burstlänge
	constant BURST_LENGTH				: natural range 2 to 8 := 4;
	
	constant BURST_PIXEL_COUNT			: natural := 2**BURST_LENGTH;
	constant BURST_PER_FRAME_COUNT		: natural := PIXEL_COUNT/BURST_PIXEL_COUNT;
	
	-- DOT definitions
	constant DOT_WIDTH					: natural := 8;
	constant DOT_ADDR_WIDTH				: natural := 10;
	
	subtype dot_type is std_logic_vector(DOT_WIDTH-1 downto 0);
	subtype dot_addr_type is std_logic_vector(DOT_ADDR_WIDTH-1 downto 0);
	
	-- PIXEL definitions
	constant PIXEL_WIDTH				: natural := 24; 
	constant PIXEL_ADDR_WIDTH			: natural := 12; 
	constant BURST_BUFFER_LENGTH		: natural := (2**PIXEL_ADDR_WIDTH)/BURST_PIXEL_COUNT;
	
		
	subtype pix_type is std_logic_vector(PIXEL_WIDTH-1 downto 0);
	subtype pix_addr_type is std_logic_vector(PIXEL_ADDR_WIDTH-1 downto 0);
	
	constant BURST_RAM_END_ADR			: pix_addr_type := (others=>'1');
	
	subtype row_count_type is integer range 0 to CAM_H-1;
	
	component ext_getframe
	  port (
		clk      	: in std_logic;
		reset		: in std_logic;
		extsel   	: in std_ulogic;
		exti     	: in module_in_type;
		exto     	: out module_out_type;
		dmai    	: out ahb_dma_in_type;
		dmao    	: in ahb_dma_out_type;
		cm_d		: in std_logic_vector(11 downto 0);
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic; 	--Snapshot strobe
		
		led_red		: out 	std_logic_vector(17 downto 0)
		);
	end component;
  
	component read_raw
		port (
			clk       	: in  std_logic;
			rst			: in  std_logic;
			getframe	: in  std_logic;
			
			line_ready	: out std_logic;
			
			cm_d		: in std_logic_vector(11 downto 0); --dot data
			cm_lval 	: in std_logic; 	--Line valid
			cm_fval 	: in std_logic; 	--Frame valid
			cm_pixclk	: in std_logic; 	--dot Clock
			cm_trigger	: out std_logic;	--Snapshot trigger
			cm_strobe	: in std_logic; 	--Snapshot strobe
			
			wr_en_odd	: out std_logic;
			wr_en_even	: out std_logic;
			wr_data		: out dot_type;
			wr_address	: out dot_addr_type;
			frame_stop	: out std_logic;
			led_red		: out 	std_logic_vector(5 downto 0)
		);
	end component;
	
	component convert
		port (
			clk       			: in  std_logic;
			rst					: in  std_logic;		
			line_ready			: in  std_logic;
			next_burst			: out std_logic;
			            		
			rd_address			: out dot_addr_type;
			rd_data_even		: in  dot_type;
			rd_data_odd			: in  dot_type;
			        
			wr_en_burst			: out std_logic;
			wr_address_burst	: out pix_addr_type;
			wr_data_burst		: out pix_type;
			led_red		: out 	std_logic_vector(5 downto 0);
			frame_stop			: in std_logic
		);
	end component;
	
	component writeframe
		port (
			clk     			: in  std_logic;
			rst    				: in  std_logic;
			dmai    			: out  ahb_dma_in_type;
			dmao    			: in   ahb_dma_out_type;
			next_burst			: in std_logic;
			frame_done			: out std_logic;
			return_pgm			: out std_logic;
			rd_address_burst	: out pix_addr_type;
			rd_data_burst		: in pix_type;
			clear_screen		: in std_logic;
			clear_done			: out std_logic;
			frame_stop			: in std_logic;
			tx					: in natural range 0 to CAM_W-1;
			ty					: in natural range 0 to CAM_H-1;
			bx					: in natural range 0 to CAM_W-1;
			by					: in natural range 0 to CAM_H-1;
			led_red				: out 	std_logic_vector(5 downto 0)
		);
	end component;
	
	component dp_ram
		generic
		(
			ADDR_WIDTH 	: integer range 1 to integer'high;
			DATA_WIDTH 	: integer range 1 to integer'high
		);
		port
		(
			wrclk       : in std_logic;
			wen			: in std_logic;
			wraddress 	: in std_logic_vector(ADDR_WIDTH -   1 downto 0);
			wrdata_in 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
			
			rdclk		: in std_logic;
			rdaddress 	: in std_logic_vector(ADDR_WIDTH -   1 downto 0);
			rddata_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component dp_ram;
	
end pkg_getframe;
