LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   Write_en : in    std_logic;
   OE       : in    std_logic;
   Address  : in    std_logic_vector(7 downto 0);
   Databus  : inout std_logic_vector(7 downto 0);
   Switches : out   std_logic_vector(7 downto 0);
   Temp_L   : out   std_logic_vector(6 downto 0);
   Temp_H   : out   std_logic_vector(6 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL Memoria : array8_ram(255 downto 0);
  SIGNAL Termostato_correct : unsigned(7 downto 0);
BEGIN

-------------------------------------------------------------------------
Escritura : process (reset, clk)
begin
  if reset='0' then
  --Para el reset, ponemos todos los valores a 0 excepto el termostato, que lo ponemos a 21
    for I in 0 to 48 loop
		Memoria(I) <= (others=>'0');
	end loop;
	
	Memoria(49) <= "00100101";
	
	for I in 50 to 63 loop
		Memoria(I) <= (others=>'0');
	end loop;
  
  elsif (clk'event and clk = '1') then
  --En caso de flanco de reloj y reset siendo 1, escribiremos si está requerido el dato en la posición del address
    if (write_en = '1' and oe = '1') then
      Memoria(to_integer(unsigned(address))) <= databus;
      
    end if;
  end if;

end process;



--outputs
databus <= Memoria(To_Integer(unsigned(address))) when (oe = '0') else
           (others => 'Z');
           
switches <= (Memoria(23)(0) & Memoria(22)(0) & Memoria(21)(0) & Memoria(20)(0) & Memoria(19)(0) & Memoria(18)(0) & Memoria(17)(0) & Memoria(16)(0));

-- Decodificador de BCD a 7 segmentos en formato decimal
with Memoria(49)(7 downto 4) select
Temp_H <=
    "1111001" when "0001",  -- 1
    "0100100" when "0010",  -- 2
    "0110000" when "0011",  -- 3
    "0011001" when "0100",  -- 4
    "0010010" when "0101",  -- 5
    "0000010" when "0110",  -- 6
    "1111000" when "0111",  -- 7
    "0000000" when "1000",  -- 8
    "0010000" when "1001",  -- 9
    "1000000" when "0000",  -- 0
    "1000111" when others;  -- F
    
    
with Memoria(49)(3 downto 0) select
Temp_L <=
    "1111001" when "0001",  -- 1
    "0100100" when "0010",  -- 2
    "0110000" when "0011",  -- 3
    "0011001" when "0100",  -- 4
    "0010010" when "0101",  -- 5
    "0000010" when "0110",  -- 6
    "1111000" when "0111",  -- 7
    "0000000" when "1000",  -- 8
    "0010000" when "1001",  -- 9
    "1000000" when "0000",  -- 0
    "1000111" when others;  -- F
    
END behavior;