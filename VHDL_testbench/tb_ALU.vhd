----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.12.2020 14:04:10
-- Design Name: 
-- Module Name: tb_ALU - Behavioral
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

USE work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_ALU is
end tb_ALU;

architecture Testbench of tb_ALU is
component ALU
    port (
        Reset : in std_logic;    -- asynnchronous, active low
        Clk : in std_logic;    -- Sys clock, 20MHz, rising_edge
        u_instruction : in std_logic_vector(5 downto 0);       -- u-instructions from CPU
        FlagZ : out std_logic;    -- Zero flag
        FlagC : out std_logic;    -- Carry flag
        FlagN : out std_logic;    -- Nibble carry bit
        FlagE : out std_logic;    -- Error flag
        Index_Reg : out std_logic_vector(7 downto 0);   -- Index register
        Databus : inout std_logic_vector(7 downto 0)    -- System Data bus 
        );
end component;
    
    Signal Reset : std_logic; 
    Signal Clk : std_logic; 
    Signal u_instruction : std_logic_vector(5 downto 0); 
    Signal FlagZ : std_logic; 
    Signal FlagC : std_logic;
    Signal FlagN : std_logic; 
    Signal FlagE : std_logic;  
    Signal Index_Reg : std_logic_vector(7 downto 0); 
    Signal Databus : std_logic_vector(7 downto 0);
begin
    
