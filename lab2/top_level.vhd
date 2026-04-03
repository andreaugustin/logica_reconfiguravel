library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port(
    rst: in std_logic;
    en: in std_logic;
    clk: in std_logic;
    data_in0: in unsigned(3 downto 0);
    data_in1: in unsigned(3 downto 0);
    unit: out unsigned(3 downto 0);
    ten: out unsigned(3 downto 0)
    );
end entity;

architecture a_top_level of top_level is

    component counter is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        clr: in std_logic; 
        load: in std_logic;
        data_in: in unsigned(3 downto 0);
        count: out unsigned(3 downto 0));
    end component;

    component cmp_eq_9 is
    port(
        value: in unsigned(3 downto 0);
        is_equal: out std_logic);
    end component;

    component cmp_eq_89 is
    port(
        value_unit: in unsigned(3 downto 0); 
        value_ten: in unsigned(3 downto 0); 
        is_equal: out std_logic);
    end component;

    signal out_comparator9: std_logic;
    signal out_comparator89: std_logic;
    signal unit_s, ten_s: unsigned(3 downto 0);

    begin

        counter0: counter port map(clk => clk,
                                    rst => rst,
                                    en => en,
                                    clr => out_comparator9,
                                    load => out_comparator89,
                                    data_in => data_in0,
                                    count => unit_s);

        counter1: counter port map(clk => clk,
                                    rst => rst,
                                    en => out_comparator9,
                                    clr => '0',
                                    load => out_comparator89,
                                    data_in => data_in1,
                                    count => ten_s);

        comparator9: cmp_eq_9 port map(value => unit_s,
                                    is_equal => out_comparator9);

        comparator89: cmp_eq_89 port map(value_unit => unit_s,
                                        value_ten => ten_s,
                                        is_equal => out_comparator89);

    unit <= unit_s;
    ten <= ten_s;

end architecture;