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
    )
end entity;

-- No nosso script, conseguimos setar a frequência que estaremos enviando os bits
-- Por ora, vamos supor que vamos por o valor de 9600 bps (Baud Rate)
-- Ciclos por bit = Clk/9600 = 50M/9600 = 5208 ciclos

architecture uart_a of uart is

    constant BIT_PERIOD: integer := 5208;

    signal clk_count: integer range 0 to BIT_PERIOD - 1 := 0;
    signal baud_tick: std_logic := '0';

begin

    process(clk, rst)
    begin
        if rst = '1' then
            clk_count <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            baud_tick <= '0';

            if clk_count = BIT_PERIOD - 1 then
                clk_count <= 0;
                baud_tick <= '1';
            else
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;
    
end architecture;