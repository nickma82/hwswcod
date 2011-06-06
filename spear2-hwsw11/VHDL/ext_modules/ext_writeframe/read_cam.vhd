-----------------------------------------------------------------------------
-- Entity:      read_cam
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Bilder von der Kamera einlesen und in ein Ram speichern
-- Date:		1.06.2011
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
use work.pkg_writeframe.all;

entity read_cam is
	port (
		clk       	: in  std_logic;
		rst			: in  std_logic;
		enable		: in  std_logic;
		
		cm_d		: in std_logic_vector(11 downto 0); --pixel data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic; 	--Snapshot strobe
			
		rd_row_rdy	: out row_count_type; --number of line which's rdy
		rd_data		: out pixel_type;
		rd_clk		: in std_logic
    );
end ;

architecture rtl of read_cam is

	-- Cam Async Signals
	type state_type is (reset, wait_getframe, wait_frame_valid, read_dot_r, read_dot_g1, read_dot_g2, read_dot_b, next_line, wait_frame_invalid);
	 
	type reg_type is record
		state		: state_type;
		next_dot	: state_type;
		toggle_r	: std_logic;
		toggle_c	: std_logic;
		p_r      : integer range 0 to CAM_H;
		p_c      : integer range 0 to CAM_W;
	end record;


	signal r_next : reg_type;
	signal r : reg_type := 
	(
		state	 => reset,
		next_dot => reset,
		toggle_r => '0',
		toggle_c => '0',
		p_r => 0,
		p_c => 0
	);
begin
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r,enable,cm_d,cm_lval,cm_fval,rst)
	variable v 				: reg_type;
	variable vpix_next_dot	: state_type;
	--variable tmp_pixel		: integer range 4095 downto 0;
	begin
    	
		
		
		
		v := r;
    	
    	---Next dot descision logic
		--takes care about PIX.NEXT_DOT
		--@TODO in weiterer Folge in CCD-Handler verschieben
		case r.state is
			when wait_frame_valid =>
				--ROW sensitive
				if r.toggle_r = '0' then
					vpix_next_dot := read_dot_g1;
				else
					vpix_next_dot := read_dot_b;
				end if;
			when read_dot_r =>
				if r.p_c < CAM_W-1 then
					vpix_next_dot := read_dot_g1;
				else
					--eol1 condition
					vpix_next_dot := next_line;
				end if;
			when read_dot_g1 =>
				vpix_next_dot := read_dot_r;
			when read_dot_g2 =>
				if r.p_c < CAM_W-1 then
					vpix_next_dot := read_dot_b;
				else
					--eol2 condition
					vpix_next_dot := next_line;
				end if;
			when read_dot_b =>
				vpix_next_dot := read_dot_g2;
				--eol condition
			when others => 
				if r.p_c > 0 and cm_lval = '0' then
					vpix_next_dot := next_line;
				end if;
				vpix_next_dot := read_dot_g1;
		end case;
		
		------------------------
		---	CCD Handler - FALLING EDGE PIXCLK sensitiv
		--- state_pixsync_cam_type
		------------------------
		case r.state is
			when reset =>
				v.state := wait_getframe;
			when wait_getframe =>
				if enable = '1' then
					v.state := wait_frame_invalid;
				end if;
			when wait_frame_valid =>
				if cm_fval = '1' then
					if cm_lval = '1' then
						v.state := vpix_next_dot;
					end if;
				end if;
			when read_dot_r =>
				-- r logic
				--v.pixel(23 downto 16) := cm_d(11 downto 4);
				--v.pixel(23 downto 16) := cm_d(7 downto 0); -- test
				v.state := vpix_next_dot;
			when read_dot_g1 | read_dot_g2 =>
				-- g1 logic
				--v.pixel(15 downto 8) := cm_d(11 downto 4);
				--v.pixel(15 downto 8) := cm_d(7 downto 0); -- test
				v.state := vpix_next_dot;
			when read_dot_b =>
				-- b logic
				--v.pixel(7 downto 0) := cm_d(11 downto 4);
				--v.pixel(7 downto 0) := cm_d(7 downto 0); -- test
				v.state := vpix_next_dot;
			when next_line =>
				if r.p_r < CAM_H-1 then	
					v.state := wait_frame_valid;
				else
					--ganzes Bild gelesen
					v.state := wait_frame_invalid;
				end if;
			when wait_frame_invalid =>
				if cm_lval = '0' and cm_fval = '0' then
					v.state := wait_frame_valid;
				end if;
		end case;
		
		---logic: row & column counter
		---logic: pixel_valid
		--takes care about PIX: p_c, p_r, toggle_c and toggle_r
		case r.state is
			when reset =>
				null;
			when wait_getframe =>
				null;
			when wait_frame_valid =>
				null;
			when read_dot_r | read_dot_g1 | read_dot_g2 | read_dot_b =>
				v.p_c := r.p_c + 1;
				v.toggle_c := not r.toggle_c;
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
			when others =>
				null;
		end case;
		
		
		cm_trigger <= '0';
    	cm_reset <= rst;
    	r_next <= v;
    end process;
    

	------------------------
	---	Sync Daten übernehmen
	------------------------
    reg : process(clk)
	begin
		if rising_edge(clk) then
			if rst = RST_ACT then
				r.state <= reset;
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;

