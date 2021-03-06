-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger, Nick Mayerhofer
-- Description: Ein Bild über AHB in Framebuffer übertragen
-- Date:		15.05.2011
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

entity writeframe is
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
end ;

architecture rtl of writeframe is
	
  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	type state_type is (idle, data, done, reset, start_next_burst);
	
	type reg_type is record
  		start				: std_logic;                                -- Für AHB
		address				: std_logic_vector(31 downto 0);            -- Für AHB
		wdata				: std_logic_vector(31 downto 0);            -- Für AHB
		state				: state_type;                               -- Statemachine
		cur_col				: natural range 0 to SCREEN_W-1;            -- Spalte
		cur_line			: natural range 0 to SCREEN_H-1;            -- Zeile
		burst_count			: natural range 0 to BURST_PER_FRAME_COUNT; -- Wie viele Bursts können gestartet werden
		burst_done_count	: natural range 0 to BURST_PER_FRAME_COUNT; -- Wie viele Bursts sind fertig
		frame_done			: std_logic;                                -- Bild ist fertig übertragen
		return_pgm			: std_logic;                                -- Programm kann weiter arbeiten
		rd_pointer			: pix_addr_type;                            -- Adresse von der gelesen wird
		clear_running		: std_logic;                                -- Bildschirm wird gelöscht
		frame_stop			: std_logic;                                -- Bild von seiten der Kamera fertig übertragen
	end record;

	
	signal r_next : reg_type;
	signal r : reg_type := 
	(
		start			=> '0',
		address 		=> (others => '0'),
		wdata  			=> (others => '0'),
		state			=> reset,
		cur_col			=> 0,
		cur_line		=> 0,
		burst_count 	=> 0,
		burst_done_count=> 0,
		frame_done 		=> '0',
		return_pgm		=> '0',
		clear_running	=> '0',
		rd_pointer		=> (others => '0'),
		frame_stop		=> '0'
	);
				
