library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;
use work.spear_amba_pkg.all;

entity spear is
  generic (
    CONF : spear_conf_type := (
      tech => ALTERA,
      word_size => 32,
      boot_rom_size => 8,
      instr_ram_size => 13,
      data_ram_size => 13,
      use_iram => true,
      use_amba => false,
      amba_shm_size => 8,
      amba_word_size => 32,
      gdb_mode => 0,
      bootrom_base_address => 15
      ));
  port (
    clk       : in  std_ulogic;
    extrst    : in  std_ulogic;
    sysrst   : out std_ulogic;
    --Extensiom Module Interface
    speari    : in  spear_in_type;
    spearo    : out spear_out_type;
    -- AMBA AHB Master Interface
    ahbmi     : in  ahb_master_in_type;
    ahbmo     : out ahb_master_out_type;
    -- Debug Interface
    debugi_if : IN  debug_if_in_type;
    debugo_if : OUT debug_if_out_type
    );
end spear;

architecture behaviour of spear is

  constant WORD_W    : natural                              := CONF.word_size;
  subtype WORD is std_logic_vector(WORD_W-1 downto 0);
  constant EXTMODACT : std_logic_vector(WORD_W-1 downto 15) := (others => '1');

  type reg_type is record
    extdata       : std_logic_vector(31 downto 0);
    old_memaccess : MEMACCESSTYPE;
    old_signedac : std_ulogic;
    old_address  : std_logic_vector(1 downto 0);
    ext_mod_sel  : std_ulogic;
    transmode    : std_ulogic;
  end record;

  type spear2ext_type is record
    data     : std_logic_vector(31 downto 0);
    addr     : std_logic_vector(14 downto 0);
    byte_en  : std_logic_vector(3 downto 0);
    write_en : std_ulogic;
  end record;

  signal r_next : reg_type;

  signal r : reg_type :=
    (
      extdata       => (others => '0'),
      old_memaccess => MEM_DISABLE,
      old_signedac  => '0',
      old_address   => (others => '0'),
      ext_mod_sel   => '0',
      transmode     => '0'
      );


  -- internal spear2 Core Signals 
  signal intrst    : std_ulogic;
  signal exthold   : std_ulogic;
  signal cpu_halt  : std_ulogic;
  signal progrst   : std_ulogic;

  signal regfi_wdata       : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfi_waddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfi_wen         : std_ulogic;
  signal regfi_raddr1      : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfi_raddr2      : std_logic_vector(REGADDR_W-1 downto 0);                 
  signal regfo_rdata1      : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfo_rdata2      : std_logic_vector(CONF.word_size-1 downto 0);

  signal corei_interruptin : std_logic_vector(15 downto 0);
  signal corei_extdata     : std_logic_vector(CONF.word_size-1 downto 0);
  signal coreo_extwr       : std_ulogic;
  signal coreo_signedac    : std_ulogic;
  signal coreo_extaddr     : std_logic_vector(CONF.word_size-1 downto 0);
  signal coreo_extdata     : std_logic_vector(CONF.word_size-1 downto 0);
  signal coreo_memaccess   : MEMACCESSTYPE;
  signal coreo_memen       : std_ulogic;
  signal coreo_illop       : std_ulogic;

  signal bromi_addr        : std_logic_vector(CONF.word_size-1 downto 0);
  signal bromo_data        : INSTR;
  
  signal vecti_data_in     : std_logic_vector(CONF.word_size-1 downto 0);
  signal vecti_interruptnr : std_logic_vector(EXCADDR_W-2 downto 0);
  signal vecti_trapnr      : std_logic_vector(EXCADDR_W-1 downto 0);
  signal vecti_wrvecnr     : std_logic_vector(EXCADDR_W-1 downto 0);
  signal vecti_intcmd      : std_ulogic;
  signal vecti_wrvecen     : std_ulogic;
  signal vecto_data_out    : std_logic_vector(CONF.word_size-1 downto 0);
  
  signal sysci_staen       : std_ulogic;
  signal sysci_stactrl     : STACTRL;
  signal sysci_staflag     : std_logic_vector(ALUFLAG_W-1 downto 0);
  signal sysci_interruptin : std_logic_vector(15 downto 0);
  signal sysci_fptrwnew    : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysci_fptrxnew    : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysci_fptrynew    : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysci_fptrznew    : std_logic_vector(CONF.word_size-1 downto 0);
  
  signal sysco_condflag    : std_ulogic;
  signal sysco_carryflag   : std_ulogic;
  signal sysco_interruptnr : std_logic_vector(EXCADDR_W-2 downto 0);
  signal sysco_intcmd      : std_ulogic;
  signal sysco_fptrw       : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysco_fptrx       : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysco_fptry       : std_logic_vector(CONF.word_size-1 downto 0);
  signal sysco_fptrz       : std_logic_vector(CONF.word_size-1 downto 0);
  
  signal progo_instrsrc    : std_ulogic;
  signal progo_prupdate    : std_ulogic;
  signal progo_praddr      : std_logic_vector(CONF.instr_ram_size-1 downto 0);
  signal progo_prdata      : INSTR;


  signal drami_write_en  : std_ulogic;
  signal drami_byte_en   : std_logic_vector(3 downto 0);
  signal drami_data_in   : std_logic_vector(31 downto 0);
  signal drami_addr      : std_logic_vector(CONF.data_ram_size-1 downto 2);
  signal dramo_data_out  : std_logic_vector(31 downto 0);
  
  signal syscsel   : std_ulogic;
  signal progexto  : module_out_type;
  signal progsel   : std_ulogic;
  signal syscexto  : module_out_type;
  signal exti      : module_in_type;
  signal dramsel   : std_ulogic;
  signal spear2ext : spear2ext_type;

  -- signals required for debug unit
  signal miniUARTsel      : std_ulogic;
  signal miniUARTexto     : module_out_type;
  signal D_RxD, D_TxD     : std_ulogic;
  signal breakpointsel    : std_ulogic;
  signal breakpointexto   : module_out_type;
  signal watchpointsel    : std_ulogic;
  signal watchpointexto   : module_out_type;
  signal s_watchpoint_act : std_ulogic;

  signal s_debugo_wdata      : INSTR;
  signal s_debugo_waddr      : std_logic_vector(CONF.instr_ram_size-1 downto 0);
  signal s_debugo_wen        : std_ulogic;
  signal s_debugo_raddr      : std_logic_vector(CONF.instr_ram_size-1 downto 0);
  signal s_debugo_rdata      : INSTR;
  signal s_debugo_read_en    : std_ulogic;    
  signal s_debugo_hi_addr    : std_logic_vector(CONF.word_size-1 downto 15);   
  signal s_debugi_rdata      : INSTR;

  -- signals required for AMBA
  -- signals for component amba shared memory
  signal ambadramsel  : std_ulogic;
  signal ambadramexto : module_out_type;
  
  -- signals for component amba extension module
  signal ambaexto     : module_out_type;
  signal ambasel      : std_ulogic;
  signal addr_high    : std_logic_vector(31 downto 15);
  -- signal for transparent mode
  signal transmode    : std_ulogic;
  -- signal for Gaisler interrupt system
  signal gIRQ         : std_ulogic;
  -- signal for stalling spear
  signal spearhold    : std_ulogic;

