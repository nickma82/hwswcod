-----------------------------------------------------------------------------
-- Author:      Nick Mayerhofer
-- Description: synchronous RAM with generic width, dual write/read clock
-- Date:		08.06.2011
-----------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

---- RAM
entity dp_ram is
	generic
	(
		ADDR_WIDTH : integer range 1 to integer'high;
		DATA_WIDTH : integer range 1 to integer'high
	);
	port
	(
		wrclk       : in std_logic;
		wen			: in std_logic;
		wraddress 	: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wrdata_in 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		
		rdclk		: in std_logic;
		rdaddress 	: in std_logic_vector(ADDR_WIDTH -  1 downto 0);
		rddata_out 	: out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end entity dp_ram;

architecture beh of dp_ram is
	subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
	type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) - 1) of RAM_ENTRY_TYPE;
	signal ram : RAM_TYPE := (others => (others => '0'));
begin
	
	read : process(rdclk)
	begin
		if rising_edge(rdclk) then
			rddata_out <= ram(to_integer(unsigned(rdaddress)));
		end if;
	end process;

	write : process(wrclk)
	begin
		if rising_edge(wrclk) then
			if wen = '1' then
				ram(to_integer(unsigned(wraddress))) <= wrdata_in;
			end if;
		end if;
	end process;
	
end architecture beh;
