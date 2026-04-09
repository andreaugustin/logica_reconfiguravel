library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;
-- tb não precisa de entradas, ele só irá gerar sinais

architecture a_top_level_tb of top_level_tb is

    component top_level is
        port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic);
    end component;


    signal clk, rst, en: std_logic;

    constant period_time: time := 20 ns; -- Período de um clock(sobida + decida)
    signal finished: std_logic := '0';

    begin
    uut: top_level port map(clk => clk,
                            rst => rst,
                            en => en);

    reset_global: process -- Mudança aqui no reset
    begin
        rst <= '1';
        wait for 15 ns;
        rst <= '0';
        wait;
    end process reset_global;

    sim_time_proc: process
    begin
        wait for 150 ms; -- tempo total da simulação
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
        wait;
    end process enable_proc;

end architecture;