begin

  s_debugo_read_en <= coreo_memen;
  s_debugo_hi_addr <= coreo_extaddr(WORD_W-1 downto 15);

  core_unit : spear_core
  generic map(
    CONF => CONF)
  port map(
    clk               => clk,
    sysrst            => intrst,
    hold              => cpu_halt,

    iramo_rdata       => s_debugi_rdata,    
    irami_wdata       => s_debugo_wdata,
    irami_waddr       => s_debugo_waddr,
    irami_wen         => s_debugo_wen,  
    irami_raddr       => s_debugo_raddr,

    regfi_wdata       => regfi_wdata,
    regfi_waddr       => regfi_waddr,
    regfi_wen         => regfi_wen,
    regfi_raddr1      => regfi_raddr1,
    regfi_raddr2      => regfi_raddr2,
    regfo_rdata1      => regfo_rdata1,
    regfo_rdata2      => regfo_rdata2,

    corei_interruptin => corei_interruptin,
    corei_extdata     => corei_extdata,
    coreo_extwr       => coreo_extwr,   
    coreo_signedac    => coreo_signedac,
    coreo_extaddr     => coreo_extaddr,  
    coreo_extdata     => coreo_extdata,   
    coreo_memaccess   => coreo_memaccess,
    coreo_memen       => coreo_memen, 
    coreo_illop       => coreo_illop,

    bromi_addr        => bromi_addr,
    bromo_data        => bromo_data,

    vecti_data_in     => vecti_data_in,
    vecti_interruptnr => vecti_interruptnr,
    vecti_trapnr      => vecti_trapnr,
    vecti_wrvecnr     => vecti_wrvecnr,
    vecti_intcmd      => vecti_intcmd,
    vecti_wrvecen     => vecti_wrvecen,
    vecto_data_out    => vecto_data_out,

    sysci_staen       => sysci_staen,
    sysci_stactrl     => sysci_stactrl,
    sysci_staflag     => sysci_staflag,
    sysci_interruptin => sysci_interruptin,
    sysci_fptrwnew    => sysci_fptrwnew,
    sysci_fptrxnew    => sysci_fptrxnew,
    sysci_fptrynew    => sysci_fptrynew,
    sysci_fptrznew    => sysci_fptrznew,

    sysco_condflag    => sysco_condflag,
    sysco_carryflag   => sysco_carryflag,
    sysco_interruptnr => sysco_interruptnr,
    sysco_intcmd      => sysco_intcmd,
    sysco_fptrw       => sysco_fptrw,
    sysco_fptrx       => sysco_fptrx,
    sysco_fptry       => sysco_fptry,
    sysco_fptrz       => sysco_fptrz,

    progo_instrsrc    => progo_instrsrc,
    progo_prupdate    => progo_prupdate,
    progo_praddr      => progo_praddr,
    progo_prdata      => progo_prdata);

  regf_unit : spear_regf
    generic map (
      CONF => CONF)
    port map(
      wclk  => clk,
      rclk  => clk,
      hold  => cpu_halt,

      wdata       => regfi_wdata,
      waddr       => regfi_waddr,
      wen         => regfi_wen,
      raddr1      => regfi_raddr1,
      raddr2      => regfi_raddr2,
      rdata1      => regfo_rdata1,
      rdata2      => regfo_rdata2);

  dram_unit : spear_dram
    generic map (
      CONF => CONF)
    port map(
      clk     => clk,
      hold    => cpu_halt,
      dramsel => dramsel,

      write_en => drami_write_en,
      byte_en  => drami_byte_en, 
      data_in  => drami_data_in,
      addr     => drami_addr,

      data_out => dramo_data_out);

  brom_unit : spear_brom
    generic map (
      CONF => CONF)
    port map(
      clk   => clk,
      hold  => cpu_halt,
      addr        => bromi_addr,
      data        => bromo_data);

  vect_unit : spear_vectab
    generic map (
      CONF => CONF)
    port map(
      clk   => clk,
      hold  => cpu_halt,

      data_in     => vecti_data_in,
      interruptnr => vecti_interruptnr,
      trapnr      => vecti_trapnr,
      wrvecnr     => vecti_wrvecnr,
      intcmd      => vecti_intcmd,
      wrvecen     => vecti_wrvecen,
      data_out    => vecto_data_out);

  sysc_unit : spear_sysc
    generic map (
      CONF => CONF)
    port map(
      clk      => clk,
      extrst   => progrst,
      sysrst   => intrst,
      hold     => exthold,
      cpu_halt => cpu_halt,
      extsel   => syscsel,
      exti     => exti,
      exto     => syscexto,

      staen       => sysci_staen,
      stactrl     => sysci_stactrl,
      staflag     => sysci_staflag,
      interruptin => sysci_interruptin,
      fptrwnew    => sysci_fptrwnew,
      fptrxnew    => sysci_fptrxnew,
      fptrynew    => sysci_fptrynew,
      fptrznew    => sysci_fptrznew,
      
      condflag    => sysco_condflag,
      carryflag   => sysco_carryflag,
      interruptnr => sysco_interruptnr,
      intcmd      => sysco_intcmd,
      fptrw       => sysco_fptrw,
      fptrx       => sysco_fptrx,
      fptry       => sysco_fptry,
      fptrz       => sysco_fptrz);
  
