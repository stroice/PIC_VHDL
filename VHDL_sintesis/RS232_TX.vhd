----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2020 19:53:04
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
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
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_TX is
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      Start : in  std_logic;
      Data  : in  std_logic_vector(7 downto 0);
      EOT   : out std_logic;
      TX    : out std_logic);
end RS232_TX;

architecture Behavioral of RS232_TX is
type RS232_States is (Idle, StartBit, SendData, StopBit);
signal Estado_RS232TX_reg, Estado_RS232TX_next: RS232_States;
signal TX_reg, TX_next: std_logic;
signal DataCount_reg, Datacount_next : unsigned(3 downto 0);

signal PulseWidth_reg, pulseWidth_next  : unsigned(7 downto 0);
constant PulseEndOfCount : unsigned(7 downto 0) := "10101110"; --En caso de testearlo con RS232_TX_tb, se debe de utilizar el valor: "00000100"

begin

--Comenzamos con el proceso de resetear los valores al valor inicial si reset está a 0.
ResetON : process(Reset, Clk)
begin
    if Reset = '0' then
        --Reseteamos todos los valores
        Estado_RS232TX_reg <=Idle;
        TX_reg <='1';
        DataCount_reg <=(others=>'0');

        PulseWidth_reg <=(others=>'0');

    elsif (Clk 'event and Clk='1') then
        --En caso de flanco positivo de reloj, copiamos los valores en el estado siguientes sobre los valores en el estado anterior
        DataCount_reg <= DataCount_next;
        TX_reg <= TX_next;
        PulseWidth_reg <= PulseWidth_next;
        Estado_RS232TX_reg <= Estado_RS232TX_next;
        
   end if;
end process;

--Máquina de estados principal del RS232TX
Maquina_RS232Tx_Principal : process(Start, Data, Estado_RS232TX_reg, DataCount_reg, PulseWidth_reg,TX_reg)
begin
    Estado_RS232TX_next <= Estado_RS232TX_reg;
    DataCount_next <= DataCount_reg;
    TX_next <= TX_reg;
    PulseWidth_next <= PulseWidth_reg;
    
--Ahora, realizamos la máquina de estados propiamente
    case Estado_RS232TX_reg is
        when Idle =>
            --Comprobamos el cambio de estado desde Idle
            if Start = '1' then
                TX_next <= '0';
                DataCount_next <= (others=>'0');
                Estado_RS232TX_next <= StartBit;
                PulseWidth_next <= (others => '0');
            end if;
        
        when StartBit =>
            --Comprobamos el cambio de estado desde StartBit
            if PulseWidth_reg >= (PulseEndOfCount-1) then
                TX_next <= Data(0);
                PulseWidth_next <= (others => '0');
                Estado_RS232TX_next <= SendData;
                DataCount_next <= "0001";
                
            else
                PulseWidth_next <= PulseWidth_reg + 1;
            end if;

        when SendData =>
            --Comprobamos el cambio de estado desde SendData
            if PulseWidth_reg >= (PulseEndOfCount-1) then
            PulseWidth_next <= (others => '0');
                if DataCount_reg >= 8 then
                    TX_next <= '1';
                    Estado_RS232TX_next <= StopBit;
                    DataCount_next <= (others=>'0');
                else
                    TX_next <= Data(TO_INTEGER (DataCount_reg));
                    DataCount_next <= DataCount_reg + 1;
                end if;
            else
                PulseWidth_next <= PulseWidth_reg + 1;
            end if;
        
        when StopBit =>
            --Comprobamos el cambio de estado desde StopBit
            if PulseWidth_reg >= (PulseEndOfCount-1) then
                TX_next <= '1';
                Estado_RS232TX_next <= Idle;
                PulseWidth_next <= (others => '0');
            else
                PulseWidth_next <= PulseWidth_reg + 1;
            end if; 
    end case;
end process;

--output logic
process(Estado_RS232TX_reg, TX_reg)
begin
    TX <= TX_reg;
    if Estado_RS232TX_reg <= Idle then
        EOT<='1';
    else 
        EOT<='0';
    end if;
end process;

end Behavioral;
