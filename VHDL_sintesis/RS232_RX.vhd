----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2020 19:53:04
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
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

entity RS232_RX is
    port (
      Clk       : in  std_logic;
      Reset     : in  std_logic;
      LineRD_in : in  std_logic;
      Valid_out : out std_logic;
      Code_out  : out std_logic;
      Store_out : out std_logic);
end RS232_RX;

architecture Behavioral of RS232_RX is
type RS232_R_States is (Idle, StartBit, RecvBit, StopBit);
signal Estado_reg, Estado_next : RS232_R_States; 

signal DataCount_reg, Datacount_next : unsigned(3 downto 0);
signal PulseWidth_reg, pulseWidth_next  : unsigned(7 downto 0);
constant BitCounter : unsigned(7 downto 0) := "10101110"; --En caso de testearlo con RS232_TX_tb, se debe de utilizar el valor: "00000100"
constant HalfBitCounter : unsigned(7 downto 0) := "01010111"; --En caso de testearlo con RS232_TX_tb, se debe de utilizar el valor: "00000010"

begin 

ResetON : process(Reset, Clk)
begin
    if Reset = '0' then
        --Reseteamos todos los valores de la máquina de estados principal RS232RX
        Estado_reg <= Idle;
        
        DataCount_reg <=(others=>'0');
        PulseWidth_reg <=(others=>'0');
        

    elsif (Clk 'event and Clk='1') then
        --En caso de flanco positivo de reloj, copiamos los valores en el estado siguientes sobre los valores en el estado anterior
        Estado_reg <= Estado_next;
        
        DataCount_reg <= DataCount_next;
        PulseWidth_reg <= PulseWidth_next;
        
   end if;
end process;
   
--Máquina de estados principal del RS232RX
Maquina_Principal_RX : process(LineRD_in, Estado_reg, DataCount_reg, PulseWidth_reg)
begin
    Estado_next <= Estado_reg;
    DataCount_next <= DataCount_reg;
    PulseWidth_next <= PulseWidth_reg;
    
--Ahora, realizamos la máquina de estados propiamente
    case Estado_reg is
        when Idle =>
            Store_out <= '0';
            Valid_out <= '0';
            --Comprobamos el cambio de estado desde Idle
            if LineRD_in = '0' then
                Estado_next <= StartBit;
            end if;
        
        when StartBit =>
            Store_out <= '0';
            Valid_out <= '0';
            --Comprobamos el cambio de estado desde StartBit
            if PulseWidth_reg >= (HalfBitCounter-1)  then
                PulseWidth_next <= (others=>'0');
                if LineRD_in = '0' then 
                Estado_next <= RecvBit;
                else
                --Entrada no está en 0, por lo que la comunicación no se realizará, vuelta a esperar
                Estado_next <= Idle;
                
                end if;
            else
                PulseWidth_next <= PulseWidth_reg + 1;
            end if;

        when RecvBit =>
            --Comprobamos el cambio de estado desde RecvBit
            Store_out <= '0';
            if (PulseWidth_reg >= (BitCounter-1)) then
                PulseWidth_next <= (others=>'0');
                Valid_out <= '1';
                if DataCount_reg >= 7 then
                    Estado_next <= StopBit;
                else
                    DataCount_next <= DataCount_reg + 1;
                end if;
            else
                Valid_out <= '0';
                PulseWidth_next <= PulseWidth_reg + 1;
            end if;
        
        when StopBit =>
            Valid_out <= '0';
            --Comprobamos el cambio de estado desde StopBit
            --Primero vamos a comprobar si, el bit de parada es el que tiene que ser
            if (PulseWidth_reg >= (BitCounter-1)) then
                DataCount_next <= (others=>'0');
                PulseWidth_next <= (others => '0');
                --Bit de parada correcto, dara la oden de guardar el Byte
                if LineRD_in = '1' then
                Store_out <= '1';
                --Bit de parada incorrecto, no se guarda el Byte, de todas formas se va a esperar el tiempo asignado al bit de parada
                else
                Store_out <= '0';
                end if;
                --Ahora, tras la comprobación del bit de parada y pasado el tiempo asignado al mismo, regresamos a la posición de Idle
                --Nótese que el DataCount se utiliza en este caso para guardar si ya se ha comprobado el bit de parada o no
            elsif (PulseWidth_reg >= (HalfBitCounter-1))and (DataCount_reg = "0000") then
                Estado_next <= Idle;
                Store_out <= '0';
            else
                Store_out <= '0';
                PulseWidth_next <= PulseWidth_reg + 1;
            end if;
    end case;
end process;

   
   
--Igualamos la salida con la entrada de la linea
Code_out <= LineRD_in;    

end Behavioral;
