library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_tb is
end entity;
-- tb não precisa de entradas, ele só irá gerar sinais

architecture a_contador_tb of contador_tb is

    component contador
        port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        -- clr: in std_logic; -- tirei pq ainda n sei como funciona esse cara
        saida: out unsigned(3 downto 0));
    end component;

    signal clk, rst, en: std_logic;
    signal saida: unsigned(3 downto 0);

    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';

    begin
    uut: contador port map(
        clk => clk,
        rst => rst,
        en => en,
        saida => saida);

    reset_global: process
    begin
        rst <= '0';
        wait for 1400 ns;
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 3 us;
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process reset_global;

    sim_time_proc: process
    begin
        wait for 10 us; -- tempo total da simulação
        finished <= '1';
        wait;
    end process sim_time_proc;

    clk_proc: process
    begin -- gera clock até que sim_time_proc termine
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    process
    begin
        en <= '0';
        wait for 1 us;
        en <= '1';
        wait for 1 us;
        en <= '0';
        wait for 1 us;
        en <= '1';
        wait;
    end process;
end architecture;