-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger
-- Description: Ein Bild in Framebuffer übertragen
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
		ahbi    			: in  ahb_mst_in_type;
		ahbo    			: out ahb_mst_out_type;
		next_burst			: in std_logic;
		frame_done			: out std_logic;
		return_pgm			: out std_logic;
		rd_address_burst	: out pix_addr_type;
		rd_data_burst		: in pix_type
    );
end ;

architecture rtl of writeframe is
	-- AMBA Signale 
	signal dmai               : ahb_dma_in_type;
	signal dmao               : ahb_dma_out_type;
  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;

	type state_type is (idle, data, done, reset, start_next_burst);
	
	type reg_type is record
  		start		: std_logic;
		address		: std_logic_vector(31 downto 0);
		wdata		: std_logic_vector(31 downto 0);
		state		: state_type;
		cur_col		: natural range 0 to SCREEN_W;
		cur_line	: natural range 0 to CAM_H;
		burst_count	: natural range 0 to BURST_BUFFER_LENGTH;
		frame_done	: std_logic;
		rd_pointer	: pix_addr_type;
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
		frame_done 		=> '0',
		rd_pointer		=> (others => '0')
	);
				
begin
	
	------------------------
	---	AHB Master
	------------------------
	ahb_master : ahbmst generic map (1, 0, VENDOR_WIR, WIR_WRITEFRAME, 0, 3, 1)
	port map (rst, clk, dmai, dmao, ahbi, ahbo);
	
	
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r,next_burst,dmao, rst,rd_data_burst)
	variable v 		: reg_type;
	begin
    	v := r;   	

		------------------
		--- Statemachine
		------------------
		case r.state is
			when reset =>
				v.state := idle;
			when idle =>
				v.address := FRAMEBUFFER_BASE_ADR;
				v.cur_line := 0;
				v.cur_col  := 0;
				v.burst_count := 0;
				
				-- sicherstellen, dass 0 tes element anliegt sobald verarbeitung startet
				v.rd_pointer := (others => '0');
				
				if next_burst = '1' then
					v.state := data;
					v.start := '1';	
					v.frame_done := '0';
					v.burst_count := 1;
					-- addresse gleich auf 1 stellen um im nächsten zyklus die richtige addresse anzulegen
					v.rd_pointer := (0 => '1', others => '0');
				end if;
				
			when data =>
				--v.wdata := 
				if dmao.ready = '1' then
					if dmao.haddr = (9 downto 0 => '0') then
						v.address := (v.address(31 downto 10) + 1) & dmao.haddr;
					else
						v.address := v.address(31 downto 10) & dmao.haddr;
					end if;

					if (dmao.haddr(BURST_LENGTH+1 downto 0) = ((BURST_LENGTH+1 downto 2 => '1') & "00")) then 
						v.start := '0';
						v.state := start_next_burst;
						v.burst_count := v.burst_count - 1;
					else
						if r.cur_col >= SCREEN_W then
							if r.cur_line >= CAM_H then
								v.state := done;
							else
								v.cur_line := r.cur_line + 1;
								v.cur_col := 0;
							end if;
						else
							v.cur_col := r.cur_col + 1;
						end if;
					end if;
					
					-- pointer immer auf nächsten pixel erhöhen
					v.rd_pointer := r.rd_pointer + 1;
					
					-- wenn letztes element gelesen wieder bei 0 anfangen
					if v.rd_pointer = BURST_RAM_END_ADR then
						v.rd_pointer := (others=> '0');
					end if;
				end if;
			when start_next_burst =>
				if r.burst_count > 0 then
					v.start := '1';
					v.state := data;
				end if;
			when done =>
				v.frame_done := '1';
				v.start := '0';
				v.state := idle;

		end case;		

		-- neue burts zählen
		if next_burst = '1' then
			v.burst_count := v.burst_count + 1;
		end if;
		
		-- Werte auf Interface zu Bus legen
		dmai.wdata  <=  "00000000" & rd_data_burst; --("000000001111111100000000");
	    dmai.burst  <= '1';
	    dmai.irq    <= '0';
	    dmai.size   <= "10";
	    dmai.write  <= '1';
	    dmai.busy   <= '0';
	    dmai.start    <= r.start;
	    dmai.address  <= r.address;  
	    
	    frame_done <= r.frame_done;
	    return_pgm <= '0';
	    
	    rd_address_burst <= r.rd_pointer;
	    
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