-------------------------------------------------------------------------------
-- Begin: Configurable SPEAR2 Modules
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Instruction RAM Configuration
-------------------------------------------------------------------------------
  use_prog_gen : if (CONF.use_iram = true) generate
    iram_unit : spear_iram
      generic map (
        CONF => CONF)
      port map (
        wclk  => clk,
        rclk  => clk,
        hold  => cpu_halt,
        
        wdata => s_debugo_wdata,
        waddr => s_debugo_waddr,
        wen   => s_debugo_wen,
        raddr => s_debugo_raddr,
        rdata => s_debugo_rdata);

    prog_unit : spear_prog
      generic map (
        CONF => CONF)
      port map(
        clk     => clk,
        extrst  => extrst,
        progrst => progrst,
        hold    => cpu_halt,
        extsel  => progsel,
        exti    => exti,
        exto    => progexto,

        instrsrc    => progo_instrsrc,
        prupdate    => progo_prupdate,
        praddr      => progo_praddr,
        prdata      => progo_prdata);
  end generate;

  no_prog_gen : if (CONF.use_iram = false) generate
    s_debugo_rdata <= (others => '0');
    progo_instrsrc <= '0';
    progo_prupdate <= '0';
    progo_praddr   <= (others => '0');
    progo_prdata   <= (others => '0');
    progexto       <= ((others           => '0'), '0');
    progrst        <= extrst;
  end generate;

