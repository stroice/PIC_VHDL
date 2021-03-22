
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;
USE work.RS232_test.all;

entity PICtop_tb is
end PICtop_tb;

architecture TestBench of PICtop_tb is

  component PICtop
    port (
      Reset    : in  std_logic;
      Clk100MHz: in  std_logic;
      RS232_RX : in  std_logic;
      RS232_TX : out std_logic;
      switches : out std_logic_vector(7 downto 0);
      temp     : out std_logic_vector(7 downto 0);
      disp     : out std_logic_vector(7 downto 0));
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset    : std_logic;
  signal Clk      : std_logic;
  signal RS232_RX : std_logic;
  signal RS232_TX : std_logic;
  signal switches : std_logic_vector(7 downto 0);
  signal temp     : std_logic_vector(7 downto 0);
  signal disp     : std_logic_vector(7 downto 0);

begin  -- TestBench

  UUT: PICtop
    port map (
        Reset    => Reset,
        Clk100MHz=> Clk,
        RS232_RX => RS232_RX,
        RS232_TX => RS232_TX,
        switches => switches,
        temp     => temp,
        disp     => disp);

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

  Reset <= '0', '1' after 75 ns;

  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 5 ns;
     wait for 10 ns;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  SEND_STUFF : process
  begin
  
  --Enceneder el Switch 4
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"49");
     wait for 40 us;
     Transmit(RS232_RX, X"34");
     wait for 40 us;
     Transmit(RS232_RX, X"31");
     wait for 250 us;
    
   --Poner el actuador 9 a 6 
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"41");
     wait for 40 us;
     Transmit(RS232_RX, X"38");
     wait for 40 us;
     Transmit(RS232_RX, X"36");
     wait for 250 us;
   
   --Poner termostato a 12
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"54");
     wait for 40 us;
     Transmit(RS232_RX, X"31");
     wait for 40 us;
     Transmit(RS232_RX, X"32");
     wait for 250 us;
     
   --Solicita informacion de actuador 9
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"53");
     wait for 40 us;
     Transmit(RS232_RX, X"41");
     wait for 40 us;
     Transmit(RS232_RX, X"38");
     
     wait;
  end process SEND_STUFF;
   
end TestBench;

