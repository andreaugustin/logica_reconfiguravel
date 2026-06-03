library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end entity;

architecture a_uart_tb of uart_tb is

    -- Declaração do componente a ser testado (UUT - Unit Under Test)
    component uart is
        port(
            clk: in std_logic;
            rst: in std_logic;
            pin_rx : in  std_logic;
            pin_tx : out std_logic;
            tx_start: in std_logic;
            tx_data: in std_logic_vector(7 downto 0);
            rx_data: out std_logic_vector(7 downto 0);
            tx_ready: out std_logic 
        );
    end component;

    -- Sinais internos para conectar ao componente
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    -- Inicializa o RX em '1' (estado ocioso do protocolo UART)
    signal pin_rx : std_logic := '1'; 
    signal pin_tx : std_logic;
    
    signal tx_start : std_logic := '0';
    signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data : std_logic_vector(7 downto 0);
    signal tx_ready : std_logic;

    -- Configuração de tempos baseada na sua lógica de 50MHz e 9600 bps
    constant CLK_PERIOD : time := 20 ns; -- (1 / 50MHz = 20 ns)
    constant BIT_PERIOD : time := 5208 * CLK_PERIOD; -- 5208 ciclos por bit

begin

    -- Instanciação do seu módulo UART
    uut: uart port map (
        clk      => clk,
        rst      => rst,
        pin_rx   => pin_rx,
        pin_tx   => pin_tx,
        tx_start => tx_start,
        tx_data  => tx_data,
        rx_data  => rx_data,
        tx_ready => tx_ready
    );

    -- Processo gerador de Clock (50 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo gerador de Estímulos
    stim_proc: process
        
        -- Procedimento auxiliar para simular o envio de 1 Byte via UART
        procedure send_rx_byte(data : std_logic_vector(7 downto 0)) is
        begin
            -- 1. Envia o Start Bit ('0') para tirar o sistema do estado ocioso
            pin_rx <= '0';
            wait for BIT_PERIOD;
            
            -- 2. Envia os 8 bits de dados (Do LSB para o MSB)
            for i in 0 to 7 loop
                pin_rx <= data(i);
                wait for BIT_PERIOD;
            end loop;
            
            -- 3. Envia o Stop Bit ('1')
            pin_rx <= '1';
            wait for BIT_PERIOD;
        end procedure;

    begin
        -- Aplica o Reset inicial
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Teste 1: Envia o byte 0xA5 ("10100101")
        -- O módulo deve detectar a queda do RX, ir pro estado "01", e guardar os bits
        send_rx_byte("10100101");
        
        -- Aguarda um tempo entre os envios
        wait for 2 * BIT_PERIOD;

        -- Teste 2: Envia o byte 0x3C ("00111100")
        -- Verifica se o tx_ready pulsou e o estado voltou para o ocioso antes de receber mais dados [cite: 25, 26]
        send_rx_byte("00111100");

        -- Trava a simulação para não rodar infinitamente
        wait; 
    end process;

end architecture;