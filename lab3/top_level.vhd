library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port(
    clk: in std_logic;
    rst: in std_logic;
    en: in std_logic);
end entity;

architecture a_top_level of top_level is

    component divider is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        q: out std_logic);
    end component;

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

    component cmp_eq_5 is
    port(
        value: in unsigned(3 downto 0);
        is_equal: out std_logic);
    end component;

    signal and0, and1, and2, and3: std_logic;
    signal out_divider: std_logic;
    signal out_comparator9_0, out_comparator9_1, out_comparator9_2, out_comparator5: std_logic;
    signal out_count_0, out_count_1, out_count_2, out_count_3: unsigned(3 downto 0);

    begin

        and0 <= out_divider and out_comparator9_0;
        and1 <= and0 and out_comparator9_1;
        and2 <= and1 and out_comparator9_2;
        and3 <= and2 and out_comparator5;

        div: divider port map(clk => clk,
                            rst => rst,
                            en => en, 
                            q => out_divider);

        counter0: counter port map(clk => clk,
                                    rst => rst,
                                    en => out_divider,
                                    clr => and0,
                                    load => '0',
                                    data_in => "0000",
                                    count => out_count_0);

        counter1: counter port map(clk => clk,
                                    rst => rst,
                                    en => and0,
                                    clr => and1,
                                    load => '0',
                                    data_in => "0000",
                                    count => out_count_1);

        counter2: counter port map(clk => clk,
                                    rst => rst,
                                    en => and1,
                                    clr => and2,
                                    load => '0',
                                    data_in => "0000",
                                    count => out_count_2);

        counter3: counter port map(clk => clk,
                                    rst => rst,
                                    en => and2,
                                    clr => and3,
                                    load => '0',
                                    data_in => "0000",
                                    count => out_count_3);

        comparator9_0: cmp_eq_9 port map(value => out_count_0,
                                    is_equal => out_comparator9_0);
        
        comparator9_1: cmp_eq_9 port map(value => out_count_1,
                                    is_equal => out_comparator9_1);
        
        comparator9_2: cmp_eq_9 port map(value => out_count_2,
                                    is_equal => out_comparator9_2);

        comparator5: cmp_eq_5 port map(value => out_count_3,
                                    is_equal => out_comparator5);


end architecture;