-----------------------------------------------------------------------------
-- Entity:      getframe
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

entity ext_getframe is
	port (
		clk       : in  std_logic;
		extsel    : in  std_ulogic;
		exti      : in  module_in_type;
		exto      : out module_out_type;
		dmai      : out  ahb_dma_in_type;
		dmao      : in ahb_dma_out_type;
		
		cm_d		: in std_logic_vector(11 downto 0); --pixel data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic; 	--Snapshot strobe
		led_red		: out 	std_logic_vector(17 downto 0)
    );
end ;

architecture rtl of ext_getframe is  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;
	
	type reg_type is record
  		ifacereg	: register_set;
		getframe	: std_logic;
		frame_done	: std_logic;
		return_pgm	: std_logic;
		wait_gf		: natural range 0 to 10;
		clear_screen: std_logic;
		clear_done: std_logic;
	end record;
	
	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg 	=> (others => (others => '0')),
		getframe 	=> '0',
		frame_done	=> '0',
		return_pgm	=> '0',
		wait_gf		=> 0,
		clear_screen=> '0',
		clear_done	=> '0'
	);
	
	signal rstint : std_ulogic;
	
	signal wr_en_odd,wr_en_even,wr_en_burst : std_logic;
	
	signal wr_address : dot_addr_type;
	signal rd_address : dot_addr_type;
	
	signal rd_data_even, rd_data_odd, wr_data : dot_type;
	
	signal wr_address_burst, rd_address_burst : pix_addr_type;
	signal wr_data_burst, rd_data_burst : pix_type;
	
	signal getframe	  : std_logic;
	signal line_ready : std_logic;
	signal next_burst : std_logic;
	signal frame_done : std_logic;
	signal return_pgm : std_logic;
	
	signal int_clear_screen, clear_done, frame_stop	:std_logic;
	
	signal pix_count : std_logic_vector(19 downto 0);
