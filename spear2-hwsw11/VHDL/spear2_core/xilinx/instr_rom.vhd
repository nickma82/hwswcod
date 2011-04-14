library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.spear_core_pkg.all;
use work.spear_pkg.all;

use work.final_rom_pkg.all;

library unisim;
    use unisim.vcomponents.all;

entity xilinx_instr_rom is
  port (
    clk   : in  std_ulogic;
    enable  : in  std_ulogic;
    addr  : in  std_logic_vector(15 downto 0);
    data  : out std_logic_vector(15 downto 0)
    );
end xilinx_instr_rom;

architecture behaviour of xilinx_instr_rom is


begin


   instr_rom_0 : RAMB16_S4
   generic map (
      INIT => X"0", --  Value of output RAM registers at startup
      SRVAL => X"0", --  Ouput value upon SSR assertion
      WRITE_MODE => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 1023
      INIT_00 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_00,
      INIT_01 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_01,
      INIT_02 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_02,
      INIT_03 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_03,
      INIT_04 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_04,
      INIT_05 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_05,
      INIT_06 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_06,
      INIT_07 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_07,
      INIT_08 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_08,
      INIT_09 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_09,
      INIT_0A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0A,
      INIT_0B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0B,
      INIT_0C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0C,
      INIT_0D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0D,
      INIT_0E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0E,
      INIT_0F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_0F,
      -- Address 1024 to 2047
      INIT_10 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_10,
      INIT_11 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_11,
      INIT_12 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_12,
      INIT_13 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_13,
      INIT_14 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_14,
      INIT_15 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_15,
      INIT_16 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_16,
      INIT_17 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_17,
      INIT_18 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_18,
      INIT_19 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_19,
      INIT_1A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1A,
      INIT_1B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1B,
      INIT_1C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1C,
      INIT_1D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1D,
      INIT_1E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1E,
      INIT_1F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_1F,
      -- Address 2048 to 3071
      INIT_20 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_20,
      INIT_21 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_21,
      INIT_22 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_22,
      INIT_23 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_23,
      INIT_24 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_24,
      INIT_25 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_25,
      INIT_26 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_26,
      INIT_27 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_27,
      INIT_28 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_28,
      INIT_29 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_29,
      INIT_2A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2A,
      INIT_2B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2B,
      INIT_2C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2C,
      INIT_2D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2D,
      INIT_2E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2E,
      INIT_2F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_2F,
      -- Address 3072 to 4095
      INIT_30 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_30,
      INIT_31 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_31,
      INIT_32 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_32,
      INIT_33 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_33,
      INIT_34 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_34,
      INIT_35 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_35,
      INIT_36 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_36,
      INIT_37 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_37,
      INIT_38 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_38,
      INIT_39 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_39,
      INIT_3A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3A,
      INIT_3B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3B,
      INIT_3C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3C,
      INIT_3D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3D,
      INIT_3E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3E,
      INIT_3F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_0_INIT_3F)
   port map (
      DO => data(3 downto 0),   -- 4-bit Data Output
      ADDR => addr(11 downto 0),             -- 12-bit Address Input
      CLK => clk,               -- Clock
      DI => (others => '0'),    -- 4-bit Data Input
      EN => enable,                -- RAM Enable Input
      SSR => '0',               -- Synchronous Set/Reset Input
      WE => '0'                 -- Write Enable Input
   );

   instr_rom_1 : RAMB16_S4
   generic map (
      INIT => X"0", --  Value of output RAM registers at startup
      SRVAL => X"0", --  Ouput value upon SSR assertion
      WRITE_MODE => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 1023
      INIT_00 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_00,
      INIT_01 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_01,
      INIT_02 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_02,
      INIT_03 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_03,
      INIT_04 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_04,
      INIT_05 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_05,
      INIT_06 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_06,
      INIT_07 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_07,
      INIT_08 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_08,
      INIT_09 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_09,
      INIT_0A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0A,
      INIT_0B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0B,
      INIT_0C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0C,
      INIT_0D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0D,
      INIT_0E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0E,
      INIT_0F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_0F,
      -- Address 1024 to 2047
      INIT_10 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_10,
      INIT_11 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_11,
      INIT_12 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_12,
      INIT_13 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_13,
      INIT_14 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_14,
      INIT_15 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_15,
      INIT_16 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_16,
      INIT_17 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_17,
      INIT_18 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_18,
      INIT_19 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_19,
      INIT_1A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1A,
      INIT_1B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1B,
      INIT_1C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1C,
      INIT_1D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1D,
      INIT_1E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1E,
      INIT_1F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_1F,
      -- Address 2048 to 3071
      INIT_20 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_20,
      INIT_21 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_21,
      INIT_22 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_22,
      INIT_23 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_23,
      INIT_24 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_24,
      INIT_25 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_25,
      INIT_26 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_26,
      INIT_27 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_27,
      INIT_28 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_28,
      INIT_29 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_29,
      INIT_2A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2A,
      INIT_2B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2B,
      INIT_2C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2C,
      INIT_2D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2D,
      INIT_2E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2E,
      INIT_2F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_2F,
      -- Address 3072 to 4095
      INIT_30 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_30,
      INIT_31 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_31,
      INIT_32 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_32,
      INIT_33 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_33,
      INIT_34 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_34,
      INIT_35 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_35,
      INIT_36 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_36,
      INIT_37 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_37,
      INIT_38 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_38,
      INIT_39 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_39,
      INIT_3A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3A,
      INIT_3B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3B,
      INIT_3C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3C,
      INIT_3D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3D,
      INIT_3E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3E,
      INIT_3F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_1_INIT_3F)
   port map (
      DO => data(7 downto 4),   -- 4-bit Data Output
      ADDR => addr(11 downto 0),             -- 12-bit Address Input
      CLK => clk,               -- Clock
      DI => (others => '0'),    -- 4-bit Data Input
      EN => enable,                -- RAM Enable Input
      SSR => '0',               -- Synchronous Set/Reset Input
      WE => '0'                 -- Write Enable Input
   );

   instr_rom_2 : RAMB16_S4
   generic map (
      INIT => X"0", --  Value of output RAM registers at startup
      SRVAL => X"0", --  Ouput value upon SSR assertion
      WRITE_MODE => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 1023
      INIT_00 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_00,
      INIT_01 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_01,
      INIT_02 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_02,
      INIT_03 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_03,
      INIT_04 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_04,
      INIT_05 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_05,
      INIT_06 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_06,
      INIT_07 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_07,
      INIT_08 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_08,
      INIT_09 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_09,
      INIT_0A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0A,
      INIT_0B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0B,
      INIT_0C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0C,
      INIT_0D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0D,
      INIT_0E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0E,
      INIT_0F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_0F,
      -- Address 1024 to 2047
      INIT_10 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_10,
      INIT_11 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_11,
      INIT_12 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_12,
      INIT_13 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_13,
      INIT_14 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_14,
      INIT_15 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_15,
      INIT_16 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_16,
      INIT_17 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_17,
      INIT_18 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_18,
      INIT_19 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_19,
      INIT_1A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1A,
      INIT_1B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1B,
      INIT_1C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1C,
      INIT_1D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1D,
      INIT_1E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1E,
      INIT_1F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_1F,
      -- Address 2048 to 3071
      INIT_20 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_20,
      INIT_21 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_21,
      INIT_22 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_22,
      INIT_23 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_23,
      INIT_24 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_24,
      INIT_25 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_25,
      INIT_26 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_26,
      INIT_27 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_27,
      INIT_28 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_28,
      INIT_29 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_29,
      INIT_2A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2A,
      INIT_2B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2B,
      INIT_2C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2C,
      INIT_2D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2D,
      INIT_2E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2E,
      INIT_2F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_2F,
      -- Address 3072 to 4095
      INIT_30 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_30,
      INIT_31 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_31,
      INIT_32 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_32,
      INIT_33 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_33,
      INIT_34 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_34,
      INIT_35 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_35,
      INIT_36 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_36,
      INIT_37 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_37,
      INIT_38 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_38,
      INIT_39 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_39,
      INIT_3A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3A,
      INIT_3B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3B,
      INIT_3C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3C,
      INIT_3D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3D,
      INIT_3E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3E,
      INIT_3F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_2_INIT_3F)
   port map (
      DO => data(11 downto 8),   -- 4-bit Data Output
      ADDR => addr(11 downto 0),             -- 12-bit Address Input
      CLK => clk,               -- Clock
      DI => (others => '0'),    -- 4-bit Data Input
      EN => enable,                -- RAM Enable Input
      SSR => '0',               -- Synchronous Set/Reset Input
      WE => '0'                 -- Write Enable Input
   );

   instr_rom_3 : RAMB16_S4
   generic map (
      INIT => X"0", --  Value of output RAM registers at startup
      SRVAL => X"0", --  Ouput value upon SSR assertion
      WRITE_MODE => "WRITE_FIRST", --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 1023
      INIT_00 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_00,
      INIT_01 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_01,
      INIT_02 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_02,
      INIT_03 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_03,
      INIT_04 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_04,
      INIT_05 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_05,
      INIT_06 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_06,
      INIT_07 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_07,
      INIT_08 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_08,
      INIT_09 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_09,
      INIT_0A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0A,
      INIT_0B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0B,
      INIT_0C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0C,
      INIT_0D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0D,
      INIT_0E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0E,
      INIT_0F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_0F,
      -- Address 1024 to 2047
      INIT_10 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_10,
      INIT_11 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_11,
      INIT_12 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_12,
      INIT_13 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_13,
      INIT_14 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_14,
      INIT_15 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_15,
      INIT_16 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_16,
      INIT_17 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_17,
      INIT_18 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_18,
      INIT_19 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_19,
      INIT_1A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1A,
      INIT_1B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1B,
      INIT_1C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1C,
      INIT_1D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1D,
      INIT_1E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1E,
      INIT_1F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_1F,
      -- Address 2048 to 3071
      INIT_20 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_20,
      INIT_21 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_21,
      INIT_22 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_22,
      INIT_23 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_23,
      INIT_24 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_24,
      INIT_25 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_25,
      INIT_26 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_26,
      INIT_27 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_27,
      INIT_28 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_28,
      INIT_29 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_29,
      INIT_2A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2A,
      INIT_2B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2B,
      INIT_2C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2C,
      INIT_2D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2D,
      INIT_2E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2E,
      INIT_2F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_2F,
      -- Address 3072 to 4095
      INIT_30 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_30,
      INIT_31 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_31,
      INIT_32 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_32,
      INIT_33 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_33,
      INIT_34 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_34,
      INIT_35 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_35,
      INIT_36 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_36,
      INIT_37 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_37,
      INIT_38 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_38,
      INIT_39 => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_39,
      INIT_3A => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3A,
      INIT_3B => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3B,
      INIT_3C => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3C,
      INIT_3D => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3D,
      INIT_3E => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3E,
      INIT_3F => spear2_comp_brom_unit_xilinx_gen_instr_rom_inst_instr_rom_3_INIT_3F)
   port map (
      DO => data(15 downto 12),   -- 4-bit Data Output
      ADDR => addr(11 downto 0),             -- 12-bit Address Input
      CLK => clk,               -- Clock
      DI => (others => '0'),    -- 4-bit Data Input
      EN => enable,                -- RAM Enable Input
      SSR => '0',               -- Synchronous Set/Reset Input
      WE => '0'                 -- Write Enable Input
   );

							

end behaviour;






















































