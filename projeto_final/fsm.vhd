library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
    generic ( -- tipo um define
        IMG_SIZE    : integer := 16;   -- tamanho imagem para o teste atual em bytes
        COMP_OFFSET : integer := 1024  -- endereço onde começa a guardar a imagem comprimida
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        empty_fifo      : in  std_logic;
        rd_en_fifo      : out std_logic;
        
        tx_ready_uart   : in  std_logic;
        tx_start_uart   : out std_logic;
        
        valid_out_comp  : in  std_logic;
        valid_in_comp   : out std_logic;
        
        control_mux     : out std_logic;
        we_en_bram      : out std_logic;
        address_bram    : out std_logic_vector(10 downto 0)
    );
end entity;

architecture a_fsm of fsm is

    type state_type is (
        S_IDLE,
        
        -- estado 1: tira os dados brutos da fifo (que chegaram da uart)
        -- e os guarda na bram. 
        S_RX_CHECK_FIFO,
        S_RX_WAIT_FIFO,
        S_RX_WRITE_BRAM,
        S_RX_WRITE_DONE,
        
        -- estado 2: lê os dados brutos da bram e envia ao compressor; 
        -- depois manda novamente para a bram guardar;
        -- metade inf BRAM: entrada; metade sup bram (1024-2047): saída comprimida
        S_COMP_READ_BRAM,
        S_COMP_WAIT_READ,
        S_COMP_SEND_DATA,
        S_COMP_CHECK_OUT,
        S_COMP_WRITE_BRAM,
        S_COMP_WRITE_DONE,
        
        -- le a zona comprimida da bram e manda para a uart
        S_TX_READ_BRAM,
        S_TX_WAIT_READ,
        S_TX_WAIT_UART,
        S_TX_SEND_START,
        
        S_DONE
    );
    
    signal state : state_type := S_IDLE;
    signal addr_orig_cnt : integer range 0 to 2047 := 0;
    signal addr_comp_cnt : integer range 0 to 2047 := 0;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state <= S_IDLE;
            addr_orig_cnt <= 0;
            addr_comp_cnt <= 0;
            rd_en_fifo    <= '0';
            tx_start_uart <= '0';
            valid_in_comp <= '0';
            control_mux   <= '1';
            we_en_bram    <= '0';
            address_bram  <= (others => '0');
            
        elsif rising_edge(clk) then
            rd_en_fifo    <= '0';
            tx_start_uart <= '0';
            valid_in_comp <= '0';
            we_en_bram    <= '0';

            case state is
                -- ESTADO 1:
                when S_IDLE =>
                    addr_orig_cnt <= 0;
                    addr_comp_cnt <= 0;
                    state <= S_RX_CHECK_FIFO;

                -- 
                when S_RX_CHECK_FIFO =>
                    if empty_fifo = '0' then
                        rd_en_fifo <= '1'; 
                        state <= S_RX_WAIT_FIFO;
                    end if;

                when S_RX_WAIT_FIFO =>
                    -- Espera 1 clock para o dado sair da FIFO
                    state <= S_RX_WRITE_BRAM;

                when S_RX_WRITE_BRAM =>
                    control_mux <= '1'; -- deixa passar para a fifo
                    address_bram <= std_logic_vector(to_unsigned(addr_orig_cnt, 11));
                    we_en_bram <= '1';  -- grava na bram
                    state <= S_RX_WRITE_DONE;

                when S_RX_WRITE_DONE =>
                    if addr_orig_cnt = IMG_SIZE - 1 then
                        addr_orig_cnt <= 0; -- zera o contador para a proxima fase (estado 2)
                        state <= S_COMP_READ_BRAM;
                    else
                        addr_orig_cnt <= addr_orig_cnt + 1;
                        state <= S_RX_CHECK_FIFO;
                    end if;



                -- ESTADO 2: LER, COMPRIMIR E GRAVAR NA BRAM
                when S_COMP_READ_BRAM =>
                    address_bram <= std_logic_vector(to_unsigned(addr_orig_cnt, 11));
                    state <= S_COMP_WAIT_READ;

                when S_COMP_WAIT_READ =>
                    -- Espera 1 clock para a leitura síncrona da BRAM refletir na saída
                    state <= S_COMP_SEND_DATA;

                when S_COMP_SEND_DATA =>
                    valid_in_comp <= '1'; 
                    state <= S_COMP_CHECK_OUT;

                when S_COMP_CHECK_OUT =>
                    if valid_out_comp = '1' then
                        state <= S_COMP_WRITE_BRAM;
                    else
                        -- se o compressor só recebeu 1 byte (espera ainda o segundo)
                        addr_orig_cnt <= addr_orig_cnt + 1;
                        state <= S_COMP_READ_BRAM;
                    end if;

                when S_COMP_WRITE_BRAM =>
                    control_mux <= '0'; -- mux escolhe a via do compressor
                    address_bram <= std_logic_vector(to_unsigned(COMP_OFFSET + addr_comp_cnt, 11));
                    we_en_bram <= '1';  -- grava o byte comprimido
                    state <= S_COMP_WRITE_DONE;

                when S_COMP_WRITE_DONE =>
                    if addr_orig_cnt = IMG_SIZE - 1 then
                        addr_comp_cnt <= 0;
                        state <= S_TX_READ_BRAM;
                    else
                        addr_orig_cnt <= addr_orig_cnt + 1;
                        addr_comp_cnt <= addr_comp_cnt + 1;
                        state <= S_COMP_READ_BRAM;
                    end if;



                -- ESTADO 3: LER COMPRIMIDO E ENVIAR PELA UART

                when S_TX_READ_BRAM =>
                    address_bram <= std_logic_vector(to_unsigned(COMP_OFFSET + addr_comp_cnt, 11));
                    state <= S_TX_WAIT_READ;

                when S_TX_WAIT_READ =>
                    state <= S_TX_WAIT_UART;

                when S_TX_WAIT_UART =>
                    if tx_ready_uart = '1' then
                        tx_start_uart <= '1'; 
                        state <= S_TX_SEND_START;
                    end if;

                when S_TX_SEND_START =>
                    -- Verifica se já enviamos metade da imagem original
                    if addr_comp_cnt = (IMG_SIZE / 2) - 1 then
                        state <= S_DONE;
                    else
                        addr_comp_cnt <= addr_comp_cnt + 1;
                        state <= S_TX_READ_BRAM;
                    end if;

                -- PROCESSO CONCLUÍDO:
                when S_DONE =>
                    -- fica aqui até que o reset seja pressionado.
                    state <= S_DONE;

                when others =>
                    state <= S_IDLE;
            end case;
        end if;
    end process;

end architecture;