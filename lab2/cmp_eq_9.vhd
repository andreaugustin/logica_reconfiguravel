library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cmp_eq_9 is
    port(
        value: in unsigned(3 downto 0);
        is_equal: out std_logic);
end entity;

architecture a_cmp_eq_9 of cmp_eq_9 is
    begin
        is_equal <= '1' when value = "1001" else '0';
end architecture;

            