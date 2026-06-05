library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compressor is
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        valid_in  : in  std_logic;                    -- para a FSM avisar SE TEM DADO NOVO NA ENTRADA
        data_in   : in  std_logic_vector(7 downto 0); 
        valid_out : out std_logic;                    -- avisa se a saida está pronta
        data_out  : out std_logic_vector(7 downto 0)  -- byte completo de saida (4 bits + 4 bits concatenados das entradas)
    );
end entity;

architecture a_compressor of compressor is
    -- registrador para guardar os 4 bits do primeiro pixel que entrar
    signal primeiro_pixel : std_logic_vector(3 downto 0);
    
    -- flag para saber se estamos esperando o 1 ou 2 pixel
    signal esperando_segundo : std_logic := '0'; 
begin
    process(clk, rst)
    begin
        if rst = '1' then
            esperando_segundo <= '0';
            primeiro_pixel <= (others => '0');
            data_out <= (others => '0');
            valid_out <= '0';
            
        elsif rising_edge(clk) then
            -- a saída NAO é válida ate que o empacotamento termine
            valid_out <= '0'; 

            if valid_in = '1' then
                if esperando_segundo = '0' then
                    -- chegou o 1 byte; guarda os 4 bits msb e muda o estado
                    primeiro_pixel <= data_in(7 downto 4);
                    esperando_segundo <= '1';
                else
                    -- chegou o 2 byte; concatena o que estava guardado com o novo
                    data_out <= primeiro_pixel & data_in(7 downto 4);
                    
                    -- avisa a FSM que o byte completo comprimido está pronto para a BRAM
                    valid_out <= '1'; 
                    
                    -- reseta o estado para o próximo par de pixels
                    esperando_segundo <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;