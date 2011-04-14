library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

use work.final_dram_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity xilinx_data_ram is
  port (
    clk     : in  std_ulogic;
    enable  : in  std_ulogic;
    ram0i   : in  byteram_in_type;
    ram0o   : out byteram_out_type;
    ram1i   : in  byteram_in_type;
    ram1o   : out byteram_out_type;
    ram2i   : in  byteram_in_type;
    ram2o   : out byteram_out_type;
    ram3i   : in  byteram_in_type;
    ram3o   : out byteram_out_type
    );
end xilinx_data_ram;

architecture behaviour of xilinx_data_ram is


begin


   data_ram_0 : RAMB16_S9_S9
   generic map (
      INIT_A => X"000", --  Value of output RAM registers on Port A at startup
      INIT_B => X"000", --  Value of output RAM registers on Port B at startup
      SRVAL_A => X"000", --  Port A ouput value upon SSR assertion
      SRVAL_B => X"000", --  Port B ouput value upon SSR assertion
      WRITE_MODE_A => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL", -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL" 
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 511
      INIT_00 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_00,
      INIT_01 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_01,
      INIT_02 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_02,
      INIT_03 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_03,
      INIT_04 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_04,
      INIT_05 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_05,
      INIT_06 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_06,
      INIT_07 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_07,
      INIT_08 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_08,
      INIT_09 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_09,
      INIT_0A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0A,
      INIT_0B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0B,
      INIT_0C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0C,
      INIT_0D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0D,
      INIT_0E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0E,
      INIT_0F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_0F,
      INIT_10 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_10,
      INIT_11 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_11,
      INIT_12 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_12,
      INIT_13 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_13,
      INIT_14 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_14,
      INIT_15 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_15,
      INIT_16 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_16,
      INIT_17 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_17,
      INIT_18 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_18,
      INIT_19 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_19,
      INIT_1A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1A,
      INIT_1B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1B,
      INIT_1C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1C,
      INIT_1D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1D,
      INIT_1E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1E,
      INIT_1F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_1F,
      INIT_20 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_20,
      INIT_21 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_21,
      INIT_22 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_22,
      INIT_23 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_23,
      INIT_24 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_24,
      INIT_25 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_25,
      INIT_26 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_26,
      INIT_27 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_27,
      INIT_28 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_28,
      INIT_29 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_29,
      INIT_2A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2A,
      INIT_2B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2B,
      INIT_2C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2C,
      INIT_2D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2D,
      INIT_2E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2E,
      INIT_2F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_2F,
      INIT_30 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_30,
      INIT_31 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_31,
      INIT_32 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_32,
      INIT_33 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_33,
      INIT_34 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_34,
      INIT_35 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_35,
      INIT_36 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_36,
      INIT_37 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_37,
      INIT_38 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_38,
      INIT_39 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_39,
      INIT_3A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3A,
      INIT_3B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3B,
      INIT_3C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3C,
      INIT_3D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3D,
      INIT_3E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3E,
      INIT_3F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_0_INIT_3F,
      -- The next set of INITP_xx are for the parity bits
      -- Address 0 to 511
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 1023
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1024 to 1535
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1536 to 2047
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => open,            -- Port A 8-bit Data Output
      DOB => ram0o.data,      -- Port B 8-bit Data Output
      DOPA => open,           -- Port A 1-bit Parity Output
      DOPB => open,           -- Port B 1-bit Parity Output
      ADDRA => ram0i.waddr,   -- Port A 11-bit Address Input
      ADDRB => ram0i.raddr,   -- Port B 11-bit Address Input
      CLKA => clk,            -- Port A Clock
      CLKB => clk,            -- Port B Clock
      DIA => ram0i.wdata,     -- Port A 8-bit Data Input
      DIB => (others => '0'), -- Port B 8-bit Data Input
      DIPA => (others => '0'),-- Port A 1-bit parity Input
      DIPB => (others => '0'),-- Port-B 1-bit parity Input
      ENA => enable,             -- Port A RAM Enable Input
      ENB => enable,             -- PortB RAM Enable Input
      SSRA => '0',            -- Port A Synchronous Set/Reset Input
      SSRB => '0',            -- Port B Synchronous Set/Reset Input
      WEA => ram0i.wen,       -- Port A Write Enable Input
      WEB => '0'              -- Port B Write Enable Input
   );

   data_ram_1 : RAMB16_S9_S9
   generic map (
      INIT_A => X"000", --  Value of output RAM registers on Port A at startup
      INIT_B => X"000", --  Value of output RAM registers on Port B at startup
      SRVAL_A => X"000", --  Port A ouput value upon SSR assertion
      SRVAL_B => X"000", --  Port B ouput value upon SSR assertion
      WRITE_MODE_A => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL", -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL" 
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 511
      INIT_00 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_00,
      INIT_01 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_01,
      INIT_02 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_02,
      INIT_03 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_03,
      INIT_04 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_04,
      INIT_05 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_05,
      INIT_06 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_06,
      INIT_07 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_07,
      INIT_08 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_08,
      INIT_09 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_09,
      INIT_0A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0A,
      INIT_0B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0B,
      INIT_0C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0C,
      INIT_0D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0D,
      INIT_0E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0E,
      INIT_0F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_0F,
      INIT_10 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_10,
      INIT_11 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_11,
      INIT_12 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_12,
      INIT_13 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_13,
      INIT_14 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_14,
      INIT_15 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_15,
      INIT_16 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_16,
      INIT_17 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_17,
      INIT_18 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_18,
      INIT_19 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_19,
      INIT_1A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1A,
      INIT_1B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1B,
      INIT_1C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1C,
      INIT_1D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1D,
      INIT_1E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1E,
      INIT_1F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_1F,
      INIT_20 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_20,
      INIT_21 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_21,
      INIT_22 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_22,
      INIT_23 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_23,
      INIT_24 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_24,
      INIT_25 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_25,
      INIT_26 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_26,
      INIT_27 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_27,
      INIT_28 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_28,
      INIT_29 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_29,
      INIT_2A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2A,
      INIT_2B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2B,
      INIT_2C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2C,
      INIT_2D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2D,
      INIT_2E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2E,
      INIT_2F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_2F,
      INIT_30 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_30,
      INIT_31 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_31,
      INIT_32 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_32,
      INIT_33 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_33,
      INIT_34 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_34,
      INIT_35 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_35,
      INIT_36 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_36,
      INIT_37 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_37,
      INIT_38 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_38,
      INIT_39 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_39,
      INIT_3A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3A,
      INIT_3B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3B,
      INIT_3C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3C,
      INIT_3D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3D,
      INIT_3E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3E,
      INIT_3F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_1_INIT_3F,
      -- The next set of INITP_xx are for the parity bits
      -- Address 0 to 511
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 1023
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1024 to 1535
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1536 to 2047
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => open,            -- Port A 8-bit Data Output
      DOB => ram1o.data,      -- Port B 8-bit Data Output
      DOPA => open,           -- Port A 1-bit Parity Output
      DOPB => open,           -- Port B 1-bit Parity Output
      ADDRA => ram1i.waddr,   -- Port A 11-bit Address Input
      ADDRB => ram1i.raddr,   -- Port B 11-bit Address Input
      CLKA => clk,            -- Port A Clock
      CLKB => clk,            -- Port B Clock
      DIA => ram1i.wdata,     -- Port A 8-bit Data Input
      DIB => (others => '0'), -- Port B 8-bit Data Input
      DIPA => (others => '0'),-- Port A 1-bit parity Input
      DIPB => (others => '0'),-- Port-B 1-bit parity Input
      ENA => enable,             -- Port A RAM Enable Input
      ENB => enable,             -- PortB RAM Enable Input
      SSRA => '0',            -- Port A Synchronous Set/Reset Input
      SSRB => '0',            -- Port B Synchronous Set/Reset Input
      WEA => ram1i.wen,       -- Port A Write Enable Input
      WEB => '0'              -- Port B Write Enable Input
   );

   data_ram_2 : RAMB16_S9_S9
   generic map (
      INIT_A => X"000", --  Value of output RAM registers on Port A at startup
      INIT_B => X"000", --  Value of output RAM registers on Port B at startup
      SRVAL_A => X"000", --  Port A ouput value upon SSR assertion
      SRVAL_B => X"000", --  Port B ouput value upon SSR assertion
      WRITE_MODE_A => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL", -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL" 
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 511
      INIT_00 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_00,
      INIT_01 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_01,
      INIT_02 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_02,
      INIT_03 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_03,
      INIT_04 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_04,
      INIT_05 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_05,
      INIT_06 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_06,
      INIT_07 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_07,
      INIT_08 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_08,
      INIT_09 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_09,
      INIT_0A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0A,
      INIT_0B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0B,
      INIT_0C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0C,
      INIT_0D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0D,
      INIT_0E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0E,
      INIT_0F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_0F,
      INIT_10 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_10,
      INIT_11 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_11,
      INIT_12 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_12,
      INIT_13 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_13,
      INIT_14 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_14,
      INIT_15 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_15,
      INIT_16 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_16,
      INIT_17 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_17,
      INIT_18 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_18,
      INIT_19 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_19,
      INIT_1A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1A,
      INIT_1B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1B,
      INIT_1C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1C,
      INIT_1D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1D,
      INIT_1E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1E,
      INIT_1F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_1F,
      INIT_20 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_20,
      INIT_21 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_21,
      INIT_22 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_22,
      INIT_23 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_23,
      INIT_24 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_24,
      INIT_25 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_25,
      INIT_26 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_26,
      INIT_27 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_27,
      INIT_28 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_28,
      INIT_29 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_29,
      INIT_2A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2A,
      INIT_2B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2B,
      INIT_2C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2C,
      INIT_2D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2D,
      INIT_2E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2E,
      INIT_2F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_2F,
      INIT_30 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_30,
      INIT_31 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_31,
      INIT_32 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_32,
      INIT_33 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_33,
      INIT_34 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_34,
      INIT_35 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_35,
      INIT_36 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_36,
      INIT_37 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_37,
      INIT_38 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_38,
      INIT_39 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_39,
      INIT_3A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3A,
      INIT_3B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3B,
      INIT_3C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3C,
      INIT_3D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3D,
      INIT_3E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3E,
      INIT_3F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_2_INIT_3F,
      -- The next set of INITP_xx are for the parity bits
      -- Address 0 to 511
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 1023
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1024 to 1535
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1536 to 2047
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => open,            -- Port A 8-bit Data Output
      DOB => ram2o.data,      -- Port B 8-bit Data Output
      DOPA => open,           -- Port A 1-bit Parity Output
      DOPB => open,           -- Port B 1-bit Parity Output
      ADDRA => ram2i.waddr,   -- Port A 11-bit Address Input
      ADDRB => ram2i.raddr,   -- Port B 11-bit Address Input
      CLKA => clk,            -- Port A Clock
      CLKB => clk,            -- Port B Clock
      DIA => ram2i.wdata,     -- Port A 8-bit Data Input
      DIB => (others => '0'), -- Port B 8-bit Data Input
      DIPA => (others => '0'),-- Port A 1-bit parity Input
      DIPB => (others => '0'),-- Port-B 1-bit parity Input
      ENA => enable,             -- Port A RAM Enable Input
      ENB => enable,             -- PortB RAM Enable Input
      SSRA => '0',            -- Port A Synchronous Set/Reset Input
      SSRB => '0',            -- Port B Synchronous Set/Reset Input
      WEA => ram2i.wen,       -- Port A Write Enable Input
      WEB => '0'              -- Port B Write Enable Input
   );

   data_ram_3 : RAMB16_S9_S9
   generic map (
      INIT_A => X"000", --  Value of output RAM registers on Port A at startup
      INIT_B => X"000", --  Value of output RAM registers on Port B at startup
      SRVAL_A => X"000", --  Port A ouput value upon SSR assertion
      SRVAL_B => X"000", --  Port B ouput value upon SSR assertion
      WRITE_MODE_A => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B => "READ_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL", -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL" 
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 511
      INIT_00 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_00,
      INIT_01 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_01,
      INIT_02 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_02,
      INIT_03 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_03,
      INIT_04 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_04,
      INIT_05 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_05,
      INIT_06 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_06,
      INIT_07 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_07,
      INIT_08 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_08,
      INIT_09 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_09,
      INIT_0A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0A,
      INIT_0B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0B,
      INIT_0C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0C,
      INIT_0D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0D,
      INIT_0E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0E,
      INIT_0F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_0F,
      INIT_10 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_10,
      INIT_11 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_11,
      INIT_12 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_12,
      INIT_13 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_13,
      INIT_14 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_14,
      INIT_15 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_15,
      INIT_16 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_16,
      INIT_17 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_17,
      INIT_18 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_18,
      INIT_19 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_19,
      INIT_1A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1A,
      INIT_1B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1B,
      INIT_1C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1C,
      INIT_1D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1D,
      INIT_1E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1E,
      INIT_1F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_1F,
      INIT_20 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_20,
      INIT_21 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_21,
      INIT_22 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_22,
      INIT_23 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_23,
      INIT_24 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_24,
      INIT_25 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_25,
      INIT_26 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_26,
      INIT_27 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_27,
      INIT_28 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_28,
      INIT_29 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_29,
      INIT_2A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2A,
      INIT_2B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2B,
      INIT_2C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2C,
      INIT_2D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2D,
      INIT_2E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2E,
      INIT_2F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_2F,
      INIT_30 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_30,
      INIT_31 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_31,
      INIT_32 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_32,
      INIT_33 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_33,
      INIT_34 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_34,
      INIT_35 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_35,
      INIT_36 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_36,
      INIT_37 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_37,
      INIT_38 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_38,
      INIT_39 => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_39,
      INIT_3A => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3A,
      INIT_3B => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3B,
      INIT_3C => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3C,
      INIT_3D => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3D,
      INIT_3E => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3E,
      INIT_3F => spear2_comp_dram_unit_xilinx_gen_data_ram_inst_data_ram_3_INIT_3F,
      -- The next set of INITP_xx are for the parity bits
      -- Address 0 to 511
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 1023
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1024 to 1535
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 1536 to 2047
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => open,            -- Port A 8-bit Data Output
      DOB => ram3o.data,      -- Port B 8-bit Data Output
      DOPA => open,           -- Port A 1-bit Parity Output
      DOPB => open,           -- Port B 1-bit Parity Output
      ADDRA => ram3i.waddr,   -- Port A 11-bit Address Input
      ADDRB => ram3i.raddr,   -- Port B 11-bit Address Input
      CLKA => clk,            -- Port A Clock
      CLKB => clk,            -- Port B Clock
      DIA => ram3i.wdata,     -- Port A 8-bit Data Input
      DIB => (others => '0'), -- Port B 8-bit Data Input
      DIPA => (others => '0'),-- Port A 1-bit parity Input
      DIPB => (others => '0'),-- Port-B 1-bit parity Input
      ENA => enable,             -- Port A RAM Enable Input
      ENB => enable,             -- PortB RAM Enable Input
      SSRA => '0',            -- Port A Synchronous Set/Reset Input
      SSRB => '0',            -- Port B Synchronous Set/Reset Input
      WEA => ram3i.wen,       -- Port A Write Enable Input
      WEB => '0'              -- Port B Write Enable Input
   );

							

end behaviour;






















