begin

	------------------------
	---	ASync Daten Statelogic, Daten bursten
	------------------------
	comb : process(r,next_burst,dmao, rst,rd_data_burst,clear_screen,frame_stop,tx,ty,bx,by)
	variable v 		: reg_type;
	variable tmp	: std_logic_vector(9 downto 0);
	begin
    	v := r;   	
    	
    	v.frame_done := '0';
    	v.return_pgm := '0';
    	clear_done <= '0';
    	
    	led_red(5 downto 0) <= (others=>'0');  	
		------------------
		--- Statemachine
		------------------
		case r.state is
			when reset =>
				v.state := idle;
				v.cur_line := 0;
				v.cur_col  := 0;
				v.burst_count := 0;
				v.burst_done_count := 0;
				v.clear_running := '0';
			when idle =>
				v.address := FRAMEBUFFER_BASE_ADR;
				
				-- sicherstellen, dass 0 tes element anliegt sobald verarbeitung startet
				v.rd_pointer := (others => '0');
				
				if next_burst = '1' or r.clear_running = '1' then
					v.state := data;					
					
					-- addresse gleich auf 1 stellen um im nächsten zyklus die richtige addresse anzulegen
					-- v.rd_pointer := (0 => '1', others => '0');
				end if;
				led_red(0) <= '1';
			when data =>
				if r.start = '0' then
					v.start := '1';
				end if;
				if dmao.ready = '1' then
					if dmao.haddr = (9 downto 0 => '0') then
						v.address := (v.address(31 downto 10) + 1) & dmao.haddr;
					else
						v.address := v.address(31 downto 10) & dmao.haddr;
					end if;

					if (dmao.haddr(BURST_LENGTH+1 downto 0) = ((BURST_LENGTH+1 downto 2 => '1') & "00")) then 
						v.start := '0';
						v.state := start_next_burst;
						v.burst_done_count := r.burst_done_count + 1;
					end if;
					
					-- zeile noch nicht fertig
					if r.cur_col < SCREEN_W-1 then
						v.cur_col := r.cur_col + 1;
					-- wenn zeile fertig
					else
						-- und bildschirm voll aufhören
						if r.cur_line = SCREEN_H-1 then
							v.state := done;
						-- ansonsten nächste zeile
						else
							v.cur_line := r.cur_line + 1;
							v.cur_col := 0;
						end if;							
					end if;
					
					-- wenn letztes element gelesen wieder bei 0 anfangen
					if r.rd_pointer = BURST_RAM_END_ADR then
						v.rd_pointer := (others=> '0');
					else
						-- pointer auf nächsten pixel erhöhen
						v.rd_pointer := r.rd_pointer + 1;
					end if;
					
					
				end if;		
				
				led_red(1) <= '1';
			when start_next_burst =>	
				-- wenn ein burst noch nicht abgebareitet ist => nächsten starten
				if r.burst_count > r.burst_done_count then
					v.state := data;
				else
					-- wenn fertig übertragen
					if r.cur_line = SCREEN_H-1 and r.cur_col = SCREEN_W-1 then
						v.state := done;
					end if;
				end if;
				led_red(2) <= '1';
			when done =>
				v.cur_line := 0;
				v.cur_col  := 0;
				v.burst_count := 0;
				v.burst_done_count := 0;
				v.frame_done := '1';
				v.return_pgm := '1';
				v.start := '0';
				v.state := idle;
				clear_done <= '1';
				v.clear_running := '0';
				led_red(3) <= '1';
		end case;		

		-- neue burts zählen
		if next_burst = '1' then
			v.burst_count := r.burst_count + 1;
			--assert (v.burst_count-r.burst_done_count) < 100	report "Burst Counter Overflow" severity error;
		end if;
		
		
		-- ein burst über ganzen screen starten
    	if clear_screen = '1' and r.clear_running = '0' then
    		v.clear_running := '1';
    		v.burst_count := BURST_PER_FRAME_COUNT;
    	end if;
		
		-- wenn clear screen muster ausgeben
		if r.clear_running = '1' then
			-- gerade
			tmp := std_logic_vector(to_unsigned(r.cur_line,10));
			if tmp(0) = '0' then
				v.wdata := "00000000111111110000000000000000";
			-- ungerade
			else
				v.wdata := "00000000000000000000000011111111";
			end if;
		else
			-- rahmen ausgeben
			if 	((r.cur_line = ty or r.cur_line = by) and (r.cur_col >= tx and r.cur_col < bx)) or
				((r.cur_col = tx or r.cur_col = bx) and (r.cur_line >= ty and r.cur_line < by)) then
				v.wdata := "00000000000000001111111100000000";
			-- sonst daten vom ram ausgeben
			else
				v.wdata := "00000000" & rd_data_burst;
			end if;
		end if;
		
		-- Werte auf Interface zu Bus legen
		dmai.wdata  <=  v.wdata;
	    dmai.burst  <= '1';
	    dmai.irq    <= '0';
	    dmai.size   <= "10";
	    dmai.write  <= '1';
	    dmai.busy   <= '0';
	    dmai.start    <= r.start;
	    dmai.address  <= r.address;  
	    
	    frame_done <= r.frame_done;
	    return_pgm <= r.return_pgm;
	    
	    rd_address_burst <= r.rd_pointer;
	   
	    led_red(4) <= r.frame_done;
	    led_red(5) <= r.clear_running;
	    
	    if frame_stop = '1' then
	    	v.frame_stop := '1';
	    end if;
	    
	    -- abbruch wenn keine daten von kamera mehr zu erwarten sind
	    if r.state /= idle and r.state /= done and r.frame_stop = '1' and r.clear_running = '0' and r.burst_count = r.burst_done_count then
	    	v.frame_stop := '0';
			v.state := done;
		end if;
		
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
end ;