-------------------------------------------------------------------------------
-- Debug Unit configuration
-------------------------------------------------------------------------------              


  ext_miniUART_unit : ext_miniUART
    port map (
      clk    => clk,
      extsel => miniUARTsel,
      exti   => exti,
      exto   => miniUARTexto,
      RxD    => D_RxD,
      TxD    => D_TxD); 

  use_debug_gen : if (CONF.gdb_mode = 1) generate
    
    ext_breakpoint_unit : ext_breakpoint
      generic map (
        CONF => CONF)
      port map (
        clk            => clk,
        extsel         => breakpointsel,
        exti           => exti,
        exto           => breakpointexto,
        
        debugo_wdata   => s_debugo_wdata,
        debugo_waddr   => s_debugo_waddr,
        debugo_wen     => s_debugo_wen,
        debugo_raddr   => s_debugo_raddr,
        debugo_rdata   => s_debugo_rdata,
        debugo_read_en => s_debugo_read_en,
        debugo_hi_addr => s_debugo_hi_addr,
        debugi_rdata   => s_debugi_rdata,
        watchpoint_act => s_watchpoint_act
        );

    ext_watchpoint_unit : ext_watchpoint
      generic map (
        CONF => CONF)
      port map (
        clk     => clk,
        extsel  => watchpointsel,
        exti    => exti,
        exto    => watchpointexto,
        read_en => s_debugo_read_en,
        hi_addr => s_debugo_hi_addr       --lower 15 bits in exti.addr
        );

  end generate;


  no_debug_gen : if (CONF.gdb_mode = 0) generate
  --  miniUARTexto        <= ((others => '0'), '0');
    breakpointexto      <= ((others => '0'), '0');
    watchpointexto      <= ((others => '0'), '0');
    s_debugi_rdata <= s_debugo_rdata;
    
 --   D_TxD               <= '1';
  end generate;