begin
	
	------------------------
	---	RAMs
	------------------------
	ram_odd_raw : dp_ram
		generic map (
			ADDR_WIDTH 	=> DOT_ADDR_WIDTH,
			DATA_WIDTH	=> DOT_WIDTH
		)
		port map (
			wrclk       => cm_pixclk,
			wen			=> wr_en_odd,
			wraddress 	=> wr_address,
			wrdata_in 	=> wr_data,
			
			rdclk		=> clk,
			rdaddress 	=> rd_address,
			rddata_out 	=> rd_data_odd
		);
	
	ram_even_raw : dp_ram
		generic map (
			ADDR_WIDTH 	=> DOT_ADDR_WIDTH,
			DATA_WIDTH	=> DOT_WIDTH
		)
		port map (
			wrclk       => cm_pixclk,
			wen			=> wr_en_even,
			wraddress 	=> wr_address,
			wrdata_in 	=> wr_data,
			
			rdclk		=> clk,
			rdaddress 	=> rd_address,
			rddata_out 	=> rd_data_even
		);	
		
	ram_burst	: dp_ram
		generic map (
			ADDR_WIDTH 	=> PIXEL_ADDR_WIDTH, 
			DATA_WIDTH	=> PIXEL_WIDTH
		)
		port map (
			wrclk       => clk,
			wen			=> wr_en_burst,
			wraddress 	=> wr_address_burst,
			wrdata_in 	=> wr_data_burst,
			               
			rdclk		=> clk,
			rdaddress 	=> rd_address_burst,
			rddata_out 	=> rd_data_burst
		);
	------------------------
	---	Lesen von Bildern Einheit anlegen
	------------------------
	read_raw_unit : read_raw
      port map (
		clk		=> clk,	
		rst 	=> rstint,
		getframe	=> getframe,
		
		line_ready	=> line_ready,
		
		cm_d 	=> cm_d,
		cm_lval => cm_lval,
		cm_fval => cm_fval,
		cm_pixclk	=> cm_pixclk,
		cm_reset	=> cm_reset,
		cm_trigger	=> cm_trigger,
		cm_strobe 	=> cm_strobe,
			
		wr_en_odd	=>  wr_en_odd,	
		wr_en_even	=>  wr_en_even,
		wr_data		=>  wr_data,		
		wr_address	=>  wr_address,
		frame_stop	=> frame_stop,
		led_red		=> led_red(17 downto 12),
		last_px_cnt => pix_count
    );
    
    convert_unit : convert
    port map (
    	clk       		 =>  clk,
		rst				 =>  rstint, 	
		line_ready		 =>  line_ready,
		next_burst		 =>  next_burst,
		rd_address		 =>  rd_address,
		rd_data_even	 =>  rd_data_even,
		rd_data_odd		 =>  rd_data_odd,
		wr_en_burst		 =>  wr_en_burst, 
		wr_address_burst =>  wr_address_burst, 
		wr_data_burst	 =>  wr_data_burst,
		frame_stop		=> frame_stop
	);
	
	writeframe_unit : writeframe
	port map (
		clk     		 => clk,     		
		rst    			 => rstint,    			
		dmai    		 => dmai,
		dmao    		 => dmao, 		
		next_burst		 => next_burst,		
		frame_done		 => frame_done,	
		return_pgm		 => return_pgm,
		rd_address_burst => rd_address_burst,
		rd_data_burst	 => rd_data_burst,
		clear_screen	 => int_clear_screen,
		clear_done		 => clear_done,
		frame_stop		=> frame_stop,
		led_red			 => led_red(11 downto 0)
	);
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, exti, extsel, rstint,frame_done,return_pgm,line_ready, next_burst,clear_done,pix_count)
	variable v 		: reg_type;
	begin
    	v := r;
    	   	
    	--schreiben
    	if ((extsel = '1') and (exti.write_en = '1')) then
    		case exti.addr(4 downto 2) is
				-- byte 0 => status&config word
    			when "000" =>
					-- wenn byte 0 oder 1 dann interrupt anfordern? und int_ack zurück setzten
    				if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
    					v.ifacereg(STATUSREG)(STA_INT) := '1';
    					v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
    				else
						-- config byte schreiben
    					if ((exti.byte_en(2) = '1')) then
    						v.ifacereg(2) := exti.data(23 downto 16);
    					end if;
						-- ?
    					if ((exti.byte_en(3) = '1')) then
    						v.ifacereg(3) := exti.data(31 downto 24);
    					end if;
    				end if;
				-- commando word => bit 0 übernehmen
    			when "001" =>
    				if ((exti.byte_en(0) = '1')) then
    					v.getframe := '1';
						v.wait_gf := 0;
    					v.return_pgm := '0';
    					v.frame_done := '0';
    				end if;
    			when "011" =>
    				v.clear_screen := '1';
    				v.clear_done := '0';
   			when others =>
					null;
			end case;
		end if;

		--auslesen
		exto.data <= (others => '0');
		if ((extsel = '1') and (exti.write_en = '0')) then
			case exti.addr(4 downto 2) is
				when "000" =>
					exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
				when "001" =>
					if ((exti.byte_en(0) = '1')) then
    					exto.data(7 downto 0) <= (0 => r.getframe, others=>'0');
    				end if;
    				if ((exti.byte_en(1) = '1')) then
    					exto.data(15 downto 8) <= (8 => r.return_pgm, others=>'0');
    				end if;
    				if ((exti.byte_en(2) = '1')) then
    					exto.data(23 downto 16) <= (16 => r.frame_done, others=>'0');
    				end if;
    			when "010" =>
    				exto.data(19 downto 0) <= pix_count(19 downto 0);
    				exto.data(31 downto 20) <= (others =>'0');
    			when "011" =>
    				if ((exti.byte_en(0) = '1')) then
    					exto.data(7 downto 0) <= (0 => r.clear_done, others=>'0');
    				end if;
				when others =>
					null;
			end case;
		end if;
    	
    	--berechnen der neuen status flags
		v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
		v.ifacereg(STATUSREG)(STA_FSS)	:= '0';		-- failsafe
		v.ifacereg(STATUSREG)(STA_RESH) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_RESL) := '0';		-- ?
		v.ifacereg(STATUSREG)(STA_BUSY) := '0';		-- busy
		v.ifacereg(STATUSREG)(STA_ERR)	:= '0';		-- fehler
		v.ifacereg(STATUSREG)(STA_RDY)	:= '1';		-- immer bereit
		
		-- Output soll Defaultmassig auf eingeschalten sein
		v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';
				
		--soft- und hard-reset vereinen
		rstint <= not RST_ACT;
		if exti.reset = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
		  rstint <= RST_ACT;
		end if;
			
		-- Interrupt
		-- wenn interrupt von modul verlangt und noch nicht bestätigt
		if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) ='0' then
		  v.ifacereg(STATUSREG)(STA_INT) := '0';
		end if; 
		exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);

		if frame_done = '1' then
			v.frame_done := '1';
			v.return_pgm := '1';
		end if;
		
		if return_pgm = '1' then
			v.return_pgm := '1';
		end if;
		
		int_clear_screen <= r.clear_screen;
		
		if r.clear_screen = '1' and clear_done = '1' then
			v.clear_done := '1';
			v.clear_screen := '0';
		end if;
	
		-- getframe 10 cycles high lassen um sicherzustellen, dass read_raw mit pixelclk es nicht verpasst
		if r.getframe = '1' then
			if r.wait_gf = 9 then
				v.getframe := '0';
				v.wait_gf := 0;
			else
				v.wait_gf := r.wait_gf + 1;	
			end if;
		end if;
		
		getframe <= r.getframe;
		r_next <= v;
    end process;    
    
    
    ------------------------
	---	Sync Daten übernehmen
	------------------------
    reg : process(clk)
	begin
		if rising_edge(clk) then
			if rstint = RST_ACT then
				r.ifacereg <= (others => (others => '0'));
			else
				r <= r_next;
			end if;
		end if;
	end process;
end ;

