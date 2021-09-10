----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2020 09:48:43 PM
-- Design Name: 
-- Module Name: sim - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim is
generic(
    length    : integer := 17;
    iteration : integer := 16
        );
--  Port ( );
end sim;

architecture Behavioral of sim is

signal clk,reset,start,done : std_logic;
signal cos,sin,angle : signed (length-1 downto 0);
constant clk_period : time:= 80ns;

signal check : std_logic_vector(2 downto 0);

begin

uut:entity work.cordic(Behavioral)
    port map(clk => clk,
        reset => reset,
        start => start,
        done => done,
        cos => cos,
        sin => sin,
        angle =>angle,
        
        check => check);
        
process
begin
clk <= '0';
wait for clk_period/2;
clk <= '1';
wait for clk_period/2;
end process;
        
start <= '0','1' after 80ns;
reset <= '1','0' after 50ns;

process
begin

wait for  150 ns;
   
    angle <= "00100001010001111"; --(pi/3)
    wait for clk_period/2;
    angle <= "11011110101110001"; --(-pi/3)
    wait for 30*clk_period;
wait;
end process;

end Behavioral;
