
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;
USE work.RS232_test.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk100MHz: in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    temp     : out std_logic_vector(7 downto 0);   -- Display value for T_STAT
    disp     : out std_logic_vector(7 downto 0));  -- Display activation for T_STAT
end PICtop;

architecture behavior of PICtop is
    
    -- This clock signal is the obtained after the clock generator
    signal Clk: std_logic;
    
    -- Connections between RS232TOP and DMA
    signal RX_Full, RX_Empty, Data_Read, Valid_D, Ack_out, TX_RDY: std_logic;
    signal RCVD_Data, TX_Data: std_logic_vector(7 downto 0);
    
    -- Bus connections
    signal RAM_OE_DMA, RAM_OE, RAM_OE_CPU, RAM_Write, RAM_Write_DMA, RAM_Write_CPU: std_logic;
    signal Address, Databus: std_logic_vector(7 downto 0);
    
    -- Connections between main control and DMA
    signal SEND_comm, DMA_ACK, DMA_READY, DMA_RQ: STD_LOGIC;
    
    -- Display values from RAM
    signal Temp_L, Temp_H: std_logic_vector(6 downto 0);
    
    -- Connections between main control and ALU
     signal u_instruction : std_logic_vector(5 downto 0);
     signal FlagZ, FlagC, FlagN, FlagE: std_logic;
     signal Index_Reg: std_logic_vector(7 downto 0);
     
     --Connections between main control and ROM
     signal ROM_Data: std_logic_vector(11 downto 0);
     signal ROM_Addr : std_logic_vector(11 downto 0);
     
     --Control Signal
     signal count: unsigned(15 downto 0);
     signal Displayed: std_logic;
  ------------------------------------------------------------------------
  -- Component for Clock Frequency modification
  ------------------------------------------------------------------------

  signal reset_p : std_logic;

  component Clk_Gen
    port (
      reset     : in  std_logic;
      clk_in1   : in  std_logic;
      clk_out1  : out  std_logic;
      locked    : out std_logic);
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
  
  component ALU
    port (
        Reset : in std_logic;    -- asynnchronous, active low
        Clk : in std_logic;    -- Sys clock, 20MHz, rising_edge
        u_instruction : in std_logic_vector(5 downto 0);      -- u-instructions from CPU
        FlagZ : out std_logic;    -- Zero flag
        FlagC : out std_logic;    -- Carry flag
        FlagN : out std_logic;    -- Nibble carry bit
        FlagE : out std_logic;    -- Error flag
        Index_Reg : out std_logic_vector(7 downto 0);   -- Index register
        Databus : inout std_logic_vector(7 downto 0)    -- System Data bus 
        );
  end component;
  
  component ROM
    port (
      Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
      Program_counter : in  std_logic_vector(11 downto 0));
  end component;
  
  component MAIN_CONTROL
    port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Write : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           SEND_comm : out  STD_LOGIC;
           DMA_READY : in  STD_LOGIC;
           Alu_op : out  std_logic_vector(5 downto 0);
           Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
           FlagZ : in  STD_LOGIC;
           FlagC : in  STD_LOGIC;
           FlagN : in  STD_LOGIC;
           FlagE : in  STD_LOGIC);
  end component;
  
begin  -- behavior

  reset_p <= not(Reset);		  -- active high reset
  
  Clock_generator : Clk_Gen
    port map (
      reset    => reset_p,   
      clk_in1  => Clk100MHz,
      clk_out1 => Clk,
      locked   => open);
      
  RS232top_PHY: RS232top
    port map (
        Reset => Reset,
        Clk       => Clk,
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
        Write_en => RAM_Write_DMA,
        OE => RAM_OE_DMA,
        DMA_RQ => DMA_RQ,
        DMA_ACK => DMA_ACK,
        Send_comm => SEND_comm,
        READY => DMA_READY);
        
  RAM_PHY: RAM
    port map (
        Clk => Clk,
        Reset => Reset,
        Write_en => RAM_Write,
        OE => RAM_OE,
        Address => Address,
        Databus => Databus,
        Switches => Switches,
        Temp_L => Temp_L,
        Temp_H => Temp_H);
        
        RAM_OE <= RAM_OE_DMA and RAM_OE_CPU;
        
        RAM_Write <= RAM_Write_DMA or RAM_Write_CPU;
        
  ALU_PHY: ALU
    port map (
         Reset => Reset,
         Clk => Clk,
         u_instruction => u_instruction,
         FlagZ => FlagZ,
         FlagC => FlagC,
         FlagN => FlagN,
         FlagE => FlagE,
         Index_Reg => Index_Reg,
         Databus => Databus
         );
         
  ROM_PHY: ROM
    port map (
         Instruction => ROM_Data,
         Program_Counter => ROM_Addr);
         
   MAIN_CONTROL_PHY: MAIN_CONTROL
     port map (
        Reset => Reset,
        Clk => Clk,
        ROM_Data => ROM_Data,
        ROM_Addr => ROM_Addr,
        RAM_Addr => Address,
        RAM_Write => RAM_Write_CPU,
        RAM_OE => RAM_OE_CPU,
        Databus => Databus,
        DMA_RQ => DMA_RQ,
        DMA_ACK => DMA_ACK,
        SEND_comm => SEND_comm,
        DMA_READY => DMA_READY,
        Alu_op => u_instruction,
        Index_Reg => Index_Reg,
        FlagZ => FlagZ,
        FlagC => FlagC,
        FlagN => FlagN,
        FlagE => FlagE);
        
 DisplayControl : process (Clk, Reset)
  begin
    if Reset = '0' then  -- asynchronous reset (active low)
      count   <= (others => '0');
      Displayed <= '0';
      disp <= "11111111";

    elsif Clk'event and Clk = '1' then  -- rising edge clock
      if count >= X"4E20" then
        count   <= (others => '0');
        if Displayed = '0' then
            Displayed <= '1';
            disp <= "11111101";
            temp <= "1" &  Temp_H;
        else
            Displayed <= '0';
            disp <= "11111110";
            temp <= "1" & Temp_L;
        end if;
        
      else
        count <= count + 1;
        if Displayed = '0' then
            disp <= "11111110";
            temp <= "1" & Temp_L;
        else
            disp <= "11111101";
            temp <= "1" & Temp_H;
        end if;
      end if;
    end if;
  end process DisplayControl;

end behavior;
