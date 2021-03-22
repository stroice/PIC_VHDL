----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2020 17:58:27
-- Design Name: 
-- Module Name: DMA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMA is

PORT (
   Clk       : in    std_logic;
   Reset     : in    std_logic;
   --Connection with RAM
   Write_en  : out   std_logic;
   OE        : out   std_logic;
   Address   : out   std_logic_vector(7 downto 0);
   Databus   : inout std_logic_vector(7 downto 0);
   --Connection with processor
   Send_comm : in    std_logic;
   DMA_ACK   : in    std_logic;
   DMA_RQ    : out   std_logic;
   Ready     : out   std_logic;
   --Connection with RS232, RX
   RCVD_Data : in    std_logic_vector(7 downto 0);
   RX_Full   : in    std_logic;
   RX_Empty  : in    std_logic;
   Data_Read : out   std_logic;
   --Connection with RS232, TX
   ACK_out   : in    std_logic;
   TX_RDY    : in    std_logic;
   Valid_D   : out   std_logic;
   TX_Data   : out   std_logic_vector(7 downto 0));

end DMA;

architecture Behavioral of DMA is

type DMA_States is (Idle, --Estado de espera
Wait_For_Buses, Mem_Write, End_Write, EndCommand_PrepareValues, EndCommand_Write, EndCommand_Finish,  --Estados para la lectura
Load_Byte_0, Load_Byte_1, Start_Byte_1, Wait_Byte_1, Load_Byte_2, Start_Byte_2, Wait_Byte_2, Finishing); --Estados para la escritura
signal Estado_DMA_reg, Estado_DMA_next: DMA_States;

signal Read_Mem_Position_reg,Read_Mem_Position_next: unsigned(7 downto 0);
signal TX_RDY_Next, TX_RDY_reg, DMA_RQ_reg, Ready_reg, Data_read_reg, Valid_D_reg  : std_logic;
signal TX_Data_reg  :   std_logic_vector(7 downto 0);

signal DMA_RQ_Next, Ready_Next, Data_read_Next, Valid_D_Next, end_var  : std_logic;
signal TX_Data_Next  :   std_logic_vector(7 downto 0);
begin

