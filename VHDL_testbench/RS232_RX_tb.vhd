----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.11.2020 23:43:14
-- Design Name: 
-- Module Name: RS232_RX_tb - Behavioral
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

entity RS232_RX_tb is
--  Port ( );
end RS232_RX_tb;

architecture testbench of RS232_RX_tb is
component RS232_RX
	port (	
      Clk       : in  std_logic;
      Reset     : in  std_logic;
      LineRD_in : in  std_logic;
      Valid_out : out std_logic;
      Code_out  : out std_logic;
      Store_out : out std_logic);
end component;

      constant Clk_period : time:= 50 ns; --Periodo del reloj simulado
      signal Clk       : std_logic;
      signal Reset     : std_logic;
      signal LineRD_in : std_logic;
      signal Valid_out : std_logic;
      signal Code_out  : std_logic;
      signal Store_out : std_logic;
	begin


--Important!!! Simulation to be run in 6000ns, Remember to change the BitCounter and HalfBitCounter values inside RS232_RX

--Mapeado de entradas y salidas del componente
    UUT: RS232_RX
        port map (
             Reset => Reset,
             Clk => Clk,
             LineRD_in => LineRD_in,
             Valid_out => Valid_out,
             Code_out => Code_out,
             Store_out  => Store_out);

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
		LineRD_in <= '1';
		wait for 200 ns;
		Reset <= '1';
		wait for 50 ns;
		--Bit de inicio de recepción
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 0
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 1
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 2
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 3
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 4
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 5
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 6
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 7
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit de fin de recepción
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Comenzar segundo Byte
		
		--Bit de inicio de recepción
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 0
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 1
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 2
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 3
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 4
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 5
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit 6
		LineRD_in <= '0';
		wait for 200 ns;
		
		--Bit 7
		LineRD_in <= '1';
		wait for 200 ns;
		
		--Bit de fin de recepción
		LineRD_in <= '1';
		
        wait;
    end process;

end testbench;
