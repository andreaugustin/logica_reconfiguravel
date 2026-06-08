library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram is
	-- tipo um define
    generic (
        ADDR_WIDTH : integer := 11;  -- 2^11 = 2048 posições de memória
        DATA_WIDTH : integer := 8    -- 1 byte por posição
    );
    port (
        clk        : in  std_logic;
        we_en      : in  std_logic;
        address    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        pixel_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of bram is
    type ram_type is array (0 to (2**ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we_en = '1' then
                ram(to_integer(unsigned(address))) <= data_in;
            end if;
            read_data <= ram(to_integer(unsigned(address)));
        end if;
    end process;

    data_out  <= read_data;
    pixel_out <= read_data;

end architecture;