-----------------------------------------------------------------------------
-- Entity:      cam_config
-- Author:      Johannes Kasberger, Nick Mayerhofer, Markus Klein
-- Description: Kamera Parameter über two-wire-bus schicken
-- Date:		24.05.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.spear_pkg.all;

package pkg_camconfig is

constant CLK_COUNT : integer := 100;
constant CLK_HALF  : integer := CLK_COUNT/2;

type cam_state_type is (reset, idle, send_start_bit, send_stop_bit, wait_until_low, restore_read, done, send_w_id, send_r_id, send_address, write1, write2, read1, read2, send_ack, wait_ack, wait_until_high, error_state);
	
component ext_camconfig
	port (
		clk     		: in  	std_logic;
		extsel  		: in  	std_ulogic;
		exti    		: in  	module_in_type;
		exto    		: out 	module_out_type;
		sclk			: out	std_logic;
		sdata_in		: in	std_logic;
		sdata_out		: out	std_logic;
		sdata_out_en 	: out 	std_logic
	);
end component;
  
end pkg_camconfig;
