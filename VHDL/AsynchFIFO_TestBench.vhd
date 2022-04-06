-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 5.4.2022 18:39:07 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_AsynchronousFiFo is
end tb_AsynchronousFiFo;

architecture tb of tb_AsynchronousFiFo is

      constant addr_width : integer := 13;
      constant data_width : integer := 8;
      constant fifo_depth : integer := 4096;

      component AsynchronousFiFo
      Generic (
            ADDR_WIDTH: natural:=13;  --log(FIFO_DEPTH)+1
            DATA_WIDTH: natural:=8; 
            FIFO_DEPTH: natural:=4096   -- log(16)=4, 
            );
        port (WriteClk          : in std_logic;
              WriteReset        : in std_logic;
              WriteReq          : in std_logic;
              WriteDataIn       : in std_logic_vector (data_width-1 downto 0);
              ReadClk           : in std_logic;
              ReadReset         : in std_logic;
              ReadReq           : in std_logic;
              ReadDataOut       : out std_logic_vector (data_width-1 downto 0);
              FullFlag          : out std_logic;
              EmptyFlag         : out std_logic;
              ReadPtr_Grey_out  : out std_logic_vector (addr_width-1 downto 0);
              WritePtr_Grey_out : out std_logic_vector (addr_width-1 downto 0));
    end component;

    signal WriteClk          : std_logic;
    signal WriteReset        : std_logic;
    signal WriteReq          : std_logic;
    signal WriteDataIn       : std_logic_vector (data_width-1 downto 0);
    signal ReadClk           : std_logic;
    signal ReadReset         : std_logic;
    signal ReadReq           : std_logic;
    signal ReadDataOut       : std_logic_vector (data_width-1 downto 0);
    signal FullFlag          : std_logic;
    signal EmptyFlag         : std_logic;
    signal ReadPtr_Grey_out  : std_logic_vector (addr_width-1 downto 0);
    signal WritePtr_Grey_out : std_logic_vector (addr_width-1 downto 0);

--    constant TbPeriod1 : time := 10 ns; -- EDIT Put right period here
--    signal TbClock1 : std_logic := '0';
--    signal TbSimEnded1 : std_logic := '0';

--    constant TbPeriod2 : time := 20 ns; -- EDIT Put right period here
--    signal TbClock2 : std_logic := '0';
--    signal TbSimEnded2 : std_logic := '0';
    
    constant clockRd_period : time := 20 ns;
    constant clockWr_period : time := 10 ns;
       
    
begin

    dut : AsynchronousFiFo
    generic map(
              ADDR_WIDTH => addr_width,
              DATA_WIDTH => data_width,
              FIFO_DEPTH => fifo_depth)
    port map (
              WriteClk          => WriteClk,
              WriteReset        => WriteReset,
              WriteReq          => WriteReq,
              WriteDataIn       => WriteDataIn,
              ReadClk           => ReadClk,
              ReadReset         => ReadReset,
              ReadReq           => ReadReq,
              ReadDataOut       => ReadDataOut,
              FullFlag          => FullFlag,
              EmptyFlag         => EmptyFlag,
              ReadPtr_Grey_out  => ReadPtr_Grey_out,
              WritePtr_Grey_out => WritePtr_Grey_out);
   
       -- Clock process definitions
    clockR_process :process
    begin
         ReadClk <= '0';
         wait for clockRd_period/2;
         ReadClk <= '1';
         wait for clockRd_period/2;
    end process;
  
    clockW_process :process
    begin
         WriteClk <= '0';
         wait for clockWr_period/2;
         WriteClk  <= '1';
         wait for clockWr_period/2;
    end process;
    
       -- Stimulus process
    stim_proc_reset: process
    begin        
       -- hold reset state for 100 ns.
         ReadReset <= '1';
         WriteReset <= '1';
       wait for 100 ns;  
         ReadReset <= '0';
         WriteReset <= '0';
       wait;
    end process;
    
      stim_proc_write: process
     begin        
        --wait for 100 ns;  
        -- insert stimulus here
      --  wait for clockWr_period*10;
          WriteReq <= '1';
        wait for clockWr_period*100;
          WriteReq <= '0';
        wait;
     end process;
    
     stim_proc_read: process
     begin        
        --wait for 100 ns;  
        -- insert stimulus here
        --wait for clockRd_period*50;
        ReadReq <= '1';
        wait for clockRd_period*50;
        ReadReq <= '0';
        wait;
     end process;
     
end tb;
