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
	type state_type is (reset, wait_frame_valid,wait_frame_invalid, read_dot, done);
	 
	type readraw_reg_type is record
		--intern
		state		: state_type;
		toggle_r	: std_logic;
		p_r      	: natural range 0 to CAM_H-1;
		p_c      	: natural range 0 to CAM_W-1;
		running		: std_logic;
		start		: std_logic;
		--rams
		en_odd		: std_logic;
		en_even		: std_logic;
		data		: dot_type;
		address		: dot_addr_type;
		--cam
		conv_line_rdy:std_logic;
	end record;


	signal r_next : readraw_reg_type;
	signal r : readraw_reg_type := 
	(
		state		=> reset,
		running		=> '0',
		start		=> '0',
		toggle_r	=> '0',
		p_r 		=> 0,
		p_c 		=> 0,
		
		en_odd		=> '0',
		en_even		=> '0',
		data		=> (others => '0'),
		address		=> (others => '0'),
		conv_line_rdy	=> '0'
	);	
begin
	read_raw : process(r, getframe, cm_d, cm_lval, cm_fval, rst)
	variable v 				: readraw_reg_type;
	begin
		v := r;
    	
    	v.en_odd := '0'; --disable every cycle
    	v.en_even := '0'; --disable every cycle
    	
		------------------------
		---	CCD Handler - RISING EDGE PIXCLK sensitiv (inverted pixclk setting)
		--- state_pixsync_cam_type
		------------------------
		case r.state is
			when reset =>
				v.state := wait_frame_invalid;
				v.p_r 		:=  0;
				v.toggle_r	:= '0';
				v.p_c 		:=  0;
				v.start		:= '0';
				v.running	:= '0';
				
			when wait_frame_invalid =>
				if cm_lval = '0' and cm_fval = '0' then
					v.state := wait_frame_valid;
				end if;
				
			when wait_frame_valid =>
				if cm_fval = '1' then
					v.running := r.start; -- übertragung nur mit neuen bild starten
					v.state := read_dot;
				end if;
			when read_dot =>
				if cm_lval = '1' then
					-- nur wenn zeile noch nicht fertig
					if r.p_c < CAM_W-1 then
						v.p_c := r.p_c + 1;
					end if;
					
					-- aktiven ram festlegen
					if r.toggle_r = '0' then
						v.en_even := '1';
					else
						v.en_odd := '1';
					end if;
					
					-- nach ersten pixel kann konvertierung gestartet werden
					-- nach 4. pixel wieder abschalten
					if r.p_c = 1 then
						v.conv_line_rdy := '1';
					elsif r.p_c = 4 then
						v.conv_line_rdy := '0';
					end if;
				end if;
				
				if r.p_c = CAM_W-1 then
					if r.p_r = CAM_H-1 then
						v.state := done;
					else
						v.toggle_r := not r.toggle_r;
						v.p_r := r.p_r + 1;
						v.p_c := 0;	
						v.address := (others=>'0');					
					end if;
				end if;
				
			when done =>
				v.p_r 		:=  0;
				v.toggle_r	:= '0';
				v.p_c 		:=  0;
				v.start		:= '0';
				v.running	:= '0';
				v.address	:= (others=>'0');
		end case;
		
		-- running übernehmen
		if getframe = '1' then
			v.start := '1';
		end if;
		
		-- daten übernehmen
		v.data := cm_d(11 downto 4);
		v.address := std_logic_vector(to_unsigned(r.p_c, DOT_ADDR_WIDTH));
		
		-- an ram übergeben
		wr_data		<= r.data;
		wr_address	<= r.address; --@TODO Grenzen der Counter angleichen
		
		-- daten nur übernehmen wenn gerade ein bild gecaptured werden soll
		wr_en_odd	<= r.en_odd and r.running;
		wr_en_even	<= r.en_even and r.running;

		line_ready	<= r.conv_line_rdy and r.running;

		
		cm_trigger <= '0';
    	cm_reset <= rst;

    	r_next <= v;
    end process;
    

	------------------------
	---	Sync Daten übernehmen
	------------------------
    read_raw_reg : process(cm_pixclk)
	begin
		if rising_edge(cm_pixclk) then
			if rst = RST_ACT then
				r.state <= reset;
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;

