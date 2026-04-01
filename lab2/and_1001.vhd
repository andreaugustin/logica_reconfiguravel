library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity and_1001 is
    port(
        entrada: in unsigned(3 downto 0);
        saida: out std_logic);
end entity;

architecture a_and_1001 of and_1001 is
    begin
        saida <= '1' when entrada = "1001" else '0';
end architecture;

            