-------------------------------------------------------------------------------
-- Company:		  Institut f�r Technische Informatik - Abteilung ECS
-- Engineer:		 Josef MOSSER, 0126655
--
-- Create Date:	 
-- Design Name:	 ext_AMBA_DPRAM_32
-- Module Name:	 AMBA Extension-Module - Behavioral
-- Project Name: AMBA4Spear
-- Target Devices:
-- Tool versions:
-- Description:	 AMBA-Extension-Module for Spear
--
-- Dependencies: used in top entity
--
-- Revision:		 0.8 - ready for testing
-- Additional Comments:
--	todo: 
--
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.spear_core_pkg.all;
use work.spear_pkg.all;
use work.spear_amba_pkg.all;


entity ext_AMBA is
  generic(
    CONF       : spear_conf_type;
    DRAMOffset : bit_vector(31 downto 8) := (others => '0')
    );
  port(
    -- normal signals
    clk          : in  STD_ULOGIC;
    rst          : in  STD_ULOGIC;
    extsel       : in  STD_ULOGIC;
    ambadramlock : out STD_ULOGIC;
    transmode    : in  STD_ULOGIC;
    -- Extension-Module Interface
    exti         : in  module_in_type;
    exto         : out module_out_type;
    addr_high    : in  std_logic_vector(31 downto 15);
    -- Gaisler Interrupt
    gIRQ         : out STD_ULOGIC;
    -- stall processor
    spearhold    : out STD_ULOGIC;
    -- AMBA-Interface
    AMBAI        : in  ahb_master_in_type;
    AMBAO        : out ahb_master_out_type;
    -- DRAM-Interface
    --ambadram_ren : out std_ulogic;

    AtD_write_en  : out std_ulogic;
    AtD_byte_en   : out std_logic_vector(3 downto 0);
    AtD_data_in   : out std_logic_vector(CONF.word_size-1 downto 0);
    AtD_addr      : out std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
    DtA_data_out  : in  std_logic_vector(CONF.word_size-1 downto 0)      
    );
end ext_AMBA;


architecture behaviour of ext_AMBA is

-- Controlsignals AMBA-Statemachine (for PortMap)
  signal BAtS : brg_amba_to_spear_type;
  signal BStA : brg_spear_to_amba_type;
  signal BStA_latched : brg_spear_to_amba_type;


  subtype BYTE is std_logic_vector(7 downto 0);
  type register_set is array (0 to 31) of BYTE;

-- StateMachine Control Signals
  type SM_Control_Sig is record
    lsHBUSREQ : STD_LOGIC;
    lsBADDR : STD_LOGIC_VECTOR (5 downto 0);
    lsHADDR : STD_LOGIC_VECTOR (31 downto 0);
    lsHWRITE : STD_LOGIC;
    lsHSIZE : STD_LOGIC_VECTOR (2 downto 0);
    lsWAIT : STD_LOGIC;
  end record;

  type reg_type is record
    ifacereg  : register_set;
    workinprogress : std_ulogic;
    Reg1inprogress : std_ulogic;
    Reg2inprogress : std_ulogic;
    SMCS : SM_Control_Sig;
    byte_en : std_logic_vector(3 downto 0);
    transmode : std_ulogic;
  end record;

  signal r, r_next : reg_type;
  signal rstint : std_ulogic;

begin

  -- Instance of AMBA-Statemachine
  -- direct PortMap of AMBA-Signals without possibility 
  --   of manipulation in this Designfile
  -- other signals are PortMaped to Signals for possibility
  --   of manipulation in this Designfile
  ASM_0 : AMBA_AHBMasterStatemachine
    port map(HRESET => rstint,
             HCLK => clk,
             -- AHB Master Inputs
             AMBAI => AMBAI,
             -- AHB Master Outputs
             AMBAO => AMBAO,
             -- Bridge AMBA-SPEAR Inputs
             BAtS => BAtS,
             -- Bridge AMBA-SPEAR Outputs
             BStA => BStA_latched
             );

  process(clk, rst)
  begin
    if rstint = RST_ACT then
	   BStA_latched.sMRDATA <= (others => '0');
      BStA_latched.sHBUSREQ <= '0';
      BStA_latched.sBADDR <= (others => '0');
      BStA_latched.sHADDR <= (others => '0');
      BStA_latched.sHWRITE <= '0';
      BStA_latched.sHSIZE <= (others => '0');
      BStA_latched.sWAIT <= '0';
    elsif rising_edge(clk) then
      BStA_latched <= BStA;
    end if;
  end process;
  
  -- Memorysignals to DRAM and back
  AtD_data_in <= BAtS.sMWDATA;
  AtD_addr(7 downto 2) <= BAtS.sMADDR(7 downto 2);
  AtD_write_en <= '1';
  AtD_byte_en(3 downto 0) <= BAtS.sByteEn(3 downto 0) when (r.transmode = '0') else (others => '0');
  BStA.sMRDATA <= DtA_data_out when (r.transmode = '0') else exti.data;


  BStA.sHBUSREQ <= r_next.SMCS.lsHBUSREQ;
  BStA.sBADDR(31 downto 8) <= (others => '0');
  BStA.sBADDR(7 downto 2) <= r_next.SMCS.lsBADDR(5 downto 0);
  BStA.sBADDR(1 downto 0) <= (others => '0');
  BStA.sHADDR <= r_next.SMCS.lsHADDR;
  BStA.sHWRITE <= r_next.SMCS.lsHWRITE;
  BStA.sHSIZE <= r_next.SMCS.lsHSIZE;
  BStA.sWAIT <= r_next.SMCS.lsWAIT;

