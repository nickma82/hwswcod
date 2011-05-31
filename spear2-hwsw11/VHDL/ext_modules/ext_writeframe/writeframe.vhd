-----------------------------------------------------------------------------
-- Entity:      writeframe
-- Author:      Johannes Kasberger
-- Description: Ein Bild in Framebuffer übertragen
-- Date:		15.05.2011
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

entity ext_writeframe is
	port (
		clk       : in  std_logic;
		extsel    : in  std_ulogic;
		exti      : in  module_in_type;
		exto      : out module_out_type;
		ahbi      : in  ahb_mst_in_type;
		ahbo      : out ahb_mst_out_type;
		
		cm_d		: in std_logic_vector(11 downto 0); --pixel data
		cm_lval 	: in std_logic; 	--Line valid
		cm_fval 	: in std_logic; 	--Frame valid
		cm_pixclk	: in std_logic; 	--pixel Clock
		--cm_xclkin	: out std_logic;
		cm_reset	: out std_logic;	--D5M reset
		cm_trigger	: out std_logic;	--Snapshot trigger
		cm_strobe	: in std_logic 	--Snapshot strobe
    );
end ;

architecture rtl of ext_writeframe is
	-- AMBA Signale 
	signal dmai               : ahb_dma_in_type;
	signal dmao               : ahb_dma_out_type;
  
	-- Core Ext Signale
	subtype BYTE is std_logic_vector(7 downto 0);
	type register_set is array (0 to 4) of BYTE;
	type state_type is (idle, adr, data, done, reset, wait_px);
	type state_cam_type is (reset, wait_frame_valid, read_line, next_line, wait_frame_invalid);
	
	-- Cam Async Signals
	type state_pixsync_cam_type is (reset, wait_getframe, wait_frame_valid, read_dot_r, read_dot_g1, read_dot_g2, read_dot_b, next_line, wait_frame_invalid);
	 
	type pixsync_type is record
		state	: state_pixsync_cam_type;
		next_dot: state_pixsync_cam_type;
		toggle_r	: std_logic;
		toggle_c	: std_logic;
	end record;

	
	type reg_type is record
  		ifacereg	: register_set;
		getframe	: std_logic;
		address		: std_logic_vector(31 downto 0);
		wdata		: std_logic_vector(31 downto 0);
		state		: state_type;
		cam_state	: state_cam_type;
		start		: std_logic;
		color		: std_logic_vector(31 downto 0);
		p_r			: integer range 0 to CAM_H-1;
		p_c			: integer range 0 to CAM_W-1;
		send_px		: std_logic;
	end record;

	signal pix_next : pixsync_type;
	signal pix : pixsync_type := 
	(
		state	 => reset,
		next_dot => reset,
		toggle_r => '0',
		toggle_c => '0'
	);
	
	signal r_next : reg_type;
	signal r : reg_type := 
	(
		ifacereg => (others => (others => '0')),
		getframe => '0',
		address 	=> (others => '0'),
		wdata  	=> (others => '0'),
		state	=> reset,
		cam_state => reset,
		start	=> '0',
		color   => (others => '0'),
		p_r => 0,
		p_c => 0,
		send_px => '0'
	);
	
	signal rstint : std_ulogic;
  
	
