----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2020 03:51:09 PM
-- Design Name: 
-- Module Name: coardic - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordic is
generic(
    length :integer := 17;
    iteration : integer :=16
    );
    
Port (
 clk,reset,start : in std_logic;
 cos , sin : out signed( length-1 downto 0);
 done : out std_logic;
 angle : in signed(length-1 downto 0);
 
 check : out std_logic_vector(2 downto 0)
 );
end cordic;

architecture Behavioral of cordic is

type aray is array (natural range <>) of signed (length-1 downto 0);
type intarray is array (natural range <>) of integer;

constant lookup : aray (0 to iteration-1) := (
    "00011000111101011", --45
    "00001110110101100",
    "00000111110101100",
    "00000011111100110",
    "00000001111111110",
    "00000000111111111",
    "00000000100000000",
    "00000000010000000",
    "00000000001000000",
    "00000000000100000",
    "00000000000010000",
    "00000000000001000",
    "00000000000000100",
    "00000000000000010",
    "00000000000000001",
    "00000000000000000"
    );
    
type state is (idle,cs_sign,initial,compute,exfinish,finish);
signal manner_reg,manner_next : state;
 
begin

process(clk,reset)
    
    variable xos,xoc,yos,yoc,zos,zoc : aray( 0 to iteration-1);
    variable xos_col,xoc_col,yos_col,yoc_col,xooc,xoos : signed (length-1 downto 0);
    variable countc,counts : integer := 0 ;
    variable flags,flagc,sign_ch,ssign,csign : std_logic := '0' ;
    variable shiftt : unsigned(length-1 downto 0);
    variable copy : signed(length-1 downto 0);
    variable quadrant : signed( 1 downto 0);
    variable CF_cos     : signed (length-1 downto 0);        
    variable CF_sin     : signed (length-1 downto 0); 
       
    begin
    
    if(reset ='1') then
        countc := 0;
        counts := 0;
        flags := '0' ;
        flagc := '0' ;
        shiftt := (others => '0');
        cos <= ( others => '0');
        sin <= (others => '0');
        done <= '0';
        manner_reg <= idle;
        
     elsif ( clk'event and clk='1') then
        
        manner_reg <= manner_next;
        
        case manner_reg is 
        
            when idle =>
                 countc := 0;
                 counts := 0;
                 flags := '0' ;
                 flagc := '0' ;
                 shiftt := (others => '0');
                 
                 xoc := ( others => (others => '0'));
                 xos := ( others => (others => '0'));
                 yoc := ( others => (others => '0'));
                 yos := ( others => (others => '0'));
                 
                 
                 cos <= ( others => '0');
                 sin <= (others => '0');
                 done <= '0';
                 
                 check <= "000";                
                 if(start='1')then
                    manner_next <= cs_sign ;
                 end if;
                 
            when cs_sign =>
                if( angle(length-1) = '1' ) then
                    sign_ch := '1'; --3&4                
                else
                    sign_ch := '0'; --1&2
                end if;
                
                copy := angle;
                
                if( angle(length-1) = '1' ) then
                    copy := (copy xor "11111111111111111") +1;
                end if;
                
                --initial
                xoc(0) := "00010110011001101";
                yoc(0) := "00000000000000000";
                
                xos(0) := "00010110011001101";
                yos(0) := "00000000000000000";
                
                if ( copy >"00000000000000000"  and copy <"00110010001111011") then
                    zoc(0) := copy;
                    zos(0) := "00110010001111011" - copy ; 
                    ssign := '0';
                    csign := '0';
                elsif ( copy > "00110010001111011" and copy <"01100100011110110") then
                    --zoc(0) := "01100100011110101" - copy;
                    zoc(0) := "01100100011110110" - copy;
                    zos(0) := copy - "00110010001111011" ;
                    ssign := '0';
                    csign := '1';
                
                end if;
                
                 if(zoc(0) >"00011000111101100") then
                    CF_sin := "00000011001100110" ;
                    CF_cos := "00000000000000000" ;
                 elsif(zoc(0) <"00011000111101100") then
                    CF_cos := "00000011001100110" ;
                    CF_sin := "00000000000000000" ;
                 end if ;
               
                check <= "001";
                manner_next <= initial;
                 
            when initial =>
                                
                --
                  if(copy ="00000000000000000") then 
                    xoc(0) := "00100000000000000";
                    xos(0) := "00000000000000000";
                    flags := '1';
                    flagc := '1';
                    ssign := '0';
                    csign := '0';
                    
                  elsif( copy ="00110010001111011" ) then
                    xos(0) := "00100000000000000";                    
                    xoc(0) := "00000000000000000";         
                    flags := '1';
                    flagc := '1';
                    csign := '0';
                    ssign := '0';
                    
                  elsif ( copy ="01100100011110110" ) then
                    xoc(0) := "00100000000000000";                    
                    xos(0) := "00000000000000000";                   
                    flags := '1';
                    flagc := '1';
                    csign := '1';
                    ssign := '0';
                    
                   end if;
                   check <= "010";
                   manner_next <= compute;
                   
            when compute => 
               
                if (flagc ='0' and countc < (iteration-1)) then
                    
                    xoc_col := yoc(countc);
                    yoc_col := xoc(countc);
                     
                    if(xoc_col >= 0) then 
                        shiftt := "00000000000000000" + unsigned(xoc_col((length-2) downto countc));
                        xoc_col := signed(shiftt);
                        
                    else
                        xoc_col := (xoc_col xor "11111111111111111") +1 ;
                        shiftt := "00000000000000000" + unsigned(xoc_col((length-2) downto countc));
                        xoc_col := signed(shiftt);
                        
                    end if;
                    
                    if(yoc_col >= 0) then 
                        shiftt := "00000000000000000" + unsigned(yoc_col((length-2) downto countc));
                        yoc_col := signed(shiftt);
                        
                    else
                        yoc_col := (xoc_col xor "11111111111111111") +1 ;
                        shiftt := "00000000000000000" + unsigned(yoc_col((length-2) downto countc));
                        yoc_col := signed(shiftt);
                        
                    end if;
                    
                    if( zoc(countc) <0 ) then
                        xoc(countc+1) := xoc(countc) + xoc_col;
                        yoc(countc+1) := yoc(countc) - yoc_col;
                        zoc(countc+1) := zoc(countc) + lookup(countc);
                        
                        countc := countc+1;
                    elsif( zoc(countc) > 0) then
                        xoc(countc+1) := xoc(countc) - xoc_col;
                        yoc(countc+1) := yoc(countc) + yoc_col;
                        zoc(countc+1) := zoc(countc) - lookup(countc);
                        
                        countc := countc+1;
                     
                    elsif(  zoc(countc) = 0) then
                        
                        flagc := '1';
                    end if;
                    
                end if;
                
                    if (flags ='0' and counts < (iteration-1)) then
                    
                    xos_col := yos(counts);
                    yos_col := xos(counts);
                     
                    if(xos_col >= 0) then 
                        shiftt := "00000000000000000" + unsigned(xos_col((length-2) downto counts));
                        xos_col := signed(shiftt);
                        
                    else
                        xos_col := (xos_col xor "11111111111111111") +1 ;
                        shiftt := "00000000000000000" + unsigned(xos_col((length-2) downto counts));
                        xos_col := signed(shiftt);
                        
                    end if;
                    
                    if(yos_col >= 0) then 
                        shiftt := "00000000000000000" + unsigned(yos_col((length-2) downto counts));
                        yos_col := signed(shiftt);
                        
                    else
                        yos_col := (xos_col xor "11111111111111111") +1 ;
                        shiftt := "00000000000000000" + unsigned(yoc_col((length-2) downto counts));
                        yos_col := signed(shiftt);
                        
                    end if;
                    
                    if( zos(counts) <0 ) then
                        xos(counts +1) := xos(counts) + xos_col;
                        yos(counts+1) := yos(counts) - yos_col;
                        zos(counts+1) := zos(counts) + lookup(counts);
                        
                        counts := counts+1;
                    elsif( zos(counts) > 0) then
                        xos(counts+1) := xos(counts) - xos_col;
                        yos(counts+1) := yos(counts) + yos_col;
                        zos(counts+1) := zos(counts) - lookup(counts);
                        
                        counts := counts+1;
                     
                    elsif (  zos(counts) = 0) then
                        
                        flags := '1';
                    end if;
                    
                end if;
                
                check <= "011";
                if ( (flags='1' and flagc='1') or countc = iteration-1 or counts = iteration-1) then
                    manner_next <= exfinish;
                else
                    manner_next <= compute;
                end if;
                
            when exfinish =>
                
                --xooc := xoc(countc) - CF_cos;
                --xoos := xos(counts) - CF_sin;
                
                xooc := xoc(countc);
                xoos := xos(counts);
                
                flagc  := '0' ;              
      		    flags  := '0' ;
      		                   
                if ( xoc(countc) = 1) then 
                    xooc := (xooc xor "01111111111111111")+1;
                    xooc(length-1) := '0';
                end if;
                
                if ( xos(counts) = 1) then 
                    xoos := (xoos xor "01111111111111111")+1;
                    xoos(length-1) := '0';
                end if;
                
                if ( csign='1') then 
                    xooc := (xooc xor "11111111111111111")+1;
                end if;
                
                if ( (ssign xor sign_ch) = '1') then
                    xoos := (xoos xor "11111111111111111")+1;
                end if;
                
                xooc(length-1) := csign;
                xoos(length-1) := ssign xor sign_ch;
                
                cos <= xooc;
                sin <= xoos;
                check <= "100";
                manner_next <= finish;
            
            when finish =>
                done <= '1';
                manner_next <= idle;
                check <= "101";
                
            when others =>  
                done <= '0';
                
            end case;    
         
    end if;
      
 end process;                
 
end Behavioral;