--Mapeado de entradas y salidas del componente
    UUT: ALU
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
         
    p_clk20MHz : PROCESS
    BEGIN
        Clk <= '1', '0' after 25 ns;
        wait for 50 ns;
    END PROCESS;
    
     
     tryInstructions : PROCESS
     BEGIN
        Reset <= '0';
        wait for 50 ns;
        Reset <= '1';
        wait for 100 ns; 
        u_instruction <= nop;
        
        wait until CLK'event and CLK='1';
        
        --Instrucción 1, 04 en simulación
        --Cargar f0 en Index_Reg de forma directa
        Databus <= x"F0";
        u_instruction <= op_ldid;
        wait until CLK'event and CLK='1';
        
        --Instrucción 2, 03 en simulación
        --Cargar 0f en el acumulador de forma síncrona
        Databus <= x"0F";
        u_instruction <= op_ldacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 3, 14 en simulación
        --Cargar 0f en el Databus de forma directa
        Databus <= (others => 'Z');
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 4, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 5, 01 en simulación
        --Cargar 02 en el registro A de forma síncrona
        Databus <= x"02";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 6, 02 en simulación
        --Cargar 01 en el registro B de forma síncrona
        Databus <= x"01";
        u_instruction <= op_ldb;
        wait until CLK'event and CLK='1';
        
        --Instrucción 6, 08 en simulación
        --Sumar A + B y cargar 03 "el resultado" en el registro Acc de forma síncrona
        Databus <= (others => 'Z');
        wait for 1 ns;
        u_instruction <= op_add;
        wait until CLK'event and CLK='1';
        
        --Instrucción 7, 14 en simulación
        --Cargar 03 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 8, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 9, 09 en simulación
        --Restar A - B y cargar 01 "el resultado" en el registro Acc de forma síncrona
        u_instruction <= op_sub;
        wait until CLK'event and CLK='1';
        
        --Instrucción 10, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 11, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 12, 06 en simulación
        --Cargar en A el valor 01 del Acc de forma síncrona
        u_instruction <= op_mvacc2a;
        wait until CLK'event and CLK='1';
        
        --Instrucción 13, 09 en simulación
        --Restar A - B y cargar 00 "el resultado" en el registro Acc de forma síncrona
        u_instruction <= op_sub;
        wait until CLK'event and CLK='1';
        
        --Instrucción 14, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 15, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 16, 05 en simulación
        --Cargar 00 en el registro Index_Reg de forma directa
        u_instruction <= op_mvacc2id;
        wait until CLK'event and CLK='1';
        
        --Instrucción 17, 03 en simulación
        --Cargar 0F en el Acc en el de forma síncrona
        Databus <= x"0F";
        u_instruction <= op_ldacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 19, 07 en simulación
        --Cargar 0F en el B en el de forma síncrona
        Databus <= (others => 'Z');
        wait for 1 ns;
        u_instruction <= op_mvacc2b;
        wait until CLK'event and CLK='1';
        
        
        --Instrucción 20, 08 en simulación
        --Sumar A + B y cargar 10 "el resultado" en el registro Acc de forma síncrona
        u_instruction <= op_add;
        wait until CLK'event and CLK='1';
        
        --Instrucción 21, 14 en simulación
        --Cargar 10 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 22, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 23, 09 en simulación
        --Restar A - B y cargar f2 "el resultado" en el registro Acc de forma síncrona " notese que el Flag C no es 1 ya que B es mayor que A
        u_instruction <= op_sub;
        wait until CLK'event and CLK='1';
        
        --Instrucción 24, 14 en simulación
        --Cargar f2 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 25, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 26, 01 en simulación
        --Cargar F1 en el registro A de forma síncrona
        Databus <= x"F1";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 27, 09 en simulación
        --Restar A - B y cargar e2 "el resultado" en el registro Acc de forma síncrona
        Databus <= (others => 'Z');
        wait for 1 ns;
        u_instruction <= op_sub;
        wait until CLK'event and CLK='1';
        
        --Instrucción 28, 14 en simulación
        --Cargar e2 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 29, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 30, 08 en simulación
        --Sumar A + B y cargar 00 "el resultado" en el registro Acc de forma síncrona
        u_instruction <= op_add;
        wait until CLK'event and CLK='1';
        
        --Instrucción 31, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa, los flags Z, C y N se activarán
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 32, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 33, 01 en simulación
        --Cargar E0 en el registro A de forma síncrona
        Databus <= x"E0";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 34, 02 en simulación
        --Cargar F0 en el registro B de forma síncrona
        Databus <= x"F0";
        u_instruction <= op_ldb;
        wait until CLK'event and CLK='1';
        
        --Instrucción 35, 08 en simulación
        --Sumar A + B y cargar D0 "el resultado" en el registro Acc de forma síncrona, "notese que  hay overflow, se enciende el flag C"
        Databus <= (others => 'Z');
        wait for 1 ns;
        u_instruction <= op_add;
        wait until CLK'event and CLK='1';
        
        --Instrucción 36, 14 en simulación
        --Cargar D0 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 37, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 38, 09 en simulación
        --Restar A - B y cargar F0 "el resultado" en el registro Acc de forma síncrona, nótese que el flag C no se activa ya que A es menor que B
        u_instruction <= op_sub;
        wait until CLK'event and CLK='1';
        
        --Instrucción 39, 14 en simulación
        --Cargar F0 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 40, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        
        --Instrucción 41, 10 en simulación
        --Función lógica A < B y carga resultado 1 en flag z
        u_instruction <= op_cmpl;
        wait until FlagZ = '1';
        
        --Instrucción 42, 0F en simulación
        --Función lógica A = B y carga resultado 0 en flag z
        u_instruction <= op_cmpe;
        wait until FlagZ = '0';
        
        --Instrucción 43, 10 en simulación
        --Función lógica A < B y carga resultado 1 en flag z
        u_instruction <= op_cmpl;
        wait until FlagZ = '1';
        
        --Instrucción 41, 11 en simulación
        --Función lógica A = B y carga resultado 0 en flag z
        u_instruction <= op_cmpg;
        wait until FlagZ = '0';

        --Instrucción 42, 01 en simulación
        --Cargar 00 en el registro A de forma síncrona
        Databus <= x"00";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 43, 02 en simulación
        --Cargar 00 en el registro B de forma síncrona
        u_instruction <= op_ldb;
        wait until CLK'event and CLK='1';
        
        --Instrucción 44, 0C en simulación
        --And entre A y B, cargar 00 en el registro AA de forma síncrona, nótese que se activa el Flag Z ya que el resultado es 0
        Databus <= (others => 'Z');
        wait for 1 ns;
        -- A = 00 and B = 00
        u_instruction <= op_and;
        wait until CLK'event and CLK='1';
        
        --Instrucción 45, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 46, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 47, 0D en simulación
        --OR entre A y B, cargar 00 en el registro AA de forma síncrona, nótese que se activa el Flag Z ya que el resultado es 0
        u_instruction <= op_or;
        wait until CLK'event and CLK='1';
        
        --Instrucción 48, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 49, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        
        --Instrucción 50, 0E en simulación
        --XOR entre A y B, cargar 00 en el registro AA de forma síncrona, nótese que se activa el Flag Z ya que el resultado es 0
        u_instruction <= op_xor;
        wait until CLK'event and CLK='1';
        
        --Instrucción 51, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 52, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 53, 01 en simulación
        --Cargar 01 en el registro A de forma síncrona
        Databus <= x"01";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 54, 0C en simulación
        --And entre A y B, cargar 00 en el registro Acc de forma síncrona, nótese que se activa el Flag Z ya que el resultado es 0
        Databus <= (others => 'Z');
        wait for 1 ns;
        u_instruction <= op_and;
        wait until CLK'event and CLK='1';
        
        --Instrucción 55, 14 en simulación
        --Cargar 00 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 56, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 57, 0D en simulación
        --OR entre A y B, cargar 01 en el registro AA de forma síncrona
        -- A = 01 and B = 00
        u_instruction <= op_or;
        wait until CLK'event and CLK='1';
        
        --Instrucción 58, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 59, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 60, 0E en simulación
        --XOR entre A y B, cargar 01 en el registro AA de forma síncrona
        -- A = 01 and B = 00
        u_instruction <= op_xor;
        wait until CLK'event and CLK='1';
        
        --Instrucción 61, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 62, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 63, 0A en simulación
        --Desplazamiento del registro Acc a la izquierda, pasando del valor 01 al 02 de forma síncrona
        u_instruction <= op_shiftl;
        wait until CLK'event and CLK='1';
        
        --Instrucción 64, 14 en simulación
        --Cargar 02 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 65, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 66, 0B en simulación
        --Desplazamiento del registro Acc a la derecha, pasando del valor 02 al 01 de forma síncrona
        u_instruction <= op_shiftr;
        wait until CLK'event and CLK='1';
        
        --Instrucción 67, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 68, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 69, 11 en simulación
        --Función lógica A > B y carga resultado 1 en flag z
        u_instruction <= op_cmpg;
        wait until CLK'event and CLK='1';
        
        --Instrucción 70, 10 en simulación
        --Función lógica A < B y carga resultado 0 en flag z
        u_instruction <= op_cmpl;
        wait until CLK'event and CLK='1';
        
        --Instrucción 71, 11 en simulación
        --Función lógica A > B y carga resultado 1 en flag z
        u_instruction <= op_cmpg;
        wait until CLK'event and CLK='1';
        
        --Instrucción 72, 0f en simulación
        --Función lógica A = B y carga resultado 0 en flag z
        u_instruction <= op_cmpe;
        wait until CLK'event and CLK='1';
        
        --Instrucción 73, 02 en simulación
        --Cargar 01 en el registro B de forma síncrona
        Databus <= x"01";
        u_instruction <= op_ldb;
        wait until CLK'event and CLK='1';
        
        --Instrucción 74, 0C en simulación
        --And entre A y B, cargar 01 en el registro Acc de forma síncrona
        Databus <= (others => 'Z');
        wait for 1 ns;
        -- A = 01 and B = 01
        u_instruction <= op_and;
        wait until CLK'event and CLK='1';
        
        --Instrucción 75, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 76, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 77, 0D en simulación
        --OR entre A y B, cargar 01 en el registro Acc de forma síncrona
        -- A = 01 and B = 01
        u_instruction <= op_or;
        wait until CLK'event and CLK='1';
        
        --Instrucción 78, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 79, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 80, 0E en simulación
        --XOR entre A y B, cargar 01 en el registro Acc de forma síncrona
        -- A = 01 and B = 01
        u_instruction <= op_xor;
        wait until CLK'event and CLK='1';
        
        --Instrucción 81, 14 en simulación
        --Cargar 01 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 82, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 83, 10 en simulación
        --Función lógica A < B y carga resultado 0 en flag z
        -- A = 01 and B = 01
        u_instruction <= op_cmpl;
        wait until CLK'event and CLK='1';
        
        --Instrucción 84, 0F en simulación
        --Función lógica A = B y carga resultado 1 en flag z
        u_instruction <= op_cmpe;
        wait until CLK'event and CLK='1';
        
        --Instrucción 85, 11 en simulación
        --Función lógica A > B y carga resultado 0 en flag z
        u_instruction <= op_cmpg;
        wait until CLK'event and CLK='1';
        
        --Instrucción 86, 13 en simulación
        --Carga del valor convertido de A al codigo ASCII en ACC
        u_instruction <= op_bin2ascii;
        wait until CLK'event and CLK='1';
        
        --Instrucción 87, 14 en simulación
        --Cargar 31 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 88, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 89, 12 en simulación
        --Carga del valor convertido de A al codigo binario en ACC "notese que no es un valor válido por lo que pone FF y da error el flag"
        u_instruction <= op_ascii2bin;
        wait until CLK'event and CLK='1';
        
        --Instrucción 90, 14 en simulación
        --Cargar 31 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 91, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 92, 01 en simulación
        --Cargar 35 en el registro A de forma síncrona
        Databus <= x"35";
        u_instruction <= op_lda;
        wait until CLK'event and CLK='1';
        
        --Instrucción 93, 13 en simulación
        --Carga del valor convertido de A al codigo ASCII en ACC "notese que no es un valor válido por lo que pone FF y da error el flag"
        Databus <= (others => 'Z');
        -- A = 35
        u_instruction <= op_bin2ascii;
        wait until CLK'event and CLK='1';
        
        --Instrucción 94, 14 en simulación
        --Cargar 31 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 95, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        --Instrucción 96, 12 en simulación
        --Carga del valor convertido de A al codigo binario en ACC, 5
        -- A = 35
        u_instruction <= op_ascii2bin;
        wait until CLK'event and CLK='1';
        
        --Instrucción 97, 14 en simulación
        --Cargar 5 en el registro Databus de forma directa
        u_instruction <= op_oeacc;
        wait until CLK'event and CLK='1';
        
        --Instrucción 98, 00 en simulación
        --No hacer nada, ZZ en Databus de forma directa
        u_instruction <= nop;
        wait until CLK'event and CLK='1';
        
        
        wait;
     END PROCESS;

end Testbench;