-----------------------------------------------------------------------------
-- Entity:      read_cam
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Bilder von der Kamera einlesen und in ein Ram speichern
-- Date:		1.06.2011
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


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

entity read_raw is
	port (
		clk       	: in  std_logic;
		rst			: in  std_logic;
		getframe	: in  std_logic;
		
		line_ready	: out std_logic;
		
		cm_d		: in std_logic_vector(11 downto 0); --dot data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--dot Clock
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic; 	--Snapshot strobe
		
		wr_en_odd	: out std_logic;
		wr_en_even	: out std_logic;
		wr_data		: out dot_type;
		wr_address	: out dot_addr_type
    );
end ;

architecture rtl of read_raw is

	-- Cam read raw Signals
	type state_type is (reset, wait_getframe, wait_frame_valid, read_dot, next_line, wait_frame_invalid);
	 
	type readraw_reg_type is record
		--intern
		state		: state_type;
		toggle_r	: std_logic;
		toggle_c	: std_logic;
		p_r      	: integer range 0 to CAM_H;
		p_c      	: integer range 0 to CAM_W;
		--rams
		en_odd		: std_logic;
		en_even		: std_logic;
		data		: dot_type;
		address		: dot_addr_type;
		--cam
		cm_trigger	: std_logic;
		conv_line_rdy:std_logic;
	end record;


	signal r_next : readraw_reg_type;
	signal r : readraw_reg_type := 
	(
		state		=> reset,
		toggle_r	=> '0',
		toggle_c	=> '0',
		p_r 		=> 0,
		p_c 		=> 0,
		
		en_odd		=> '0',
		en_even		=> '0',
		data		=> (others => '0'),
		address		=> (others => '0'),
		cm_trigger 	=> '0',
		conv_line_rdy	=> '0'
	);	
begin
	read_raw : process(r, getframe, cm_d, cm_lval, cm_fval, rst)
	variable v 				: readraw_reg_type;
	--variable tmp_pixel		: integer range 4095 downto 0;
	begin
		v := r;
    	
    	v.en_odd := '0'; --disable every cycle
    	v.en_even := '0'; --disable every cycle
    	
		------------------------
		---	CCD Handler - FALLING EDGE PIXCLK sensitiv
		--- state_pixsync_cam_type
		------------------------
		case r.state is
			when reset =>
				v.state := wait_getframe;
			when wait_getframe =>
				if getframe = '1' then
					v.state := wait_frame_invalid;
				end if;
			when wait_frame_valid =>
				--@TODO trigger starten
				if cm_fval = '1' then
					v.conv_line_rdy := '0';
					if cm_lval = '1' then
						v.state := read_dot;
					end if;
				end if;
			when read_dot =>
				if r.p_c < CAM_W-1 then
					v.state := read_dot;
				else
					--eol1 condition
					v.state := next_line;
				end if;
			when next_line =>
				v.conv_line_rdy := '1';
				if r.p_r < CAM_H-1 then
					v.state := wait_frame_valid;
				else
					v.state := wait_frame_invalid; --ganzes Bild gelesen
				end if;
			when wait_frame_invalid =>
				if cm_lval = '0' and cm_fval = '0' then
					v.state := wait_frame_valid;
				end if;
		end case;
		
		---logic: row & column counter
		---logic: dot_valid
		--takes care about PIX: p_c, p_r, toggle_c and toggle_r
		case r.state is
			when reset =>
				null;
			when wait_getframe =>
				null;
			when wait_frame_valid =>
				v.cm_trigger := '1';
			when read_dot =>
				v.cm_trigger := '0';
				if r.toggle_r = '0' then
					--odd
					v.en_even := '1';
				else
					--even
					v.en_odd := '1';
				end if;
				v.p_c := r.p_c + 1;
				v.toggle_c := not r.toggle_c;
				-- dot data logic
				v.data := cm_d(11 downto 4);
				--v.data := cm_d(7 downto 0); -- test
			when next_line =>
				--if r.p_r < CAM_H-1 then
				v.p_r := r.p_r + 1;
				v.toggle_r := not r.toggle_r;
				v.p_c := 0;
				v.toggle_c := '0';
			when wait_frame_invalid =>
				--nur hier nötig, weil jedes Mal zum Syncen hier sind
				v.p_r 		:=  0;
				v.toggle_r	:= '0';
				v.p_c 		:=  0;
				v.toggle_c	:= '0';
				v.cm_trigger:= '0';
			when others =>
				null;
		end case;
		
		
		wr_data		<= v.data;
		wr_address	<= std_logic_vector(to_unsigned(r.p_c, DOT_ADDR_WIDTH)); --@TODO Grenzen der Counter angleichen
		wr_en_odd	<= v.en_odd;
		wr_en_even	<= v.en_even;
		line_ready	<= v.conv_line_rdy;
		
		cm_trigger <= v.cm_trigger;
    	cm_reset <= rst;
    	r_next <= v;
    end process;
    

	------------------------
	---	Sync Daten übernehmen
	------------------------
    read_raw_reg : process(cm_pixclk)
	begin
		if falling_edge(cm_pixclk) then
			if rst = RST_ACT then
				r.state <= reset;
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;

