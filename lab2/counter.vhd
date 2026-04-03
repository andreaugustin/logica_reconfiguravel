library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        clr: in std_logic;
        load: in std_logic;
        data_in: in unsigned(3 downto 0);
        count: out unsigned(3 downto 0));
end entity;

architecture a_counter of counter is

    signal count_s: unsigned(3 downto 0) := "0000"; -- começa em zero

    begin
        process(clk, rst, clr)
        begin
            if rst = '1' then
                count_s <= "0000";
            elsif rising_edge(clk) then

                if load = '1' then -- qnd load = 1, o contador carrega data_in nesse ciclo de clk
                    count_s <= data_in;

                elsif clr = '1' then
                    count_s <= "0000";

                elsif en = '1' then
                    if count_s = "1111" then
                        count_s <= "0000";
                    else
                        count_s <= count_s + 1;
                    end if;
                end if;
            end if;
        end process;
        count <= count_s;
end architecture;

            