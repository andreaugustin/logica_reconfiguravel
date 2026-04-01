library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port(
    rst: in std_logic;
    en: in std_logic;
    clk: in std_logic;
    unidade: out unsigned(3 downto 0);
    dezena: out unsigned(3 downto 0)
    );
end entity;

architecture a_top_level of top_level is

    component contador is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        clr: in std_logic; 
        saida: out unsigned(3 downto 0));
    end component;

    component and_1001 is
    port(
        entrada: in unsigned(3 downto 0);
        saida: out std_logic);
    end component;

    signal saida_comparador: std_logic;
    signal unidade_s, dezena_s: unsigned(3 downto 0);

    begin
        contador1: contador port map(clk => clk,
                                    rst => rst,
                                    en => en,
                                    clr => saida_comparador,
                                    saida => unidade_s);

        contador2: contador port map(clk => clk,
                                    rst => rst,
                                    en => saida_comparador,
                                    clr => '0',
                                    saida => dezena_s);

        comparador: and_1001 port map(entrada => unidade_s,
                                    saida => saida_comparador);

    unidade <= unidade_s;
    dezena <= dezena_s;

end architecture;