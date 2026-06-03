library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compressor is
    port(
        clk: in std_logic;
        rst: in std_logic;
        data_in : in  std_logic_vector(7 downto 0); 
        data_out : out std_logic_vector(7 downto 0)
    );
end entity;

architecture a_compressor of compressor is
    signal temp: std_logic_vector(7 downto 0) := "00000000";
    begin
        process(clk, rst)
        begin
            if rst = '1' then
                temp <= "00000000";
            elsif rising_edge(clk) then
                temp <= data_in;
            end if;
        end process;
        data_out <= temp;
end architecture;

