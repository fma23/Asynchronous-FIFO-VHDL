library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity AsynchronousFiFo is
Generic (
        ADDR_WIDTH: natural:=13;  --log(FIFO_DEPTH)+1
        DATA_WIDTH: natural:=8; 
        FIFO_DEPTH: natural:=4096   -- log(16)=4, 
        );
port(
WriteClk  : in std_logic;  
WriteReset: in std_logic; 
WriteReq  : in std_logic; 
WriteDataIn    : in std_logic_vector(DATA_WIDTH-1 downto 0);

ReadClk   : in std_logic;  
ReadReset : in std_logic; 
ReadReq   : in std_logic;
ReadDataOut  : out std_logic_vector(DATA_WIDTH-1 downto 0); 

FullFlag          : out std_logic;
EmptyFlag         : out std_logic;
              
ReadPtr_Grey_out        : out std_logic_vector(ADDR_WIDTH-1 downto 0);
WritePtr_Grey_out       : out std_logic_vector(ADDR_WIDTH-1 downto 0)
);
end AsynchronousFiFo;

architecture Behavioral of AsynchronousFiFo is

signal FIFO_Full : std_logic:='0'; 
signal FIFO_Empty: std_logic:='0'; 

signal WriteDataIn_Sig : std_logic_vector(DATA_WIDTH-1 downto 0);

signal WritePtr             : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal WritePtr_Binary      : std_logic_vector(ADDR_WIDTH-1 downto 0); 
signal WritePtr_Binary_sync : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal ReadPtr              : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal ReadPtr_Binary       : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal ReadPtr_Binary_sync  : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal ReadPtr_Grey_reg     : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal WritePtr_Grey        : std_logic_vector(ADDR_WIDTH-1 downto 0):=(others=>'0'); 
signal WritePtr_Grey_dly    : std_logic_vector(ADDR_WIDTH-1 downto 0); 
signal WritePtr_Grey_sync   : std_logic_vector(ADDR_WIDTH-1 downto 0); 
signal WritePtr_Grey_reg    : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal ReadPtr_Grey      : std_logic_vector(ADDR_WIDTH-1 downto 0):=(others=>'0');
signal ReadPtr_Grey_dly  : std_logic_vector(ADDR_WIDTH-1 downto 0); 
signal ReadPtr_Grey_sync : std_logic_vector(ADDR_WIDTH-1 downto 0);

type RAM is array (FIFO_DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal DualPortRAM: RAM:=(others=>(others=>'0')); 

begin

WRITE_FIFO:process(WriteClk) is 
variable count: std_logic_vector(1 downto 0); 
begin 
if rising_edge(WriteClk) then

  if WriteReset='1' then
     WritePtr  <= (others=>'0');
     WritePtr_Grey_reg     <= (others=>'0');
     WriteDataIn_Sig <= (others=>'0');
    
     --ReadPtr_Grey_reg    <= (others=>'0');
     ReadPtr_Grey_dly <= (others=>'0');
     ReadPtr_Grey_sync <= (others=>'0');
     count:="00";
     ReadPtr_Binary_sync  <= (others=>'0');
   else  
   if (WriteReq ='1' and  FIFO_Full ='0') then
       WriteDataIn_Sig<=WriteDataIn_Sig+1; 
       DualPortRAM(conv_integer(WritePtr(ADDR_WIDTH-2 downto 0)))<=WriteDataIn_Sig;
       WritePtr<= WritePtr+1; 
    end if; 
   
   --register write grey pointer 
   WritePtr_Grey_reg <=WritePtr_Grey;
   --Synchronize read
   ReadPtr_Grey_dly<=ReadPtr_Grey_reg; 
   ReadPtr_Grey_sync<=ReadPtr_Grey_dly; 
   --register read binary pointer after conversion from grey
   ReadPtr_Binary_sync<=ReadPtr_Binary; 
   end if;
 end if; 
 end process WRITE_FIFO; 
 
  --convert binary to grey code
 WritePtr_Grey <= WritePtr xor ('0' & WritePtr(ADDR_WIDTH-1 downto 1));
 
 --convert binary to grey code
 ReadPtr_Grey <= ReadPtr xor ('0' & ReadPtr(ADDR_WIDTH-1 downto 1));

 --Write Gray to binary conversion
  WritePtr_Binary(ADDR_WIDTH-1) <= WritePtr_Grey_sync(ADDR_WIDTH-1);
  write_gray2bin : for i in ADDR_WIDTH-2 downto 0 generate
       WritePtr_Binary(i) <= WritePtr_Binary(i+1) xor WritePtr_Grey_sync(i);
  end generate;

--Read Gray to binary conversion
  ReadPtr_Binary(ADDR_WIDTH-1) <= ReadPtr_Grey_sync(ADDR_WIDTH-1);
  Read_gray2bin : for i in ADDR_WIDTH-2 downto 0 generate
       ReadPtr_Binary(i) <= ReadPtr_Binary(i+1) xor ReadPtr_Grey_sync(i);
  end generate;


 READ_FIFO:process(ReadClk) is 
 begin 
 if rising_edge(ReadClk) then
   if ReadReset='1' then 
     ReadPtr  <= (others=>'0');
     ReadPtr_Grey_reg     <= (others=>'0');
     
     WritePtr_Grey_dly     <= (others=>'0');
     WritePtr_Grey_sync   <= (others=>'0');
     WritePtr_Binary_sync <= (others=>'0'); 
     ReadDataOut          <=  (others=>'0');
    else
        if (ReadReq ='1' and  FIFO_Empty ='0') then 
        ReadDataOut<=DualPortRAM(conv_integer(ReadPtr(ADDR_WIDTH-2 downto 0)));  --was -2
        ReadPtr<= ReadPtr+1;
        end if; 
        --register read pointer
        ReadPtr_Grey_reg <=ReadPtr_Grey;  
        --synchronize write pointer
        WritePtr_Grey_dly<=WritePtr_Grey_reg; 
        WritePtr_Grey_sync<=WritePtr_Grey_dly; 
          
        --register write pointer in read clock domain 
        WritePtr_Binary_sync<=WritePtr_Binary;
 end if;
end if; 
end process READ_FIFO; 
 
--generate full fifo and empty fifo flags: 
FIFO_Empty <='1' when   WritePtr_Binary_sync = ReadPtr else '0'; 
FIFO_Full <='1'  when  (NOT ReadPtr_Binary_sync(ADDR_WIDTH-1))&ReadPtr_Binary_sync(ADDR_WIDTH-2 downto 0) = WritePtr else '0'; 


FullFlag  <= FIFO_Full; 
EmptyFlag  <= FIFO_Empty;
    
end Behavioral;


