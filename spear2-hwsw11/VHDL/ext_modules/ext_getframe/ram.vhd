-----------------------------------------------------------------------------
-- Author:      Nick Mayerhofer
-- Description: Asynchronous FIFO with generic width
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
			ram(to_integer(unsigned(wraddress))) <= wrdata_in;
		end if;
	end process;
	
end architecture beh;


--library ieee; 
--use ieee.std_logic_1164.all; 
--use ieee.numeric_std.all;
--
--USE ieee.math_real.log2;
--USE ieee.math_real.ceil;
--
------ FIFO
--entity async_fifo is
--	generic
--	(
--		BUFFER_LENGTH : integer range 1 to integer'high;
--		DATA_WIDTH : integer range 1 to integer'high
--	);
--	port
--	(
--		--global
--		reset		: in std_logic;
--		fifo_empty	: out std_logic;
--		fifo_full	: out std_logic;
--		--in
--		i_data 		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
--		i_en		: in  std_logic;
--		i_val       : out std_logic;
--		--out
--		o_data	 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
--		o_en		: in  std_logic;
--		o_val       : out std_logic
--		
--	);
--end entity async_fifo;
--
--
--architecture afifo of async_fifo is
--	--#calc ADDD = (BUFFER_LENGTH//2)/(2//2)
--	constant  ADDRESS_WIDTH : integer := INTEGER(CEIL( LOG2(REAL(BUFFER_LENGTH-1))/LOG2(REAL(2)) ));
--	
--	signal tmp_reset : std_logic;
--begin
--	tmp_reset <= reset;
--end architecture afifo;
