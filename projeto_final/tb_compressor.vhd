library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_compressor is
end entity;

architecture behavior of tb_compressor is

    component compressor is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            data_in  : in  std_logic_vector(7 downto 0); 
            data_out : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Sinais internos para conectar ao DUT
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '0';
    signal data_in_tb  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out_tb : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;
	 constant CLK_PERIOD_HALF : time := 5 ns;

begin

    DUT: compressor
        port map (
            clk      => clk_tb,
            rst      => rst_tb,
            data_in  => data_in_tb,
            data_out => data_out_tb
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
        rst_tb <= '1';
        data_in_tb <= x"AA"; 
        wait for CLK_PERIOD * 2;
        
        rst_tb <= '0';
        wait for CLK_PERIOD;
        
        data_in_tb <= x"FF";
        wait for CLK_PERIOD;
        
        data_in_tb <= x"55";
        wait for CLK_PERIOD;
        
        data_in_tb <= x"12";
        wait for CLK_PERIOD;
        
        data_in_tb <= x"00";
        wait for CLK_PERIOD;

        wait;
    end process;

end architecture;