-------------------------------------------------------------------------------
-- AMBA Configuration
-------------------------------------------------------------------------------
  ena_amba : if (CONF.use_amba = true) generate

    signal ambadramlock : std_ulogic;
    signal ambadrami_write_en  : std_ulogic;
    signal ambadrami_byte_en   : std_logic_vector(3 downto 0);
    signal ambadrami_data_in   : std_logic_vector(CONF.word_size-1 downto 0);
    signal ambadrami_addr      : std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    signal ambadramo_data_out  : std_logic_vector(CONF.word_size-1 downto 0);

  begin
    
    ---------------------------------------
    --- AMBA DRAM-Module on Extension-Bus
    ---------------------------------------
    ambadram_unit : ext_AMBA_sharedmem
      generic map (
        CONF => CONF)
      port map(
        clk          => clk,
        rst          => intrst,
        -- de Frage: ist das nicht auch Teil des AMBA <-> Shared DRAM 
        ambadramsel  => ambadramsel,
        ambadramlock => ambadramlock,
        -- Extension-Module Interface
        exti         => exti,
        exto         => ambadramexto,
        -- AMBA <-> Shared DRAM

        adrami_write_en => ambadrami_write_en,
        adrami_byte_en  => ambadrami_byte_en,
        adrami_data_in  => ambadrami_data_in,
        adrami_addr     => ambadrami_addr,
        adramo_data_out => ambadramo_data_out
        );

    ---------------------------------------
    --- AMBA-Module on Extension-Bus
    ---------------------------------------
    amba_unit : ext_AMBA
      generic map(
        CONF       => CONF,
        DRAMOffset => (others => '0')
        )
      port map(
        clk          => clk,
        rst          => intrst,
        extsel       => ambasel,
        ambadramlock => ambadramlock,
        transmode    => transmode,
        -- Extension-Module Interface
        exti         => exti,
        exto         => ambaexto,
        addr_high    => addr_high,
        -- Gaisler interrupt
        gIRQ         => gIRQ,
        spearhold    => spearhold,
        -- AMBA-Interface
        AMBAI        => ahbmi,
        AMBAO        => ahbmo,
        -- DRAM-Interface
        
        AtD_write_en => ambadrami_write_en,
        AtD_byte_en  => ambadrami_byte_en,
        AtD_data_in  => ambadrami_data_in,
        AtD_addr     => ambadrami_addr,
        DtA_data_out => ambadramo_data_out
        );

  end generate;

  no_amba : if (CONF.use_amba = false) generate
    ahbmo         <= AMBA_MASTER_OUT_VOID;
    gIRQ          <= '0';
    ambadramexto  <= MODULE_OUT_VOID;
    ambaexto      <= MODULE_OUT_VOID;
    spearhold     <= not HOLD_ACT;
  end generate;
