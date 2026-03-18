library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        -- clr: in std_logic; -- tirei pq ainda n sei como funciona esse cara
        saida: out unsigned(3 downto 0));
end entity;

architecture a_contador of contador is

    signal saida_s: unsigned(3 downto 0) := "0000"; -- n tenho certeza se precisa inicilizar
    
    begin
        process(clk, rst)
        begin
            if rst = '1' then
                saida_s <= "0000";
            elsif en = '1' then -- talvez seja interessante deixar esse en dps do clk
                if rising_edge(clk) then
                    if saida_s = "1111" then
                        saida_s <= "0000";
                    else
                        saida_s <= saida_s+1;
                    end if;
                end if;
            end if;
        end process;
        saida <= saida_s;
end architecture;

            