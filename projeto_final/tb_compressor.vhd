library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_compressor is
end entity;

architecture behavior of tb_compressor is

    component compressor is
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            valid_in  : in  std_logic;                    -- para a FSM avisar SE TEM DADO NOVO NA ENTRADA
            data_in   : in  std_logic_vector(7 downto 0); 
            valid_out : out std_logic;                    -- avisa se a saida está pronta
            data_out  : out std_logic_vector(7 downto 0)  -- byte completo de saida
        );
    end component;

    -- Sinais internos para conectar ao DUT
    signal clk_tb       : std_logic := '0';
    signal rst_tb       : std_logic := '0';
    signal valid_in_tb  : std_logic := '0';
    signal data_in_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_out_tb : std_logic;
    signal data_out_tb  : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant CLK_PERIOD_HALF : time := 5 ns;

begin

    DUT: compressor
        port map (
            clk       => clk_tb,
            rst       => rst_tb,
            valid_in  => valid_in_tb,
            data_in   => data_in_tb,
            valid_out => valid_out_tb,
            data_out  => data_out_tb
        );

    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD_HALF;
        clk_tb <= '1';
        wait for CLK_PERIOD_HALF;
    end process;

    stimulus_process: process
    begin
        -- Estado inicial e Reset
        rst_tb <= '1';
        valid_in_tb <= '0';
        data_in_tb <= (others => '0'); 
        wait for CLK_PERIOD * 2;
        
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        -- TESTE 1: Entram dois bytes "11110000"
        valid_in_tb <= '1';
        data_in_tb <= "11110000"; 
        wait for CLK_PERIOD;
        
        valid_in_tb <= '1';
        data_in_tb <= "11110000";
        wait for CLK_PERIOD;
        
        -- Tem que sair: 11111111
        valid_in_tb <= '0'; -- Pausamos a entrada para analisar a saída
        wait for CLK_PERIOD * 2;
        
        -- TESTE 2: Entram os bytes x"00" e x"10" (corrigido de x"01")
        valid_in_tb <= '1';
        data_in_tb <= x"00"; -- MSB é "0000"
        wait for CLK_PERIOD;
        
        valid_in_tb <= '1';
        data_in_tb <= x"10"; -- MSB é "0001"
        wait for CLK_PERIOD;
        
        -- Tem que sair: 00000001
        valid_in_tb <= '0';
        wait for CLK_PERIOD * 2;
        
        -- TESTE 3: Entra apenas um byte isolado
        valid_in_tb <= '1';
        data_in_tb <= "11111111";
        wait for CLK_PERIOD;
        
        -- Nao tem que sair nada (valid_out permanece '0' aguardando o próximo byte)
        valid_in_tb <= '0';
        wait for CLK_PERIOD * 4;

        -- Encerra a simulação
        wait;
    end process;

end architecture;