-------------------------------------------------------------------------------
-- End Configurable SPEAR Modules
-------------------------------------------------------------------------------
  

  comb : process(r, speari, spearhold, dramo_data_out, syscexto, progexto, breakpointexto, miniUARTexto,
                 debugi_if, D_TxD, watchpointexto, ambaexto, ambadramexto,
                 coreo_extwr, coreo_signedac, coreo_extaddr, coreo_extdata, coreo_memaccess, coreo_memen,
                 spear2ext, intrst, cpu_halt)  --erweitern!
    variable v              : reg_type;
    variable v_aligned_data : std_logic_vector(31 downto 0);
  begin
    v := r;

    spear2ext.data     <= (others => '0');
    spear2ext.addr     <= coreo_extaddr(14 downto 0);
    spear2ext.byte_en  <= (others => '0');
    spear2ext.write_en <= coreo_extwr;
    if (CONF.use_amba = true and CONF.word_size = 32) then
      addr_high(31 downto 15) <= coreo_extaddr(31 downto 15);
    else
      addr_high(31 downto 15) <= (others => '0');
    end if;
    --
    -- write access
    --
    case coreo_memaccess is
      when BYTE_A =>
        spear2ext.data(7 downto 0)   <= coreo_extdata(7 downto 0);
        spear2ext.data(15 downto 8)  <= coreo_extdata(7 downto 0);
        spear2ext.data(23 downto 16) <= coreo_extdata(7 downto 0);
        spear2ext.data(31 downto 24) <= coreo_extdata(7 downto 0);
        case coreo_extaddr(1 downto 0) is
          when "00" =>
            spear2ext.byte_en(0) <= '1';
          when "01" =>
            spear2ext.byte_en(1) <= '1';
          when "10" =>
            spear2ext.byte_en(2) <= '1';
          when "11" =>
            spear2ext.byte_en(3) <= '1';
          when others =>
            null;
        end case;
      when HWORD_A =>
        spear2ext.data(15 downto 0)  <= coreo_extdata(15 downto 0);
        spear2ext.data(31 downto 16) <= coreo_extdata(15 downto 0);
        case coreo_extaddr(1) is
          when '0' =>
            spear2ext.byte_en(1 downto 0) <= "11";
          when '1' =>
            spear2ext.byte_en(3 downto 2) <= "11";
          when others =>
            null;
        end case;
      when WORD_A =>
        if (CONF.word_size = 32) then
          spear2ext.data                <= coreo_extdata;
          spear2ext.byte_en(3 downto 0) <= "1111";
        else
          null;
        end if;
      when others =>
        null;
    end case;

    --
    -- read access
    --
    v.old_memaccess := coreo_memaccess;
    v.old_signedac  := coreo_signedac;
    v.old_address   := coreo_extaddr(1 downto 0);

    v_aligned_data := (others => '0');
    if r.ext_mod_sel = '1' then
      v_aligned_data := r.extdata;
    else
      v_aligned_data := dramo_data_out;
    end if;

    case r.old_address is
      when "00" =>
        v_aligned_data := v_aligned_data;
      when "01" =>
        v_aligned_data(7 downto 0) := v_aligned_data(15 downto 8);
      when "10" =>
        v_aligned_data(15 downto 0) := v_aligned_data(31 downto 16);
      when "11" =>
        v_aligned_data(7 downto 0) := v_aligned_data(31 downto 24);
      when others =>
        null;
    end case;

    case r.old_memaccess is
      when BYTE_A =>
        if (r.old_signedac = SIGNED_AC) then
          v_aligned_data(31 downto 8) := (others => v_aligned_data(7));
        else
          v_aligned_data(31 downto 8) := (others => '0');
        end if;
      when HWORD_A =>
        if (r.old_signedac = SIGNED_AC) then
          v_aligned_data(31 downto 16) := (others => v_aligned_data(15));
        else
          v_aligned_data(31 downto 16) := (others => '0');
        end if;
      when others =>
        null;
    end case;

    corei_extdata <= v_aligned_data(WORD_W-1 downto 0);

    syscsel       <= '0';
    progsel       <= '0';
    spearo.extsel <= '0';
    dramsel       <= '0';
    miniUARTsel   <= '0';
    breakpointsel <= '0';
    watchpointsel <= '0';
    ambasel       <= '0';
    ambadramsel   <= '0';
    transmode     <= '0';
    --
    -- module selection
    --
    v.ext_mod_sel := '0';
    if (coreo_extaddr(WORD_W-1 downto 15) = EXTMODACT) then
      v.ext_mod_sel := '1';
      case coreo_extaddr(14 downto 5) is
        when "1111111111" =>            -- (-32)
          --SYSC Module
          syscsel <= coreo_extwr or coreo_memen;
        when "1111111110" =>            -- (-64)
          --PROG Module
          if (CONF.use_iram = true) then
            progsel <= coreo_extwr or coreo_memen;
          end if;

     -- when "1111111110" => -- Reserved for Protection Unit  (-96)

        when "1111111100" => -- (-128)
          --miniUART Module for debug purpose
        
            miniUARTsel <= coreo_extwr or coreo_memen;
          
        when "1111111011" =>  -- (-160)
          --breakpoint Module
          if (CONF.gdb_mode = 1) then
            breakpointsel <= coreo_extwr or coreo_memen;
          end if;
        when "1111111010" =>  -- (-192)
          --watchpoint Module
          if (CONF.gdb_mode = 1) then
            watchpointsel <= coreo_extwr or coreo_memen;
          end if;
        when "1111111001" =>  -- (-224)
          --AMBA Module
          if (CONF.use_amba = true) then
            ambasel <=  coreo_extwr or coreo_memen;
          end if;
        when "1000000000" =>
          --AMBA Shared Memory
          if (CONF.use_amba = true) then
            ambadramsel <=  coreo_extwr or coreo_memen;
          end if;
        when "1000000001" =>
          --AMBA Shared Memory
          if (CONF.use_amba = true) then
            ambadramsel <=  coreo_extwr or coreo_memen;
          end if;
        when "1000000010" =>
          --AMBA Shared Memory
          if (CONF.use_amba = true) then
            ambadramsel <=  coreo_extwr or coreo_memen;
          end if;
        when "1000000011" =>
          --AMBA Shared Memory
          if (CONF.use_amba = true) then
            ambadramsel <=  coreo_extwr or coreo_memen;
          end if;
       
        when others =>
          null;
      end case;
      spearo.extsel <= coreo_extwr or coreo_memen;
    else
      if (CONF.word_size = 32) then
        if coreo_extaddr(31)='1' then 
          -- Transparent mode, the data is provided by amba extnesion module
          v.ext_mod_sel := '1';
          transmode <= coreo_extwr or coreo_memen;--coreo_extaddr(31);
          v.transmode := coreo_extwr or coreo_memen;--coreo_extaddr(31);
        else
          dramsel <= coreo_extwr or coreo_memen;
        end if;
      else
        dramsel <= coreo_extwr or coreo_memen;
        transmode <= '0';
        v.transmode := '0';
      end if;
    end if;

    --
    -- build write back bus
    --
    v.extdata := (others => '0');
    for i in v.extdata'left downto v.extdata'right loop
      v.extdata(i) := speari.data(i) or syscexto.data(i) or progexto.data(i) or breakpointexto.data(i) or watchpointexto.data(i) or miniUARTexto.data(i);
      if CONF.use_amba = true then
        v.extdata(i) := v.extdata(i) or ambadramexto.data(i) or ambaexto.data(i);
      end if;
    end loop; 

    --
    -- for external modules
    --
    spearo.data     <= spear2ext.data;
    spearo.addr     <= spear2ext.addr(14 downto 0);
    spearo.byte_en  <= spear2ext.byte_en;
    spearo.write_en <= spear2ext.write_en;
    spearo.reset    <= intrst;

    --
    -- for sys-ctrl-unit  programmer-unit breakpoint-unit and watchpoint-unit 
    --
    exti.data        <= spear2ext.data;
    exti.addr        <= spear2ext.addr(14 downto 0);
    exti.byte_en     <= spear2ext.byte_en;
    exti.write_en    <= spear2ext.write_en;

    -- common reset not used for sysctrl- and programmer-module
    exti.reset       <= intrst;         --'0';
    s_watchpoint_act <= watchpointexto.intreq;
    D_RxD            <= debugi_if.D_RxD;
    debugo_if.D_TxD  <= D_TxD;


    --
    -- for internal data memory
    --
    drami_data_in  <= spear2ext.data;
    drami_addr     <= coreo_extaddr(CONF.data_ram_size-1 downto 2);
    drami_byte_en  <= spear2ext.byte_en;
    drami_write_en <= spear2ext.write_en;
    
    sysrst <= intrst;
    exthold         <= speari.hold;
    spearo.cpu_halt <= cpu_halt;

    if (CONF.use_amba = true) then
      exthold <= spearhold or speari.hold;
    else
      exthold <= speari.hold;
    end if;

    r_next <= v;
  end process;


  reg : process(clk)                    --, intrst)
  begin
    if rising_edge(clk) then
      if intrst = RST_ACT then
        r.extdata       <= (others => '0');
        r.old_memaccess <= MEM_DISABLE;
        r.old_signedac  <= '0';
        r.old_address   <= (others => '0');
        r.ext_mod_sel   <= '0';
        r.transmode <= '0';
      else
        if (cpu_halt = not HOLD_ACT) then
          r <= r_next;
        end if;
      end if;
    end if;
  end process;

  
  process(coreo_illop, syscexto, progexto, miniUARTexto, breakpointexto, ambaexto, gIRQ, ambadramexto, speari)
  begin  -- process
    corei_interruptin(15 downto 0) <= (others => '0');

    -- internal interrupt sources
    corei_interruptin(15) <= coreo_illop;
    corei_interruptin(14) <= syscexto.intreq;
    corei_interruptin(13) <= progexto.intreq;
    corei_interruptin(12)  <= '0'; --Reserved for Protection CTRL Unit
    corei_interruptin(11)  <= miniUARTexto.intreq or breakpointexto.intreq;

    if (CONF.use_amba = true) then
      corei_interruptin(10) <= ambaexto.intreq;  -- Communication error
      corei_interruptin(9) <= gIRQ;         -- Merged AMBA Modules Interrupt
      corei_interruptin(8) <= ambadramexto.intreq;  -- Shared Memory access violation 
    end if;

    -- external interrupt sources   
    corei_interruptin(7 downto 0) <= speari.interruptin;
    
  end process;

end behaviour;
