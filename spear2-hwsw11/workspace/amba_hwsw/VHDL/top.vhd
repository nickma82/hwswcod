library ieee;
use ieee.std_logic_1164.all;

use work.top_pkg.all;
use work.spear_pkg.all;
use work.spear_amba_pkg.all;
use work.pkg_dis7seg.all;
use work.pkg_counter.all;
use work.pkg_writeframe.all;
use work.pkg_aluext.all;

library grlib;
use grlib.amba.all;

library techmap;
use techmap.gencomp.all;

library gaisler;
use gaisler.misc.all;
use gaisler.memctrl.all;



entity top is
  port(
    db_clk      : in  std_ulogic;
    rst         : in  std_ulogic;
    -- Debug Interface
    D_RxD       : in  std_logic; 
    D_TxD       : out std_logic;
    -- 7Segment Anzeige
    digits      : out digit_vector_t(7 downto 0);
    -- SDRAM Controller Interface (AMBA)
    sdcke       : out std_logic;
    sdcsn       : out std_logic;
    sdwen       : out std_logic;
    sdrasn      : out std_logic;
    sdcasn      : out std_logic;
    sddqm       : out std_logic_vector(3 downto 0);
    sdclk       : out std_logic;
    sa          : out std_logic_vector(14 downto 0);
    sd          : inout std_logic_vector(31 downto 0);
    -- LCD (AMBA)
    ltm_hd      : out std_logic;
    ltm_vd      : out std_logic;
    ltm_r       : out std_logic_vector(7 downto 0);
    ltm_g       : out std_logic_vector(7 downto 0);
    ltm_b       : out std_logic_vector(7 downto 0);
    ltm_nclk    : out std_logic;
    ltm_den     : out std_logic;
    ltm_grest   : out std_logic
  );
end top;

architecture behaviour of top is
  
  signal speari    : spear_in_type;
  signal spearo    : spear_out_type;

  signal debugi_if : debug_if_in_type;
  signal debugo_if : debug_if_out_type;

  signal exti      : module_in_type;
  
  signal syncrst     : std_ulogic;
  signal sysrst      : std_ulogic;

  signal clk         : std_logic;

  -- 7-segment display
  signal dis7segsel  : std_ulogic;
  signal dis7segexto : module_out_type;

  -- signals for counter extension module
  signal counter_segsel : std_logic;
  signal counter_exto : module_out_type;
  
  -- signals for writeframe extension module
  signal writeframe_segsel : std_logic;
  signal writeframe_exto : module_out_type;

  -- signals for aluext extension module
  signal aluext_segsel : std_logic;
  signal aluext_exto : module_out_type;
  
  -- signals for AHB slaves and APB slaves
  signal ahbmi            : ahb_master_in_type;
  signal spear_ahbmo      : ahb_master_out_type;
  signal grlib_ahbmi      : ahb_mst_in_type;
  signal grlib_ahbmo      : ahb_mst_out_vector;
  signal ahbsi            : ahb_slv_in_type;
  signal ahbso            : ahb_slv_out_vector; 
  signal apbi             : apb_slv_in_type;
  signal apbo             : apb_slv_out_vector;
  signal apb_bridge_ahbso : ahb_slv_out_type;
  signal sdram_ahbso      : ahb_slv_out_type;

  -- signals for SDRAM Controller
  signal sdi            : sdctrl_in_type;
  signal sdo            : sdctrl_out_type;
  
  -- signals for VGA Controller
  signal vgao           : apbvga_out_type;
  signal vga_clk_int    : std_logic;
  signal vga_clk_sel    : std_logic_vector(1 downto 0);
  signal svga_ahbmo     : ahb_mst_out_type;
  
  -- signals for writeframe AMBA Master
  signal writeframe_ahbmo : ahb_mst_out_type;
  
  component altera_pll IS
    PORT
      (
        areset		: IN STD_LOGIC  := '0';
        inclk0		: IN STD_LOGIC  := '0';
        c0		: OUT STD_LOGIC ;
        c1		: OUT STD_LOGIC;
        locked		: OUT STD_LOGIC 
        );
   END component;

