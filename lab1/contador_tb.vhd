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
        clr: in std_logic; -- tirei pq ainda n sei como funciona esse cara
        saida: out unsigned(3 downto 0));
    end component;

    signal clk, rst, en, clr: std_logic;
    signal saida: unsigned(3 downto 0);

    constant period_time: time := 20 ns; -- Período de um clock(sobida + decida)
    signal finished: std_logic := '0';

    begin
    uut: contador port map(
        clk => clk,
        rst => rst,
        en => en,
        clr => clr,
        saida => saida);

    reset_global: process -- Mudança aqui no reset
    begin
        rst <= '1';
        wait for 15 ns;
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

    enable_proc: process -- alteração no tempo do en
    begin 
        en <= '1';
        wait for 185 ns;
        en <= '0';
        wait;
    end process enable_proc;

    clr_proc: process -- Inclusão do crl
    begin
        clr <= '0';
        wait for 75 ns;
        clr <= '1';
        wait for 20 ns;
        clr <= '0';
        wait for 30 ns;
        clr <= '1';
        wait for 20 ns;
        clr <= '0';
        wait;
    end process clr_proc;

end architecture;