library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    port(
        clk: in std_logic;
        rst: in std_logic;

        pin_rx : in  std_logic; -- recebe do script
        pin_tx : out std_logic; -- envia para o script

        tx_start: in std_logic;
        
        tx_data: in std_logic_vector(7 downto 0);
        rx_data: out std_logic_vector(7 downto 0);
        
        tx_ready: out std_logic 
    );
end entity;

-- No nosso script, conseguimos setar a frequência que estaremos enviando os bits
-- Por ora, vamos supor que vamos por o valor de 9600 bps (Baud Rate)
-- Ciclos por bit = Clk/Baud_Rate = 50M/9600 = 5208 ciclos
-- Então a ideia é que a cada 5208 clocks vamos pegar um bit
    
architecture uart_a of uart is

    constant BIT_PERIOD: integer := 5208;

    signal clk_count: integer range 0 to BIT_PERIOD - 1 := 0;
    signal baud_tick: std_logic := '0';
    -- Teremos 3 estados:
    -- 0. Oscioso; 1. Recebendo bits serialmente; 2. Coloca 1 byte na saida
    signal state: std_logic_vector(1 downto 0) := "00";
    signal index: integer range -2 to 7;
    signal sequence: integer range 0 to 9;

    signal rx_data_s: std_logic_vector(7 downto 0) := "00000000"; 
    signal tx_ready_s: std_logic := '0';

begin

    process(clk, rst)
    begin
        if rst = '1' then
            clk_count <= 0;
            baud_tick <= '0';
            sequence <= 0;
        
        elsif rising_edge(clk) then

            if state = "00" then
                clk_count <= 0;
                baud_tick <= '0';
                sequence <= 0;
            end if;

            if state = "01" then
                baud_tick <= '0';
                
    
                if clk_count = BIT_PERIOD - 1 then
                    clk_count <= 0;
                    baud_tick <= '1';
                    sequence <= sequence + 1;
                    index <= sequence - 2;
                else
                    clk_count <= clk_count + 1;
                end if;
            else
                clk_count <= 0;
                baud_tick <= '0';
                sequence <= 0;
            end if;
         end if;
    end process;

    -- 0 OSCIOSO: fica verificando o pino pin_rx. Se ele for para '0', é pq vai começar a vir dados. Então muda de estado para 1
    -- 1 RECEBENDO BITS SERIALMENTE: vou ativiar aqui o baud_tick e também vou por uma variável para usar como indice.
        -- o baud_tick diz a hora que podemos ler o que está no pino pin_rx e guardar aqui
        -- a cada tick do baud_tick, vamos somar 1 no index, para escrevermos no lugar certo
        -- sempre verificamos que index chegou 7. Quando chegou, primeiro guardamos o valor de pin_rx e já passamos para o estado 2
    -- 2 COLOCA 1 BYTE NA SAIDA: simplesmente damos um pulso em tx_ready (saida) para avisar que o que está no barramento de saída é o byte. Voltamos para 0 
    process(clk, rst)
    begin
        if rst = '1' then
            state <= "00";
            -- tem que ver o que mais tenho que zerar
        elsif rising_edge(clk) then

            case state is

                when "00" => -- OSCIOSO
                    tx_ready_s <= '0'; -- indicamos que não é hora pegar o que está na saída
                    if pin_rx = '0' then
                        state <= "01";
                    end if;

                when "01" => -- RECEBENDO BITS SERIALMENTE
                      if baud_tick = '1' AND index >= 0 then -- para cada tick, vamos jogar o bit no lugar correto
                          rx_data_s(index) <= pin_rx;

                          if index = 7 then -- se estamos no index 7, 
                              state <= "10";
                         end if;
                     end if;

                when "10" => -- COLOCA 1 BYTE NA SAIDA
                    tx_ready_s <= '1';
                    state <= "00";
                when others => 
                    state <= "00";
                end case;
            end if;
        end process; 
                        
    rx_data <= rx_data_s; -- sempre estara atualizando, a cada bit que chega
end architecture;
