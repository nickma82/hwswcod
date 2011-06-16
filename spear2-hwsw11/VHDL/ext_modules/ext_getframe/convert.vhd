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
		line_ready			: in  std_logic;
		next_burst			: out std_logic;

		rd_address			: out dot_addr_type;
		rd_data_even		: in  dot_type;
		rd_data_odd			: in  dot_type;
		            		
		wr_en_burst			: out std_logic;
		wr_address_burst	: out pix_addr_type;
		frame_stop			: in std_logic;
		wr_data_burst		: out pix_type;
		led_red				: out 	std_logic_vector(5 downto 0)
    );
end ;

architecture rtl of convert is
	type state_type is (reset, wait_line_ready, convert_line, line_done, frame_done);
	type dot_state_type is (p_g1, p_g2, p_b, p_r);
	 
	type reg_type is record
		state		: state_type;
		dot_state	: dot_state_type;
		
		toggle_r	: std_logic;
		col_cnt    	: natural range 0 to SCREEN_W;
		row_cnt    	: natural range 0 to SCREEN_H-1;
				
		rd_address	: dot_addr_type;
		
		wr_enable	: std_logic;
		pixel_data	: pix_type;
		last_dot	: dot_type;
		pixel_addr	: pix_addr_type;
		b_cnt		: natural range 0 to BURST_PIXEL_COUNT-1;
		next_burst	: std_logic;
	end record;


	signal r_next : reg_type;
	signal r : reg_type := 
	(
		state		=> reset,
		dot_state	=> p_g1,
		toggle_r	=> '0',
		col_cnt		=> 0,
		row_cnt		=> 0,
			
		rd_address	=> (others => '0'),
		
		wr_enable	=> '0',
		pixel_data	=> (others => '0'),
		last_dot		=> (others => '0'),
		pixel_addr	=> (others => '0'),
		b_cnt		=> 0,
		next_burst	=> '0'
	);
begin
read_raw : process(r, line_ready, rst, rd_data_even, rd_data_odd, frame_stop)
	variable v 	: reg_type;
	variable cur_dot,other_dot : dot_type;
	begin
		v := r;
		v.next_burst := '0';
		
		if r.toggle_r = '0' then
			cur_dot := rd_data_even;
			other_dot := rd_data_odd;
		else
			cur_dot := rd_data_odd;
			other_dot := rd_data_even;
		end if;
		
		led_red(5 downto 0) <= (others=>'0'); 
		
    	---Next dot descision logic
		if r.state = convert_line then
			if r.toggle_r = '1' then
				case r.dot_state is
					when p_g1 =>
						v.dot_state := p_r;
					when p_r =>
						v.dot_state := p_g1;
					when others =>
						null;
				end case;
			else
				case r.dot_state is
					when p_b =>
						v.dot_state := p_g2;
					when p_g2 =>
						v.dot_state := p_b;
					when others =>
						null;
				end case;
			end if;
		end if;
		
		case r.state is
			when reset =>
				v.state := wait_line_ready;
				v.row_cnt := 0;
				v.col_cnt := 0;
				v.wr_enable := '0';
				v.pixel_addr := (others=>'0');
				v.b_cnt := 0;
				v.toggle_r := '0';
				
			when wait_line_ready =>	
				if line_ready = '1' then 
					v.state := convert_line;
					if r.toggle_r = '1' then
						v.dot_state := p_g1;
					else
						v.dot_state := p_b;
					end if;
					if r.row_cnt = 0 then
						v.b_cnt := 1;
					end if;
					v.rd_address := r.rd_address + 1;					
				else
					v.rd_address := (others => '0');
				end if;
				led_red(0) <= '1';
			when convert_line =>
				-- bei rot muss blau der zeile darüber verwendet werden
				-- => bei g1 muss blau auf last dot gespeichert werden
				
				-- bei g1 muss rot der selben zeile verwenden werden
				-- bei r muss r als last dot gespeichert werden
				
				-- bei b muss rot der zeile darüber verwendet werden
				-- bei g2 muss rot als last dot gespeichert werden
				
				-- bei g2 muss blau der selben zeile verwendet werden
				-- bei b muss b als last dot gespeichert werden
				
				v.wr_enable := '1';
				
				case r.dot_state is
					when p_g1 =>
						v.last_dot := other_dot;
					when p_r =>
						v.last_dot := cur_dot;
					when p_b =>
						v.last_dot := cur_dot;
					when p_g2 =>
						v.last_dot := other_dot;
				end case;
				
				v.pixel_data := (others=>'0');
				
				case r.dot_state is
					when p_b =>
						--v.pixel_data := r.last_dot & other_dot  & cur_dot;
						v.pixel_data := "00000000" & "00000000"  & cur_dot;
					when p_g2 =>
						--v.pixel_data := other_dot & cur_dot & r.last_dot;
						v.pixel_data := "00000000" & cur_dot & "00000000";
					when p_g1 =>
						--v.pixel_data := r.last_dot & cur_dot & other_dot;
						v.pixel_data := "00000000" & cur_dot & "00000000";
					when p_r =>
						--v.pixel_data := cur_dot & other_dot & r.last_dot;
						v.pixel_data := cur_dot & "00000000" & "00000000";
				end case;
				
				
				if r.col_cnt = SCREEN_W then
					v.state := line_done;
				else
					v.col_cnt := r.col_cnt + 1;
					if v.col_cnt < CAM_W-1 then
						v.rd_address := r.rd_address + 1;
					else
						v.pixel_data := (others=>'0'); --schwarz
					end if;
				end if;			
				
				if r.pixel_addr = BURST_RAM_END_ADR then
					v.pixel_addr := (others=> '0'); 
				else
					if r.col_cnt > 0 then
						v.pixel_addr := r.pixel_addr + 1;
					end if;
				end if;
				
			
				if r.b_cnt = BURST_PIXEL_COUNT-1 then
					v.next_burst := '1';
					v.b_cnt := 0;
				else
					v.b_cnt := r.b_cnt + 1;
				end if;
				led_red(1) <= '1';
			when line_done => 
				
				v.col_cnt := 0;
				v.toggle_r := not r.toggle_r;
				v.wr_enable := '0';
				
				if r.row_cnt = SCREEN_H-1 then
					v.state := frame_done;
				else
					v.state := wait_line_ready;
					v.row_cnt := r.row_cnt + 1;
				end if;
				led_red(2) <= '1';
			when frame_done =>
				v.row_cnt := 0;
				v.col_cnt := 0;
				v.toggle_r := '0';
				v.rd_address := (others=>'0');
				v.pixel_addr := (others=>'0');
				v.b_cnt := 0;
				v.state := wait_line_ready;
				--v.next_burst := '1';
				led_red(3) <= '1';
		end case;
			
		rd_address <= r.rd_address;
		
		wr_en_burst <= r.wr_enable;
		wr_address_burst <= r.pixel_addr;
		wr_data_burst <= r.pixel_data;
		next_burst <= r.next_burst;
		
		led_red(4) <= frame_stop;
		
		if frame_stop = '1' then
			v.state := frame_done;
		end if;
		
    	r_next <= v;
    end process;
    

	------------------------
	---	Sync Daten übernehmen
	------------------------
    read_raw_reg : process(clk)
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
