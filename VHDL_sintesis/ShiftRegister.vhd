----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2020 19:53:04
-- Design Name: 
-- Module Name: ShiftRegister - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
port (	
				Reset		:	in	std_logic;
				Clk		    :	in  std_logic; 
				Enable	    :	in	std_logic;
				D			:	in	std_logic;
				Q			:	out	std_logic_vector (7 downto 0));
end ShiftRegister;

architecture Behavioral of ShiftRegister is
signal Q_anterior : std_logic_vector (7 downto 0);

begin
--Creamos inicialmente un proceso sequencial para el análisis de las entradas
    process(Reset, Clk, Enable)
    begin
    --Primeramente, comprobamos que la señal de reset no se haya puesto a 0, momento en el cual se activaría poniendo a 0 la salida
        if (Reset = '0') then
        Q_anterior <= (others => '0');
        
        --En caso de no activarse el reset, ahora se comprobaría el que se produzca en flanco de subida en el reloj estando el enable a 1
        elsif (Clk 'event and Clk = '1' and Enable='1') then
        --En caso de que suceda, se añadirá en la posición 0 el nuevo valor de D y los otros 7 bits se desplazarán posiciones menos significativas
            Q_anterior <= D & Q_anterior (7 downto 1);
       
        end if;
    
    end process;
--Tras esto, igualamos los valores del Q anterior y al Q siguiente
Q <= Q_anterior;

end Behavioral;