begin
	
  altera_pll_inst : altera_pll PORT MAP (
    areset	 => '0',
    inclk0	 => db_clk,
    c0	         => clk,
    c1	         => vga_clk_int,
    locked	 => open
    );

  spear_unit: spear
    generic map (
    CONF => (
      tech => work.spear_pkg.ALTERA,
      word_size => 32,
      boot_rom_size => 12,
      instr_ram_size => 16,
      data_ram_size => 17,
      use_iram => true,
      use_amba => true,
      amba_shm_size => 8,
      amba_word_size => 32,
      gdb_mode => 0,
      bootrom_base_address => 29
      ))
    port map(
      clk    => clk,
      sysrst => sysrst,
      extrst => syncrst,
      speari => speari,
      spearo => spearo,
      ahbmi  => ahbmi,
      ahbmo  => spear_ahbmo,
      debugi_if => debugi_if,
      debugo_if => debugo_if
      );
 

  -----------------------------------------------------------------------------
  -- AMBA AHB arbiter/multiplexer
  -----------------------------------------------------------------------------

  ahb0 : ahbctrl
    generic map(
      defmast => 0,                  -- default master
      split   => 0,                  -- split support
      nahbm   => 3,                  -- number of masters
      nahbs   => AHB_SLAVE_COUNT,    -- number of slaves
      fixbrst => 1                   -- support fix-length bursts
      )
    port map(
      rst  => sysrst,
      clk  => clk,
      msti => grlib_ahbmi,
      msto => grlib_ahbmo,
      slvi => ahbsi,
      slvo => ahbso
      );


  process(grlib_ahbmi, spear_ahbmo, svga_ahbmo, writeframe_ahbmo)
  begin  -- process
    ahbmi.hgrant  <=  grlib_ahbmi.hgrant(0);
    ahbmi.hready  <=  grlib_ahbmi.hready;
    ahbmi.hresp   <=  grlib_ahbmi.hresp;
    ahbmi.hrdata  <=  grlib_ahbmi.hrdata;
    ahbmi.hirq    <=  grlib_ahbmi.hirq(MAX_AHB_IRQ-1 downto 0);

    for i in 2 to grlib_ahbmo'length - 1 loop
      grlib_ahbmo(i) <= ahbm_none;
    end loop;

    grlib_ahbmo(0).hbusreq  <=  spear_ahbmo.hbusreq;
    grlib_ahbmo(0).hlock    <=  spear_ahbmo.hlock;
    grlib_ahbmo(0).htrans   <=  spear_ahbmo.htrans;
    grlib_ahbmo(0).haddr    <=  spear_ahbmo.haddr;
    grlib_ahbmo(0).hwrite   <=  spear_ahbmo.hwrite;
    grlib_ahbmo(0).hsize    <=  spear_ahbmo.hsize;
    grlib_ahbmo(0).hburst   <=  spear_ahbmo.hburst;
    grlib_ahbmo(0).hprot    <=  spear_ahbmo.hprot;
    grlib_ahbmo(0).hwdata   <=  spear_ahbmo.hwdata;
    grlib_ahbmo(0).hirq     <=  (others => '0');
    grlib_ahbmo(0).hconfig  <=  AMBA_MASTER_CONFIG;
    grlib_ahbmo(0).hindex   <=  0;

    grlib_ahbmo(1)          <=  svga_ahbmo;
    
    grlib_ahbmo(2)			<=  writeframe_ahbmo;
  end process;


  -----------------------------------------------------------------------------
  -- AMBA AHB/APB Bridge
  -----------------------------------------------------------------------------

  apb_bridge : apbctrl
    generic map(
      hindex  => 0,
      haddr   => 16#F00#,
      hmask   => 16#fff#,
      nslaves => APB_SLAVE_COUNT
      )
    port map(
      rst  => sysrst,
      clk  => clk,
      ahbi => ahbsi,              -- from master to bridge
      ahbo => apb_bridge_ahbso,   -- from bridge to master
      apbi => apbi,               -- from bridge to slaves
      apbo => apbo                -- from slaves to bridge
      );

  -----------------------------------------------------------------------------
  -- SDRAM controller
  -----------------------------------------------------------------------------
  
  sdctrl_inst : sdctrl
  generic map
  (
    -- index of ahb slave (0 is already assigned by the APB master)
    hindex => 1,
    -- AHB address
    haddr => 16#E00#,
    -- AHB mask (determines size of the address space the component can utilize)
    hmask => 16#F80#,
    -- mapping of SDCFG register (here: position 0x000 + AHB i/o base address)
    ioaddr => 16#000#,
    -- send no initialization command sequence on reset release
    pwron => 0,
    -- bdrive & vdrive active low (default)
    oepol => 0,
    -- use 32 bit mode
    sdbits => 32,
    -- using inverted clock mode can help reaching timing requirements, but limits the sdclk to 40-50MHz
    invclk => 0,
    -- use 8-word burst for reading
    pageburst => 0
  )
  port map
  (
    rst => syncrst,
    clk => clk,
    ahbsi => ahbsi,
    ahbso => sdram_ahbso,
    sdi => sdi,
    sdo => sdo
  );
	

  -- sdram address
  sa(14 downto 0) <= sdo.address(16 downto 2);
  -- clock enable (active High)
  sdcke <= sdo.sdcke(0);
  -- chip select (active Low)
  sdcsn <= sdo.sdcsn(0);
  -- sdram clock
  sdclk <= clk;
  -- row address strobe
  sdrasn <= sdo.rasn;
  -- column address strobe
  sdcasn <= sdo.casn;
  -- write enable
  sdwen <= sdo.sdwen;
  -- data mask (data lines = DQ lines), when high supresses i/o data
  -- only first 4 strobes used for 32 bit mode
  sddqm <= sdo.dqm(3  downto 0);
  
  -- vectored iopad using vbdrive for controlling SDRAM data bus access
  sd_pad : iopadvv
  generic map
  (
    width => 32
  )
  port map
  (
    sd(31 downto 0),
    sdo.data(31 downto 0),
    sdo.vbdrive(31 downto 0),
    sdi.data(31 downto 0)
  );


  process(apb_bridge_ahbso, sdram_ahbso)
  begin  -- process
    ahbso    <= (others => ahbs_none);
    ahbso(0) <= apb_bridge_ahbso;
    ahbso(1) <= sdram_ahbso;
  end process;

  -----------------------------------------------------------------------------
  -- SVGA controller (LCD)
  -----------------------------------------------------------------------------
  
  svgactrl0 : svgactrl
    generic map
    (
      pindex => 0,
      paddr => 16#001#,
      pmask => 16#fff#,
      hindex => 1,
      memtech => 7
    )
    port map
    (
      rst => syncrst,
      clk => clk,
      vgaclk => vga_clk_int,
      apbi => apbi,
      apbo => apbo(0),
      vgao => vgao,
      ahbi => grlib_ahbmi,
      ahbo => svga_ahbmo,
      clk_sel => vga_clk_sel
    );  

    vga_clk_sel <= (others => '0');	
    ltm_hd <= vgao.hsync;
    ltm_vd <= vgao.vsync;
    ltm_r <= vgao.video_out_r(7 downto 0);
    ltm_g <= vgao.video_out_g(7 downto 0);
    ltm_b <= vgao.video_out_b(7 downto 0);
    ltm_nclk <= vga_clk_int;    
    ltm_den <= vgao.blank;
    ltm_grest <= '1';
  
  -----------------------------------------------------------------------------
  -- Spear extension modules
  -----------------------------------------------------------------------------
  
	aluext_unit : ext_aluext
	port map(
		clk       => clk,
		extsel    => aluext_segsel,
		exti      => exti,
		exto      => aluext_exto
	);

	writeframe_unit: ext_writeframe
  	port map(
		clk       => clk,
		extsel    => writeframe_segsel,
		exti      => exti,
		exto      => writeframe_exto,
		ahbi 		=> grlib_ahbmi,
		ahbo 		=> writeframe_ahbmo      
	);
      
  
	dis7seg_unit: ext_dis7seg
	  generic map (
	    DIGIT_COUNT => 8,
	    MULTIPLEXED => 0)
	  port map(
	    clk        => clk,
	    extsel     => dis7segsel,
	    exti       => exti,
	    exto       => dis7segexto,
	    digits     => digits,
	    DisEna     => open,
	    PIN_select => open
	  );
	
	
	counter_unit: ext_counter
	  port map(
	    clk        => clk,
	    extsel     => counter_segsel,
	    exti       => exti,
	    exto       => counter_exto
	  );
  
	comb : process(spearo, debugo_if, D_RxD, dis7segexto, counter_exto, writeframe_exto,aluext_exto)  --extend!
	  variable extdata : std_logic_vector(31 downto 0);
	begin   
		exti.reset    <= spearo.reset;
		exti.write_en <= spearo.write_en;
		exti.data     <= spearo.data;
		exti.addr     <= spearo.addr;
		exti.byte_en  <= spearo.byte_en;
		
		dis7segsel <= '0';
		counter_segsel <= '0';
		writeframe_segsel <= '0';
		aluext_segsel <= '0';
		if spearo.extsel = '1' then
		  case spearo.addr(14 downto 5) is
		    when "1111110111" => -- (-288)
		      --DIS7SEG Module
		      dis7segsel <= '1';
		    when "1111110110" => -- (-320)              
		      --Counter Module
		      counter_segsel <= '1';
		    when "1111110101" =>
		    	writeframe_segsel <= '1';
			-- auf 0xFFFFFE80
			when "1111110100" =>
				aluext_segsel <= '1';
		    when others =>
		      null;
		  end case;
		end if;
		
		extdata := (others => '0');
		for i in extdata'left downto extdata'right loop
		  extdata(i) := dis7segexto.data(i) or counter_exto.data(i) or writeframe_exto.data(i) or aluext_exto.data(i); 
		end loop;
		
		speari.data <= (others => '0');
		speari.data <= extdata;
		speari.hold <= '0';
		speari.interruptin <= (others => '0');
		
		
		--Debug interface
		D_TxD             <= debugo_if.D_TxD;
		debugi_if.D_RxD   <= D_RxD;
	end process;


	reg : process(clk)
	begin
		if rising_edge(clk) then
			--
			-- input flip-flops
			--
			syncrst <= rst;
		end if;
	end process;

end behaviour;
