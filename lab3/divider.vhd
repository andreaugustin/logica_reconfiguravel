library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        q: out std_logic);
end entity;

architecture a_divider of divider is

    signal q_s: std_logic;
    signal count: integer range 0 to 499999;
    begin
        process(clk, rst)
        begin
            if rst = '1' then
                q_s <= '0';
                count <= 0;
            elsif rising_edge(clk) then
                if en = '1' then
                    if count = 499999 then -- (50M / 100) - 1
                    q_s <= '1';
                    count <= 0;
                    else
                        count <= count + 1;
                        q_s <= '0';
                    end if;
                else
                    q_s <= '0'; -- garantir que fique com a saída 0 se o en estiver desativado
                end if;
            end if;
        end process;
        q <= q_s;
end architecture;

            