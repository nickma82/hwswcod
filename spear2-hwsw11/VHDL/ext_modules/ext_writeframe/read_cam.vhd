-----------------------------------------------------------------------------
-- Entity:      read_cam
-- Author:      Johannes Kasberger
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
		frame_ready : out std_logic;
		
		cm_d		: in std_logic_vector(11 downto 0); --pixel data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic 	--Snapshot strobe
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
	end record;


	signal r_next : reg_type;
	signal r : reg_type := 
	(
		state	 => reset,
		next_dot => reset,
		toggle_r => '0',
		toggle_c => '0'
	);
	
begin
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r,enable,cm_d,cm_lval,cm_fval,rst)
	variable v 		: reg_type;
	begin
    	v := r;
    	
    	
    	------------------------
		---	CCD Handler - FALLING EDGE PIXCLK sensitiv
		--- state_pixsync_cam_type
		-- reset, wait_frame_valid, wait_getframe, read_dot_r, read_dot_g1, read_dot_g2, read_dot_b, next_line, wait_frame_invalid
		------------------------
		-- @TODO: p_r und p_c in pix VERSCHIEBEN!!!!!!
		--case pix.state is
		--	when reset =>
		--		vpix.state := wait_getframe;
		--		--@TODO ev. schon zu syncen beginnen
		--	when wait_getframe =>
		--		if r.getframe = '1' then
		--			vpix.state := wait_frame_invalid;
		--			vpix.toggle_r	:= '0';
		--		end if;
		--	when wait_frame_valid =>
		--		if cm_fval = '1' then
		--			vpix.toggle_c	:= '0';
		--			v.p_r := 0;
		--			if cm_lval = '1' then
		--				vpix.state := pix.next_dot;
		--			end if;
		--		end if;
		--	when read_dot_r =>
		--		-- r logic
		--		v.color := (others => '0');
		--		v.color(23 downto 16) := (others => '1');
		--		v.send_px := '1';
		--		vpix.state := pix.next_dot;
		--	when read_dot_g1 =>
		--		-- g1 logic
		--		v.color := (others => '0');
		--		v.color(15 downto 8) := (others => '1');
		--		v.send_px := '1';
		--	when read_dot_g2 =>
		--		-- g2 logic
		--		vpix.state := pix.next_dot;
		--	when read_dot_b =>
		--		-- b logic
		--		vpix.state := pix.next_dot;
		--	when next_line =>
		--		if r.p_r < CAM_H-1 then	
		--		-- @TODO: Wann ist das Bild fertig übertragen?? (letzte Zeile)
		--		-- Wenn Fertig, in wait getfram springen??
		--			v.p_r := r.p_r + 1;
		--			vpix.state := wait_frame_valid;
		--			vpix.toggle_r := not pix.toggle_r;
		--		else
		--			vpix.state := wait_frame_invalid;
		--		end if;
		--	when wait_frame_invalid =>
		--		if cm_lval = '0' and cm_fval = '0' then
		--			vpix.state := wait_frame_valid;
		--		end if;
		--end case;
		--
		-----Next dot descision logic
		--case pix.state is
		--	when others => 
		--		if r.p_c > 0 and cm_lval = '0' then
		--			vpix.next_dot := next_line;
		--		end if;
		--		vpix.next_dot := read_dot_r;
		--end case;
		--
		--
		-----das folgende gehört in den CCD Handler rein
		--if r.cam_state = read_line and cm_lval = '1' and r.p_c < CAM_W-1 then
		--	v.p_c := r.p_c + 1;
		--	vpix.toggle_c := not pix.toggle_c;
		--	if r.address <= FRAMEBUFFER_END_ADR and falling_edge(cm_pixclk) then
		--		v.address := r.address + 4;
		--	else
		--		v.address := FRAMEBUFFER_BASE_ADR;
		--	end if;
		--else
		--	v.p_c := 0;
		--	v.address := FRAMEBUFFER_BASE_ADR;
		--end if;
    	
		cm_trigger <= '0';
		frame_ready <= '0';
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
