----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2020 12:44:50
-- Design Name: 
-- Module Name: ram_tb - Behavioral
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

entity ram_tb is
--  Port ( );
end ram_tb;

architecture Behavioral of ram_tb is
component ram
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

    constant Clk_period : time:= 50 ns; --Periodo del reloj simulado
    signal Clk      : std_logic;
    signal Reset    : std_logic;
    signal Write_en : std_logic;
    signal OE       : std_logic;
    signal Address  : std_logic_vector(7 downto 0);
    signal Databus  : std_logic_vector(7 downto 0);
    signal Switches : std_logic_vector(7 downto 0);
    signal Temp_L   : std_logic_vector(6 downto 0);
    signal Temp_H   : std_logic_vector(6 downto 0);

begin

--Mapeado de entradas y salidas del componente
    UUT: ram
    port map (
        Clk      => Clk,
        Reset    => Reset,
        Write_en => Write_en,
        OE       => OE,
        Address  => Address,
        Databus  => Databus,
        Switches => Switches,
        Temp_L   => Temp_L,
        Temp_H   => Temp_H);

-- Reloj
    process
    begin
        Clk <= '0' ;
		wait for Clk_period/2;
        Clk <= '1' ;
		wait for Clk_period/2;
    end process;
    
    --Reset y Start 
    process
    begin
		Reset <= '0';
		Write_en <='0';
		OE <= '1';
		Address <= (others =>'0');
		Databus <= (others =>'Z');
		--Las salidas al bus deben estar a X "alta impedancia", los switches serán 0 y el termostato dará 21 en sgmentos de 8 bits
		wait for 200 ns;
		Reset <= '1';
		wait for 50 ns;
		--cambiamos el valor de los Switches
		Address <= x"10";
		Databus <= "10100110";
		wait for 25 ns;
		write_en <='1';
		wait for 75 ns;
		write_en <= '0';
		wait for 75 ns;
		
		--Escribimos en el byte más significativo de la DMA
		Address <= x"04";
		Databus <= "10001110";
		wait for 75 ns;
		write_en <='1';
		wait for 75 ns;
		write_en <= '0';
		
		--Reescribimos el termostato
		Address <= x"31";
		Databus <= "00001111";--15
		wait for 75 ns;
		write_en <='1';
		wait for 75 ns;
		write_en <= '0';
		
		--Probamos la memoria de propósito general
		Address <= x"60";
		Databus <= "10110000";
		wait for 75 ns;
		write_en <='1';
		wait for 75 ns;
		write_en <= '0';
		
		--Leemos la posiciones de ambas memorias
		wait for 75 ns;
		Address <= x"60";
		Databus <= (others => 'Z');
		wait for 75 ns;
		OE <= '0';
		wait for 100 ns;
		Address <= x"04";
		wait for 100 ns;

        --Reseteamos y comprobamos de nuevo los valores de la memoria, el valor de la memoria específica cambiará mientras que la de propósito general se mantendrá igual "tambien el termostato y los switches deberán cambiar"
        Reset <= '0';
        wait for 100 ns;
        Reset <= '1';
        wait for 100 ns;
        Address <= x"60";
        wait for 100 ns;
        Reset <= '0';

        wait;
    end process;


end Behavioral;
