library ieee;
use ieee.std_logic_1164.all;

entity mux is
    port (
        sel       : in  std_logic;                    -- (control_mux da FSM)
        data_in_0 : in  std_logic_vector(7 downto 0); -- porta 0: ligada na saída do compressor
        data_in_1 : in  std_logic_vector(7 downto 0); -- porta 1: ligada na saída da FIFO
        data_out  : out std_logic_vector(7 downto 0)  -- saída: ligada no 'data_in' da BRAM
    );
end entity;

architecture a_mux of mux is
begin
	 -- se sel = 1, passa a FIFO; senão, passa o compressor
    data_out <= data_in_1 when sel = '1' else data_in_0;
end architecture;