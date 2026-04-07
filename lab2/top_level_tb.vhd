library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;
-- tb não precisa de entradas, ele só irá gerar sinais

architecture a_top_level_tb of top_level_tb is

    component top_level is
    port(
    rst: in std_logic;
    en: in std_logic;
    clk: in std_logic;
    data_in0: in unsigned(3 downto 0);
    data_in1: in unsigned(3 downto 0);
    unit: out unsigned(3 downto 0);
    ten: out unsigned(3 downto 0)
    );
    end component;

    signal clk, rst, en: std_logic;
    signal data_in0, data_in1, unit, ten_s: unsigned(3 downto 0);

    constant period_time: time := 20 ns; -- Período de um clock(sobida + decida)
    signal finished: std_logic := '0';

    begin
    uut: top_level port map(
                            rst => rst,
                            en => en,
                            clk => clk,
                            data_in0 => data_in0,
                            data_in1 => data_in1,
                            unit => unit,
                            ten => ten_s);

    --reset_global: process -- Mudança aqui no reset
    --begin
    --    rst <= '1';
    --    wait for 15 ns;
    --    rst <= '0';
    --    wait;
    --end process reset_global;

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
        wait for 10 us;
        en <= '0';
        wait;
    end process enable_proc;

    data_in0_proc: process 
    begin
        data_in0 <= "0101";
        wait;
    end process data_in0_proc;

    data_in1_proc: process 
    begin
        data_in1 <= "0001";
        wait;
    end process data_in1_proc;

end architecture;