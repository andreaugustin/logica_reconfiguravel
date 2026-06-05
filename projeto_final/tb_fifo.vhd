library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fifo is
end entity;

architecture sim of tb_fifo is

    component fifo is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            rd_en    : in  std_logic;
            data_in  : in  std_logic_vector(7 downto 0);
            wr_en    : in  std_logic;
            empty    : out std_logic;
            full     : out std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    signal tb_clk      : std_logic := '0';
    signal tb_rst      : std_logic := '0';
    signal tb_rd_en    : std_logic := '0';
    signal tb_wr_en    : std_logic := '0';
    signal tb_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_data_out : std_logic_vector(7 downto 0);
    signal tb_empty    : std_logic;
    signal tb_full     : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: fifo
        port map(
            clk      => tb_clk,
            rst      => tb_rst,
            rd_en    => tb_rd_en,
            data_in  => tb_data_in,
            wr_en    => tb_wr_en,
            empty    => tb_empty,
            full     => tb_full,
            data_out => tb_data_out
        );

    clk_process: process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_process: process
    begin
        tb_rst <= '1';
        wait for CLK_PERIOD * 2;
        tb_rst <= '0';
        wait for CLK_PERIOD * 2;

        -- teste: preenche TODA a FIFO (escrever 16 vezes)
		  -- pos[1] <= 1 , (...)
        tb_wr_en <= '1';
        for i in 1 to 16 loop
            tb_data_in <= std_logic_vector(to_unsigned(i, 8));
            wait for CLK_PERIOD;
        end loop;
        tb_wr_en <= '0';
        
        -- A FLAG FULL TEM QUE ESTAR EM 1 AQUI!!
        wait for CLK_PERIOD * 2;

        -- teste: tenta escrever com a FIFO cheia (overflow)
        tb_wr_en <= '1';
        tb_data_in <= x"FF"; -- tenta escrever 255
        wait for CLK_PERIOD;
        tb_wr_en <= '0';
        
        -- ela tem que ignorar a tentativa de escrita
        wait for CLK_PERIOD * 2;

        -- teste: esvaziar toda a fifo -> lê 16 vezes
        tb_rd_en <= '1';
        for i in 1 to 16 loop
            wait for CLK_PERIOD;
        end loop;
        tb_rd_en <= '0';

        -- aqui, a flag 'empty' tem que ESTAR EM 1!!!!
        wait for CLK_PERIOD * 2;

		  -- tenta ler a fifo vazia (tem que ignorar essa tentativa)
        tb_rd_en <= '1';
        wait for CLK_PERIOD;
        tb_rd_en <= '0';
        wait for CLK_PERIOD * 2;

        -- teste: lê e escreve AO MESMO TEMPO
        tb_wr_en <= '1';
        tb_data_in <= x"AA";
        wait for CLK_PERIOD; -- escreve um dado 
        
        tb_rd_en <= '1';
        tb_data_in <= x"BB";
        wait for CLK_PERIOD; -- le o x"AA" enquanto escreve o x"BB"
        
        tb_wr_en <= '0';
        tb_rd_en <= '0';
        
		  -- contador aqui tem que permanecer o mesmo!!!!
        wait for CLK_PERIOD * 5;

        wait;
    end process;

end architecture;