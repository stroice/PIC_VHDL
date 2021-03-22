library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ShiftRegistrer is
end;

architecture testbench of tb_ShiftRegistrer is
    component ShiftRegister
	port (	
				Reset		:	in	std_logic;
				Clk		    :	in  std_logic; 
				Enable	    :	in	std_logic;
				D			:	in	std_logic;
				Q			:	out	std_logic_vector (7 downto 0));
end component;
    
	    constant clk_period : time:= 50 ns; --Periodo del reloj simulado
		signal	Reset		:	std_logic;
		signal	Clk		    :   std_logic; 
		signal	Enable	    :	std_logic;
		signal	D			:	std_logic;
		signal	Q			:	std_logic_vector (7 downto 0);
	begin

--Mapeado de entradas y salidas del componente
    UUT: ShiftRegister
        port map (
             Reset => Reset,
             Clk => Clk,
             Enable => Enable,
             D	 => D,
             Q => Q);
			
-- Reloj
    process
    begin
        Clk <= '0' ;
		wait for clk_period/2;
        Clk <= '1' ;
		wait for clk_period/2;
    end process;
 

--Reset y Start 
    process
    begin
		Reset <= '0';
		Enable <= '0';
		D <= '0';
		wait for 200 ns;
		Reset <= '1';
		wait for 100 ns;
		Enable <= '1';
		D <= '1';
		wait for 100 ns; 
		D <= '0';
		wait for 100 ns; 
		D <= '1'; 
		wait for 400 ns;
		Reset <= '0';
        wait;      
    end process;
    
end testbench;