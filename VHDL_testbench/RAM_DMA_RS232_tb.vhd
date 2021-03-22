
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_DMA_RS_tb is
--  Port ( );
end RAM_DMA_RS_tb;

architecture testbench of RAM_DMA_RS_tb is
    
    signal Clk : STD_LOGIC;
    
    --External input lines
    signal RS232_RX : std_logic;
    signal Reset : STD_LOGIC;
    
    -- External output lines
    signal RS232_TX : std_logic;
    signal switches : std_logic_vector(7 downto 0);
    
    -- Connections between RS232TOP and DMA
    signal RX_Full, RX_Empty, Data_Read, Valid_D, Ack_out, TX_RDY: STD_LOGIC;
    signal RCVD_Data, TX_Data: std_logic_vector(7 downto 0);
    
    -- Bus connections
    signal OE, Write_En: STD_LOGIC;
    signal Address, Databus: std_logic_vector(7 downto 0);
    
    -- Connections between processor and DMA
    signal SEND, DMA_ACK, READY, DMA_RQ: STD_LOGIC;
    
    -- Display values from RAM
    signal Temp_L, Temp_H: std_logic_vector(6 downto 0);
    
    
component DMA
	port (	
           Reset : in STD_LOGIC;
           Clk : in STD_LOGIC;
           RCVD_Data : in STD_LOGIC_VECTOR (7 downto 0);
           RX_Full : in STD_LOGIC;
           RX_Empty : in STD_LOGIC;
           Data_Read : out STD_LOGIC;
           ACK_out : in STD_LOGIC;
           TX_RDY : in STD_LOGIC;
           Valid_D : out STD_LOGIC;
           TX_Data : out STD_LOGIC_VECTOR (7 downto 0);
           Address : out STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout STD_LOGIC_VECTOR (7 downto 0);
           Write_en : out STD_LOGIC;
           OE : out STD_LOGIC;
           DMA_RQ : out STD_LOGIC;
           DMA_ACK : in STD_LOGIC;
           Send_comm : in STD_LOGIC;
           READY : out STD_LOGIC);
end component;

component RAM
    port (
        Clk      : in    std_logic;
        Reset    : in    std_logic;
        Write_en : in    std_logic;
        OE       : in    std_logic;
        Address  : in    std_logic_vector(7 downto 0);
        Databus  : inout std_logic_vector(7 downto 0);
        Switches : out   std_logic_vector(7 downto 0);
        Temp_L   : out   std_logic_vector(6 downto 0);
        Temp_H   : out   std_logic_vector(6 downto 0));
  end component;
    
  component RS232top
    port (
      Reset     : in  std_logic;
      Clk : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;

begin

    RS232top_PHY: RS232top
    port map (
        Reset => Reset,
        Clk => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty);
        
  DMA_PHY: DMA
    port map (
        Reset => Reset,
        Clk => Clk,
        RCVD_Data => RCVD_Data,
        RX_Full => RX_Full,
        RX_Empty => RX_Empty,
        Data_Read => Data_Read,
        ACK_out => ACK_out,
        TX_RDY => TX_RDY,
        Valid_D => Valid_D,
        TX_Data => TX_Data,
        Address => Address,
        Databus => Databus,
        Write_en => Write_en,
        OE => OE,
        DMA_RQ => DMA_RQ,
        DMA_ACK => DMA_ACK,
        Send_comm => SEND,
        READY => READY);
        
  RAM_PHY: RAM
    port map (
        Clk => Clk,
        Reset => Reset,
        Write_en => Write_En,
        OE => OE,
        Address => Address,
        Databus => Databus,
        Switches => Switches,
        Temp_L => Temp_L,
        Temp_H => Temp_H);
  
  p_clk20MHz : PROCESS
  BEGIN
     Clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

  -- Reset
  p_reset : PROCESS
  BEGIN
     reset <= '0', '1' after 75 ns;
     WAIT;

  END PROCESS;
  
  rx_bytes_RS232 : PROCESS
  BEGIN
     RS232_RX <= '1';
     SEND <= '0';

     wait for 2500 ns; 

     RS232_RX <= '1',
           '0' after 500 ns,    -- StartBit
           '0' after 9150 ns,   -- LSb
           '1' after 17800 ns,
           '0' after 26450 ns,
           '1' after 35100 ns,
           '0' after 43750 ns,
           '1' after 52400 ns,
           '0' after 61050 ns,
           '1' after 69700 ns,  -- MSb
           '1' after 78350 ns;  -- Stopbit
       
       wait for 100000 ns; 

        RS232_RX <= '1',
           '0' after 500 ns,    -- StartBit
           '1' after 9150 ns,   -- LSb
           '1' after 17800 ns,
           '1' after 26450 ns,
           '1' after 35100 ns,
           '1' after 43750 ns,
           '1' after 52400 ns,
           '1' after 61050 ns,
           '1' after 69700 ns,  -- MSb
           '1' after 78350 ns;  -- Stopbit
           
       wait for 100000 ns; 

        RS232_RX <= '1',
           '0' after 500 ns,    -- StartBit
           '1' after 9150 ns,   -- LSb
           '1' after 17800 ns,
           '1' after 26450 ns,
           '0' after 35100 ns,
           '1' after 43750 ns,
           '1' after 52400 ns,
           '1' after 61050 ns,
           '1' after 69700 ns,  -- MSb
           '1' after 78350 ns;  -- Stopbit
     
     wait for 100000 ns; 

        RS232_RX <= '1',
           '0' after 500 ns,    -- StartBit
           '0' after 9150 ns,   -- LSb
           '1' after 17800 ns,
           '0' after 26450 ns,
           '0' after 35100 ns,
           '0' after 43750 ns,
           '0' after 52400 ns,
           '0' after 61050 ns,
           '0' after 69700 ns,  -- MSb
           '1' after 78350 ns;  -- Stopbit
          
     wait for 100000 ns; 
          
        SEND <= '0';
  -- Se puede forzar el valor de las direcciones 0x04 y 0x05 desde Scope - ram - Memoria_Esp...force constant
      wait for 400000 ns;
      if (READY = '1') then
        SEND <= '1';
      end if;
      wait for 2000 ns;
      SEND <= '0';
      wait;
  END PROCESS;
  
  controlBus : PROCESS (DMA_RQ)
  BEGIN
      if (DMA_RQ'event AND DMA_RQ = '1') then
        DMA_ACK <= '0', '1' after 50 ns;
      elsif (DMA_RQ'event AND DMA_RQ = '0') then
        DMA_ACK <= '1', '0' after 50 ns;
      end if;
  END PROCESS;
  
end testbench;
