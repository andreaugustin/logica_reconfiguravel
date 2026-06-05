library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entrada e saida de 8 bits;
-- armazenamento de 16 bytes (0 a 15);
entity fifo is
	port(
		clk		: in std_logic;
		rst		: in std_logic;
		rd_en 	: in std_logic;
		data_in	: in std_logic_vector(7 downto 0);
		wr_en		: in std_logic;
		empty		: out std_logic;
		full		: out std_logic;
		data_out : out std_logic_vector(7 downto 0)
		);
end entity;

architecture a_fifo of fifo is
	type memory_type is array(15 downto 0) of std_logic_vector(7 downto 0);
	signal memory : memory_type := (others => (others => '0'));
	
	signal wr_ptr : integer range 0 to 15 := 0; 
	signal rd_ptr : integer range 0 to 15 := 0; 
	signal count  : integer range 0 to 16 := 0; 
	
begin
	empty <= '1' when count = 0 else '0';
	full  <= '1' when count = 16 else '0';
	
	process(clk, rst)
	begin
		if rst = '1' then
			wr_ptr   <= 0;
			rd_ptr   <= 0;
			data_out <= (others => '0');
			count    <= 0;
			
		elsif rising_edge(clk) then
			-- escrita:
			if (wr_en = '1' and count < 16) then
				memory(wr_ptr) <= data_in;
				if wr_ptr = 15 then 
					wr_ptr <= 0;    
				else
					wr_ptr <= wr_ptr + 1;
				end if;
			end if;
				
			-- leitura:
			if (rd_en = '1' and count > 0) then
				data_out <= memory(rd_ptr);
				if rd_ptr = 15 then 
					rd_ptr <= 0;    
				else
					rd_ptr <= rd_ptr + 1;
				end if;
			end if;
				
			-- contador:
			if (wr_en = '1' and count < 16 and rd_en = '0') then
				count <= count + 1;
				
			elsif (wr_en = '1' and count < 16 and rd_en = '1') then
				null; 
			
			elsif (wr_en = '0' and count > 0 and rd_en = '1') then
				count <= count - 1; 
			
			else
				null;
			end if;
            
		end if; 
	end process;
	
end architecture;