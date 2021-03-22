----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.12.2020 13:27:24
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is 
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
end ALU;

architecture Behavioral of ALU is
    Signal A : std_logic_vector (7 downto 0);
    Signal B: std_logic_vector (7 downto 0);
    Signal Acc: std_logic_vector (7 downto 0);
    Signal FlagC_reg, FlagZ_reg, FlagN_reg, FlagE_reg : std_logic;
begin

ResetON : process(Clk, reset)
    variable Aux : unsigned (8 downto 0);
    variable Aux_Nib: unsigned (4 downto 0);

begin
    
    if reset='0' then
        A <= (others => '0');
        B <= (others => '0');
        ACC <= (others => '0');
        Index_Reg <= (others => '0');
        
        FlagC_reg <= '0';
        FlagN_reg <= '0';
        FlagZ_reg <= '0';
        FlagE_reg <= '0';

    --Control por medio de flanco de reloj de los registros
    elsif (clk'event and clk = '1') then
          
    --Control de los registros, parte síncrona de la ALU 
            case u_instruction is
            
            -- external value load
            
                when op_lda =>
                    A <= Databus;
                when op_ldb =>
                    B <= Databus;
                when op_ldacc =>
                    ACC <= Databus;
                when op_mvacc2a =>
                    A <= ACC;
                when op_mvacc2b =>
                    B <= ACC;
                    
            -- arithmetic operations
                when op_add=>
                    Aux_Nib := unsigned('0' & A(3 downto 0)) + unsigned('0' & B(3 downto 0)); 
                    Aux := (((unsigned('0' & A(7 downto 4)) + unsigned('0' & B(7 downto 4))) + ("0000" & Aux_Nib(4))) & Aux_Nib(3 downto 0));
                    ACC <= std_logic_vector(Aux(7 downto 0));
                    
                when op_sub =>

                    Aux_Nib := (unsigned('0' & A(3 downto 0)) + unsigned('0' & Not(B(3 downto 0)))) + "00001"; 
                    Aux := (((unsigned('0' & A(7 downto 4)) + unsigned('0' & Not(B(7 downto 4)))) + ("0000" & Aux_Nib(4))) & Aux_Nib(3 downto 0));
                    ACC <= std_logic_vector(Aux(7 downto 0));
                
                when op_shiftl =>
                    ACC <= (ACC(6 downto 0) & '0');
                when op_shiftr =>
                    ACC <= ('0' & ACC(7 downto 1));
                    
            -- logic operations
                when op_and => 
                    Aux := ('0' & unsigned(A and B));
                    ACC <= std_logic_vector(Aux(7 downto 0));
                    
                when op_or =>
                    Aux := ('0' & unsigned(A or B));
                    ACC <= std_logic_vector(Aux(7 downto 0));
                    
                when op_xor =>
                    Aux := ('0' & unsigned(A xor B));
                    ACC <= std_logic_vector(Aux(7 downto 0));      

            -- conversion operations      
                when op_ascii2bin =>
                    if (A >= x"30" AND A <= x"39") then
                        ACC <= "0000" & A(3 downto 0);
                        FlagE_reg <= '0';
                    else
                        ACC <= x"FF";
                        FlagE_reg <= '1';
                    end if;
                when op_bin2ascii =>
                    if (A <= x"09") then
                        ACC <= "0011" & A(3 downto 0);
                        FlagE_reg <= '0';
                    elsif (A < x"10") then
                        ACC <= std_logic_vector(x"37" + unsigned (A));
                   
                    else
                        ACC <= x"FF";
                        FlagE_reg <= '1';
                    end if;
                
                when op_ldid =>
                    Index_Reg <= Databus;
    
                when op_mvacc2id =>
                    Index_Reg <= Acc;

                when nop =>
                    A <= A;
                    B <= B;
                    ACC <= Acc;
                
                when others => null;
          end case;
          
          --Control de los flags:
          
          --Control de flags C y N, controlados ambos por las mismas instrucciones
          if (u_instruction = op_sub or u_instruction = op_add) then
            FlagC_reg <= Aux(8);
            FlagN_reg <= Aux_Nib(4);
            
          end if;
          
          --Control del Flag Z
          if ((u_instruction = op_add) or (u_instruction = op_sub)or (u_instruction = op_and) or (u_instruction = op_or) or (u_instruction = op_xor)) then
          
            if (Aux(7 downto 0) = 0) then
                FlagZ_reg <= '1';
            else
                FlagZ_reg <= '0';
            end if;
          --Control del Flag Z para comparaciones  
          elsif (u_instruction = op_cmpe) then
          
            if (A = B) then
                FlagZ_reg <= '1';
            else
                FlagZ_reg <= '0';
            end if;
          
          elsif (u_instruction = op_cmpl) then
          
            if (A < B) then
                FlagZ_reg <= '1';
            else
                FlagZ_reg <= '0';
            end if;
            
          elsif (u_instruction = op_cmpg) then
          
            if (A > B) then
                FlagZ_reg <= '1';
            else
                FlagZ_reg <= '0';
            end if;
          end if;
            
        end if;
        
end process;


--Control del Databus, no dependiente del reloj
DatabusControl : process(u_instruction, Acc)
begin

if (u_instruction = op_oeacc) then
    Databus <= ACC;
else
    Databus<= (others => 'Z');
    
end if;

end process;
 
 --Control de los flags
FlagC <= FlagC_reg;
FlagN <= FlagN_reg;
FlagZ <= FlagZ_reg;
FlagE <= FlagE_reg;
 
end Behavioral;