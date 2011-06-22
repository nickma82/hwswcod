-----------------------------------------------------------------------------
-- Entity:      read_cam
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Bilder von der Kamera einlesen und in ein Ram speichern
--				Reagiert auf Line Valid und Frame Valid der Kamera um State zu bestimmen
--				Immer zwei ganze Zeilen werden gespeichert (jeweils ein RAM für gerade und ungerade Zeilen). 
--				Wenn Zeile vollständig wird Konvertierung gestartet
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
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic; 	--Snapshot strobe
		
		wr_en_odd	: out std_logic;                     -- ungerade zeile schreiben
		wr_en_even	: out std_logic;                     -- gerade zeile schreiben
		wr_data		: out dot_type;                      -- bayer daten
		wr_address	: out dot_addr_type;                 -- spalte der daten
		led_red		: out std_logic_vector(5 downto 0);  -- debug leds
		frame_stop	: out std_logic                      -- frame ist vorbei
    );
end ;

architecture rtl of read_raw is


	type readraw_reg_type is record
		--intern
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
		last_fval	: std_logic;
		last_lval	: std_logic;
	end record;


	signal r_next : readraw_reg_type;
	signal r : readraw_reg_type := 
	(
		running		=> '0',
		start		=> '0',
		toggle_r	=> '0',
		p_r 		=> 0,
		p_c 		=> 0,
		
		en_odd		=> '0',
		en_even		=> '0',
		data		=> (others => '0'),
		address		=> (others => '0'),
		conv_line_rdy	=> '0',
		last_fval	=> '0',
		last_lval	=> '0'
	);	
begin
	read_raw : process(r, getframe, cm_d, cm_lval, cm_fval, rst)
	variable v 				: readraw_reg_type;
	begin
		v := r;
    	
    	v.en_odd := '0'; --disable every cycle
    	v.en_even := '0'; --disable every cycle
    	frame_stop <= '0';
    	led_red <= (others => '0');
		------------------------
		---	CCD Handler - RISING EDGE PIXCLK sensitiv (inverted pixclk setting)
		--- state_pixsync_cam_type
		------------------------
		
		if cm_fval ='1' and cm_lval = '1' then
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
			
			-- am ende der Zeile kann konvertierung gestartet werden
			if r.p_c = CAM_W-20 then
				v.conv_line_rdy := '1';
				
			-- nach ein paar takten signal wieder auf '0'
			elsif r.p_c = CAM_W-10 then
				v.conv_line_rdy := '0';
			end if;
			
			-- daten übernehmen von kamera
			v.data := cm_d(11 downto 4);
			
			v.address := std_logic_vector(to_unsigned(r.p_c, DOT_ADDR_WIDTH));
			
			if r.running = '1' then
				v.start := '0';
			end if;
			
			led_red(0) <= '1';
		-- neue zeile
		elsif cm_fval = '1' and cm_lval = '0' then
			-- nach line valid zeile toggeln
			if r.last_lval = '1' then
				v.toggle_r := not r.toggle_r;
				
				if r.p_r < CAM_H-1 then
					v.p_r := r.p_r + 1;
				else
					v.p_r := 0;
				end if;
				
				v.p_c := 0;	
				v.address := (others=>'0');	
			end if;
			led_red(1) <= '1';
		-- zwischen zwei frames
		elsif cm_fval = '0' and cm_lval = '0' then
			v.p_r 		:=  0;
			v.p_c 		:=  0;
			v.toggle_r	:= '0';
			v.conv_line_rdy := '0';
			v.address	:= (others => '0');
			v.data		:= (others => '0');
			
			frame_stop <= '1';
		
			-- nur direkt nach frame aktion ausführen
			if r.last_fval = '1' then
				v.running := '0';
			else
				if r.start = '1' then
					v.running := '1';
				end if;
			end if;
			
			led_red(2) <= '1';
		else
			led_red(3) <= '1';
		end if;
		
		
		-- running übernehmen
		if getframe = '1' then
			v.start := '1';
		end if;		
		
		-- an ram übergeben
		wr_data		<= r.data;
		wr_address	<= r.address; 
		
		-- daten nur übernehmen wenn gerade ein bild gecaptured werden soll
		wr_en_odd	<= r.en_odd and r.running;
		wr_en_even	<= r.en_even and r.running;
		line_ready	<= r.conv_line_rdy and r.running;
			
		led_red(4) <= r.running;
		led_red(5) <= r.start;
				
		cm_trigger <= '0';

    	v.last_lval := cm_lval;
    	v.last_fval := cm_fval;
    	
    	r_next <= v;
    end process;
    

	------------------------
	---	Sync Daten übernehmen
	------------------------
    read_raw_reg : process(cm_pixclk)
	begin
		if rising_edge(cm_pixclk) then
			if rst = RST_ACT then
				r.p_r 		<=  0;
				r.toggle_r	<= '0';
				r.p_c 		<=  0;
				r.start		<= '0';
				r.running	<= '0';
				r.conv_line_rdy <= '0';
				r.en_odd	<= '0';
				r.en_even	<= '0';
				r.address	<= (others => '0');
				r.data		<= (others => '0');
				r.last_lval  <= '0';
				r.last_fval	<= '0';
			else
				r <= r_next;
			end if;
		end if;
	end process;
end;