ResetON : process(Reset, Clk)
begin
    if Reset = '0' then

        --Internal Values
        Estado_DMA_reg  <= Idle;
        Read_Mem_Position_reg <= (others => '0');

        DMA_RQ_reg    <= '0';
        Ready_reg     <= '1';
        Data_read_reg <= '0';
        TX_Data_reg   <= (others => '0');
        Valid_D_reg   <= '1';
        TX_RDY_reg    <= '0';
        
    elsif (Clk 'event and Clk='1') then
        --En caso de flanco positivo de reloj, copiamos los valores en el estado siguientes sobre los valores en el estado anterior
        Estado_DMA_reg  <= Estado_DMA_next;
        Read_Mem_Position_reg <= Read_Mem_Position_next;
        
        DMA_RQ_reg    <= DMA_RQ_Next;
        Ready_reg     <= Ready_Next;
        Data_read_reg <= Data_read_Next;
        TX_Data_reg   <= TX_Data_Next;
        Valid_D_reg   <= Valid_D_Next;
        TX_RDY_reg    <= TX_RDY_Next;
   end if;
end process;

Maquina_Principal_DMA : process(Estado_DMA_reg, Read_Mem_Position_reg, Send_comm, DMA_ACK, RCVD_Data, RX_Empty, TX_RDY, Databus,DMA_RQ_reg, Ready_reg, Data_read_reg, TX_Data_reg, Valid_D_reg, TX_RDY_reg)
begin
    Estado_DMA_next  <= Estado_DMA_reg;
    Read_Mem_Position_next <= Read_Mem_Position_reg;
    
    Write_en  <= '0';
    OE        <= '1';
    Address   <= (others => 'Z');
    Databus   <= (others => 'Z');
    
    DMA_RQ_next    <= DMA_RQ_reg;
    Ready_next     <= Ready_reg;
    Data_read_next <= Data_read_reg;
    TX_Data_next   <= TX_Data_reg;
    Valid_D_next   <= Valid_D_reg;
    TX_RDY_Next    <= TX_RDY;
    end_var <= '0';
--Ahora, realizamos la máquina de estados propiamente

    case Estado_DMA_reg is
        when Idle =>

            DMA_RQ_Next    <= '0';
            Ready_Next     <= '1';
            Data_read_Next <= '0';
            TX_Data_Next   <= (others => '0');
            Valid_D_Next   <= '1';
            
            --Check if somthing is requested
            if Send_comm = '1' then
                Estado_DMA_next <= Load_Byte_0;
                Ready_Next     <= '0';
            elsif RX_Empty = '0' then
                Estado_DMA_next <= Wait_For_Buses;
                Ready_Next     <= '0';
            end if;
 
        --Estados para la Lectura:
        when Wait_For_Buses=>      
            DMA_RQ_Next    <= '1';
            Data_read_Next <= '1';
            if DMA_ACK = '1' then
                Estado_DMA_next <= Mem_Write;
                Address <= std_logic_vector(Read_Mem_Position_reg);
                Databus <= RCVD_Data;
                Write_en  <= '0';
                OE <= '1';
            end if;
            
        when Mem_Write=>
            OE  <= '1';
            Address <= std_logic_vector(Read_Mem_Position_reg);
			Databus <= RCVD_Data;
            Write_en  <= '1';
            
            Estado_DMA_next <= End_Write;
            
        when End_Write=>
            Write_en  <= '0';
            OE  <= '1';
            Address <= std_logic_vector(Read_Mem_Position_reg);
			Databus <= RCVD_Data;

            Data_Read_Next <= '0';
            if Read_Mem_Position_reg = 2 then
                Estado_DMA_next <= EndCommand_PrepareValues;
            else
                Read_Mem_Position_next <= Read_Mem_Position_reg + 1;
                Estado_DMA_next <= IDLE;
            end if;
            
        when EndCommand_PrepareValues=>
            Read_Mem_Position_next <= (others => '0');
            Write_en  <= '0';
            OE  <= '1';
            Address <= x"03";
            Databus <= x"ff";
            Estado_DMA_next <= EndCommand_Write;
            
        when EndCommand_Write=>
            Write_en  <= '1';
            OE  <= '1';
            Address <= x"03";
            Databus <= x"ff";
            
            Estado_DMA_next <= EndCommand_Finish;

        when EndCommand_Finish=>
            Write_en  <= '0';
            OE  <= '1';
            Address <= x"03";
            Databus <= x"ff";
            Estado_DMA_next <= IDLE;
            
        --Estados para la escritura:
        when Load_Byte_0 =>
             Write_en  <= '0';
             OE <= '0';
             Address <= x"04";
             Estado_DMA_next <= Load_Byte_1;
             
        when Load_Byte_1 =>
            Write_en  <= '0';
            OE <= '0';
            Address <= x"04";    
            Tx_Data_Next <= Databus;
            Estado_DMA_next <= Start_Byte_1;
            
        when Start_Byte_1 =>
            Write_en  <= '0';
            OE <= '0';
            Address <= x"04";
                
            Tx_Data_Next <= Databus;
            Valid_D_Next <= '0';
            Estado_DMA_next <= Wait_Byte_1;
            
        when Wait_Byte_1 =>
            Valid_D_Next <= '1';
            Write_en  <= '0';
            OE <= '1';
            Tx_Data_Next <= Databus;
            
            if TX_RDY_reg = '0' and TX_RDY = '1' then
                Write_en  <= '0';
                OE <= '0';
                Estado_DMA_next <= Load_Byte_2;
            end if;
            
        when Load_Byte_2 =>
            Write_en  <= '0';
            OE <= '0';
            Address <= x"05";
            
            Tx_Data_Next <= Databus;
            Estado_DMA_next <= Start_Byte_2;
            
        when Start_Byte_2 =>
            Write_en  <= '0';
            OE <= '0';
            Address <= x"05";
            Tx_Data_Next <= Databus;
            
            Valid_D_Next <= '0';
            Estado_DMA_next <= Wait_Byte_2;
            
        when Wait_Byte_2 =>
            Valid_D_Next <= '1';
            Write_en  <= '0';
            OE <= '1';
            Tx_Data_Next <= Databus;
            if TX_RDY_reg = '0' and TX_RDY = '1' then
                DMA_RQ_Next    <= '0';
                Ready_Next     <= '1';
                Data_read_Next <= '0';
                Estado_DMA_next <= Finishing;
            end if;
            
        when Finishing =>
            
            DMA_RQ_Next    <= '0';
            Ready_Next     <= '1';
            end_var<='1';
            Write_en  <= '0';
            OE <= '1';
            Data_read_Next <= '0';
            TX_Data_Next   <= (others => '0');
            Valid_D_Next   <= '1';
            Estado_DMA_next <= IDLE;

    end case;   
end process;

--output logic
DMA_RQ    <= DMA_RQ_reg;
Ready    <=  '1' when end_var = '1' else not(Send_comm);
Data_read <= Data_read_reg;
TX_Data   <= TX_Data_reg;
Valid_D   <= Valid_D_reg;

end Behavioral;