begin
	ahb_master : ahbmst generic map (1, 0, VENDOR_WIR, WIR_WRITEFRAME, 0, 3, 1)
	port map (rstint, clk, dmai, dmao, ahbi, ahbo);
	
	
	------------------------
	---	ASync Core Ext Interface Daten übernehmen und schreiben
	------------------------
	comb : process(r, pix, exti, extsel,dmao, rstint, cm_lval, cm_fval, cm_d)
	variable v 		: reg_type;
	variable vpix	: pixsync_type;
	begin
    	v := r;
    	vpix:= pix;
    	   	
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
    				end if;
    			--when "010" =>
    				--v.color(31 downto 0) := exti.data(31 downto 0);
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
		
		------------------
		--- Statemachine
		------------------
		case r.state is
			when reset =>
				v.start := '0';
				v.state := idle;
			when idle =>
				--v.address := FRAMEBUFFER_BASE_ADR;
				v.state := wait_px;
			when wait_px =>
				if r.send_px = '1' then
					v.state := adr;
					v.start := '1';
				end if;
			when adr =>
				if dmao.ready = '1' then
					v.state := data;
				end if;
				v.wdata := r.color;
			when data =>
				if r.address >= FRAMEBUFFER_END_ADR then
					v.state := done;
				else
				--	v.address := r.address + 4;
					v.state := wait_px;
				end if;
				v.start := '0';
				v.send_px := '0';
			when done =>
				v.state := idle;
		end case;
		
		
		------------------------
		---	CCD Handler - FALLING EDGE PIXCLK sensitiv
		--- state_pixsync_cam_type
		-- reset, wait_frame_valid, wait_getframe, read_dot_r, read_dot_g1, read_dot_g2, read_dot_b, next_line, wait_frame_invalid
		------------------------
	-- @TODO: p_r und p_c in pix VERSCHIEBEN!!!!!!
		case pix.state is
			when reset =>
				vpix.state := wait_getframe;
				--@TODO ev. schon zu syncen beginnen
			when wait_getframe =>
				if r.getframe = '1' then
					vpix.state := wait_frame_invalid;
					vpix.toggle_r	:= '0';
				end if;
			when wait_frame_valid =>
				if cm_fval = '1' then
					vpix.toggle_c	:= '0';
					v.p_r := 0;
					if cm_lval = '1' then
						vpix.state := pix.next_dot;
					end if;
				end if;
			when read_dot_r =>
				-- r logic
				v.color := (others => '0');
				v.color(23 downto 16) := (others => '1');
				v.send_px := '1';
				vpix.state := pix.next_dot;
			when read_dot_g1 =>
				-- g1 logic
				v.color := (others => '0');
				v.color(15 downto 8) := (others => '1');
				v.send_px := '1';
			when read_dot_g2 =>
				-- g2 logic
				vpix.state := pix.next_dot;
			when read_dot_b =>
				-- b logic
				vpix.state := pix.next_dot;
			when next_line =>
				if r.p_r < CAM_H-1 then	
	-- @TODO: Wann ist das Bild fertig übertragen?? (letzte Zeile)
	-- Wenn Fertig, in wait getfram springen??
					v.p_r := r.p_r + 1;
					vpix.state := wait_frame_valid;
					vpix.toggle_r := not pix.toggle_r;
				else
					vpix.state := wait_frame_invalid;
				end if;
			when wait_frame_invalid =>
				if cm_lval = '0' and cm_fval = '0' then
					vpix.state := wait_frame_valid;
				end if;
		end case;
		
		---Next dot descision logic
		case pix.state is
			when others => 
				if r.p_c > 0 and cm_lval = '0' then
					vpix.next_dot := next_line;
				end if;
				vpix.next_dot := read_dot_r;
		end case;
		
		
		---das folgende gehört in den CCD Handler rein
		if r.cam_state = read_line and cm_lval = '1' and r.p_c < CAM_W-1 then
			v.p_c := r.p_c + 1;
			vpix.toggle_c := not pix.toggle_c;
			if r.address <= FRAMEBUFFER_END_ADR and falling_edge(cm_pixclk) then
				v.address := r.address + 4;
			else
				v.address := FRAMEBUFFER_BASE_ADR;
			end if;
		else
			v.p_c := 0;
			v.address := FRAMEBUFFER_BASE_ADR;
		end if;
		
		-- Werte auf Interface zu Bus legen
		dmai.wdata  <=  r.wdata;
	    dmai.burst  <= '0';
	    dmai.irq    <= '0';
	    dmai.size   <= "10";
	    dmai.write  <= '1';
	    dmai.busy   <= '0';
	    dmai.start    <= r.start;
	    dmai.address  <= r.address;
		
	    cm_reset <= rstint;
	    
	    pix_next <= vpix;
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
				r.state <= reset;
				r.cam_state <= reset;
			else
				r <= r_next;
			end if;
		end if;
	end process;
	
	
	cam_states : process(cm_pixclk)
	begin
		if falling_edge(cm_pixclk) then
			if rstint = RST_ACT then
				pix.state <= reset;
			else
				pix <= pix_next;
			end if;
		end if;
	end process;
	
end ;