-- Synchronous process 
  reg : process(clk, rstint)
  begin
    if rising_edge(clk) then
      if rstint = RST_ACT then
        for i in 0 to 31 loop
          r.ifacereg(i) <= (others => '0');
        end loop;
        r.workinprogress <= '0';
        r.Reg1inprogress <= '0';
        r.Reg2inprogress <= '0';
        r.SMCS.lsHBUSREQ <= '0';
        r.SMCS.lsBADDR <= (others => '0');
        r.SMCS.lsHADDR <= (others => '0');
        r.SMCS.lsHWRITE <= '0';
        r.SMCS.lsHSIZE <= (others => '0');
        r.SMCS.lsWAIT <= '0';
        r.byte_en <= (others => '0');
        r.transmode <= '0';
      else 
        -- Generic register assignment
        r <= r_next;
      end if;
    end if;
  end process;

  comb : process(r, exti, extsel, rst, BAtS, transmode, addr_high)
    variable v : reg_type;

  begin
    -- Default Values
    v := r;
    
    --Gaisler Interrupt handling
    -- has to be placed here because if placed below, interrupts can't be deleted!!!
    for i in BAtS.sIRQ'left downto BAtS.sIRQ'right loop
      v.ifacereg(CONFIGREG_CUST)(i) := r.ifacereg(CONFIGREG_CUST)(i) or BAtS.sIRQ(i);
    end loop;
    gIRQ <= r.ifacereg(CONFIGREG_CUST)(0) or r.ifacereg(CONFIGREG_CUST)(1) or
            r.ifacereg(CONFIGREG_CUST)(2) or r.ifacereg(CONFIGREG_CUST)(3) or
            r.ifacereg(CONFIGREG_CUST)(4) or r.ifacereg(CONFIGREG_CUST)(5) or
            r.ifacereg(CONFIGREG_CUST)(6) or r.ifacereg(CONFIGREG_CUST)(7);

    --write
    if ((extsel = '1') and (exti.write_en = '1') and (transmode = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          -- first 16 bit only
          if ((exti.byte_en(0) = '1') or (exti.byte_en(1) = '1')) then
            v.ifacereg(STATUSREG)(STA_INT) := '1';
            v.ifacereg(CONFIGREG)(CONF_INTA) :='0';
          else
            if ((exti.byte_en(2) = '1')) then
              v.ifacereg(2) := exti.data(23 downto 16);
            end if;
            if ((exti.byte_en(3) = '1')) then
              v.ifacereg(3) := exti.data(31 downto 24);
            end if;
          end if;
        when "001" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(4) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(5) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(6) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(7) := exti.data(31 downto 24);
          end if;
        when "010" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(8) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(9) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(10) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(11) := exti.data(31 downto 24);
          end if;
        when "011" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(12) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(13) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(14) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(15) := exti.data(31 downto 24);
          end if;
        when "100" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(16) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(17) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(18) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(19) := exti.data(31 downto 24);
          end if;
        when "101" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(20) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(21) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(22) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(23) := exti.data(31 downto 24);
          end if;
        when "110" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(24) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(25) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(26) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(27) := exti.data(31 downto 24);
          end if;
        when "111" =>
          if ((exti.byte_en(0) = '1')) then
            v.ifacereg(28) := exti.data(7 downto 0);
          end if;
          if ((exti.byte_en(1) = '1')) then
            v.ifacereg(29) := exti.data(15 downto 8);
          end if;
          if ((exti.byte_en(2) = '1')) then
            v.ifacereg(30) := exti.data(23 downto 16);
          end if;
          if ((exti.byte_en(3) = '1')) then
            v.ifacereg(31) := exti.data(31 downto 24);
          end if;
        when others =>
          null;
      end case;
    end if;

    --read
    exto.data <= (others => '0');
    if ((extsel = '1') and (exti.write_en = '0') and (transmode = '0')) then
      case exti.addr(4 downto 2) is
        when "000" =>
          exto.data <= r.ifacereg(3) & r.ifacereg(2) & r.ifacereg(1) & r.ifacereg(0);
        when "001" =>
          if (r.ifacereg(CONFIGREG)(CONF_ID) = '1') then
            exto.data <= MODULE_VER & MODULE_ID;
          else
            exto.data <= r.ifacereg(7) & r.ifacereg(6) & r.ifacereg(5) & r.ifacereg(4);
          end if;
        when "010" =>
          exto.data <= r.ifacereg(11) & r.ifacereg(10) & r.ifacereg(9) & r.ifacereg(8);
        when "011" =>
          exto.data <= r.ifacereg(15) & r.ifacereg(14) & r.ifacereg(13) & r.ifacereg(12);
        when "100" =>
          exto.data <= r.ifacereg(19) & r.ifacereg(18) & r.ifacereg(17) & r.ifacereg(16);
        when "101" =>
          exto.data <= r.ifacereg(23) & r.ifacereg(22) & r.ifacereg(21) & r.ifacereg(20);
        when "110" =>
          exto.data <= r.ifacereg(27) & r.ifacereg(26) & r.ifacereg(25) & r.ifacereg(24);
        when "111" =>
          exto.data <= r.ifacereg(31) & r.ifacereg(30) & r.ifacereg(29) & r.ifacereg(28);
        when others =>
          null;
      end case;
    end if;

    
    --compute new status
    v.ifacereg(STATUSREG)(STA_LOOR) := r.ifacereg(CONFIGREG)(CONF_LOOW);
    v.ifacereg(STATUSREG)(STA_FSS)  := '0';
    v.ifacereg(STATUSREG)(STA_RESH) := '0';
    v.ifacereg(STATUSREG)(STA_RESL) := '0';
    v.ifacereg(STATUSREG)(STA_BUSY) := '0';
    v.ifacereg(STATUSREG)(STA_ERR)  := '0';
    v.ifacereg(STATUSREG)(STA_RDY)  := '1';
    
    -- output is enabled by default 
    v.ifacereg(CONFIGREG)(CONF_OUTD) := '1';

    --merging soft- and hard-reset 
    rstint <= not RST_ACT;
    if rst = RST_ACT or r.ifacereg(CONFIGREG)(CONF_SRES) = '1' then
      rstint <= RST_ACT;
    end if;

    --interrupt handling 
    if r.ifacereg(STATUSREG)(STA_INT) = '1' and r.ifacereg(CONFIGREG)(CONF_INTA) = '0' then
      v.ifacereg(STATUSREG)(STA_INT) := '0';
    end if;
    exto.intreq <= r.ifacereg(STATUSREG)(STA_INT);
    

    -- Module Specific part
    
    if (transmode = '1') then
      spearhold <= '1';
    else
      spearhold <= '0';
    end if;
    
    ambadramlock <= '0';
    if r.workinprogress = '0' then
      -- transmode --> highest priority if nothing is in process
      --   set flag for transmode
      if (transmode = '1') then
        -- clear statusbits to prevent wrong information
        v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_T) := '0';
        v.ifacereg(STATUSREG_CUST)(STA_ERROR_T) := '0';
        v.transmode := '1';
        v.workinprogress := '1';
        -- generate Statemachinecontrolsignals
        v.SMCS.lsHBUSREQ := '1';
        v.SMCS.lsBADDR(5 downto 0) := (others => '0');
        v.SMCS.lsHADDR := addr_high(31 downto 15) & exti.addr(14 downto 0);
        case exti.byte_en is
          when "0001" =>
            v.SMCS.lsHSIZE := HSIZE_BYTE;
          when "0010" =>
            v.SMCS.lsHSIZE := HSIZE_BYTE;
          when "0100" =>
            v.SMCS.lsHSIZE := HSIZE_BYTE;
          when "1000" =>
            v.SMCS.lsHSIZE := HSIZE_BYTE;
          when "0011" =>
            v.SMCS.lsHSIZE := HSIZE_HWORD;
          when "1100" =>
            v.SMCS.lsHSIZE := HSIZE_HWORD;
          when "1111" =>
            v.SMCS.lsHSIZE := HSIZE_WORD;
          when others =>
            v.SMCS.lsHSIZE := HSIZE_WORD;
        end case;
        v.SMCS.lsWAIT := '0';
        v.SMCS.lsHWRITE := exti.write_en;
      elsif (r.ifacereg(SLOT1_CONFIG)(CFG_START) = '1') then
        v.workinprogress := '1';
        v.Reg1inprogress := '1';
        -- cleart Ready + Finished + Error Flags
        v.ifacereg(STATUSREG_CUST)(STA_READY_1) := '0';
        v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_1) := '0';
        v.ifacereg(STATUSREG_CUST)(STA_ERROR_1) := '0';
        -- clear Start-Flag
        v.ifacereg(SLOT1_CONFIG)(CFG_START) := '0';
        -- generate Statemachinecontrolsignals
        v.SMCS.lsHBUSREQ := '1';
        v.SMCS.lsBADDR(5 downto 0) := r.ifacereg(SLOT1_MEMOFFSET)(CFG_MEMOFFSET+5 downto CFG_MEMOFFSET);
        v.SMCS.lsHADDR := r.ifacereg(SLOT1_AMBAADDR+3) & r.ifacereg(SLOT1_AMBAADDR+2) & r.ifacereg(SLOT1_AMBAADDR+1) & r.ifacereg(SLOT1_AMBAADDR);
        v.SMCS.lsHSIZE := r.ifacereg(SLOT1_CONFIG)(CFG_ACCTYPE+2 downto CFG_ACCTYPE);
        v.SMCS.lsWAIT := '0';
        v.SMCS.lsHWRITE := r.ifacereg(SLOT1_CONFIG)(CFG_READ_WRITE);
      elsif (r.ifacereg(SLOT2_CONFIG)(CFG_START) = '1') then
        v.workinprogress := '1';
        v.Reg2inprogress := '1';
        -- cleart Ready + Finished + Error Flags
        v.ifacereg(STATUSREG_CUST)(STA_READY_2) := '0';
        v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_2) := '0';
        v.ifacereg(STATUSREG_CUST)(STA_ERROR_2) := '0';
        -- clear Start-Flag
        v.ifacereg(SLOT2_CONFIG)(CFG_START) := '0';
        -- generate Statemachinecontrolsignals
        v.SMCS.lsHBUSREQ := '1';
        v.SMCS.lsBADDR(5 downto 0) := r.ifacereg(SLOT2_MEMOFFSET)(CFG_MEMOFFSET+5 downto CFG_MEMOFFSET);
        v.SMCS.lsHADDR := r.ifacereg(SLOT2_AMBAADDR+3) & r.ifacereg(SLOT2_AMBAADDR+2) & r.ifacereg(SLOT2_AMBAADDR+1) & r.ifacereg(SLOT2_AMBAADDR);
        v.SMCS.lsHSIZE := r.ifacereg(SLOT2_CONFIG)(CFG_ACCTYPE+2 downto CFG_ACCTYPE);
        v.SMCS.lsWAIT := '0';
        v.SMCS.lsHWRITE := r.ifacereg(SLOT2_CONFIG)(CFG_READ_WRITE);
      end if;
    else
      ambadramlock <= '1';
      if (BAtS.sBusRequest = '1') then
        v.SMCS.lsHBUSREQ := '0';
      elsif BAtS.sERROR = '1' then
        if (r.transmode = '1') then
          v.transmode := '0';
          spearhold <= '0';
          v.workinprogress := '0';
          v.ifacereg(STATUSREG_CUST)(STA_ERROR_T) := '1';
        else
          if r.Reg1inprogress = '1' then
					-- set Ready + Error Flags
            v.ifacereg(STATUSREG_CUST)(STA_READY_1) := '1';
            v.ifacereg(STATUSREG_CUST)(STA_ERROR_1) := '1';
            v.workinprogress := '0';
            v.Reg1inprogress := '0';
          else
					-- set Ready + Error Flags
            v.ifacereg(STATUSREG_CUST)(STA_READY_2) := '1';
            v.ifacereg(STATUSREG_CUST)(STA_ERROR_2) := '1';
            v.workinprogress := '0';
            v.Reg2inprogress := '0';
          end if;
        end if;
      elsif BAtS.sFinished = '1' then
        if (r.transmode = '1') then
          v.transmode := '0';
          spearhold <= '0';
          v.workinprogress := '0';
          v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_T) := '1';
          exto.data <= BAtS.sMWDATA;
        else
          if r.Reg1inprogress = '1' then
            v.Reg1inprogress := '0';
            v.workinprogress := '0';
					-- set Ready + Finished Flags
            v.ifacereg(STATUSREG_CUST)(STA_READY_1) := '1';
            v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_1) := '1';
					-- generate Interrupt
            if r.ifacereg(SLOT1_CONFIG)(CFG_MASKINT) = '0' then
              exto.intreq <= '1';
            end if;
          else
            v.Reg2inprogress := '0';
            v.workinprogress := '0';
					-- set Ready + Finished Flags
            v.ifacereg(STATUSREG_CUST)(STA_READY_2) := '1';
            v.ifacereg(STATUSREG_CUST)(STA_SUCCESS_2) := '1';
					-- generate Interrupt
            if r.ifacereg(SLOT2_CONFIG)(CFG_MASKINT) = '0' then
              exto.intreq <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;
    
    r_next <= v;
  end process;
  
end behaviour;
