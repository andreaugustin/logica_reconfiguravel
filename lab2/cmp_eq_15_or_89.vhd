library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cmp_eq_15_or_89 is
    port(
        value_unit: in unsigned(3 downto 0); 
        value_ten: in unsigned(3 downto 0); 
        is_equal: out std_logic);
end entity;

architecture a_cmp_eq_15_or_89 of cmp_eq_15_or_89 is
    begin
        is_equal <= '1' when (value_unit = "1001" and value_ten = "1000") else
                    '1' when (value_ten = "0000") or
                             (value_ten = "0001" and value_unit < "0101") else 
                    '0';
end architecture;
