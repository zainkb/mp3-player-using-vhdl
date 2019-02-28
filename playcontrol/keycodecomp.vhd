----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:09:13 11/11/2018 
-- Design Name: 
-- Module Name:    keycodecomp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keycodecomp is
    Port ( rd : out  STD_LOGIC;
           rd_ack : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           empty : in  STD_LOGIC;
           listnext : out  STD_LOGIC;
           listprev : out  STD_LOGIC);
end keycodecomp;

architecture Behavioral of keycodecomp is

begin

process (data, rd_ack, empty)
begin

rd <= not empty;

if (data = x"72") then
       listnext <= rd_ack;
		 listprev <= '0';
		 
	elsif (data = x"75") then
		 listprev <= rd_ack;
		 listnext <= '0';
	else
	 listnext <= '0';
	 listprev <= '0';
end if;



end process;

end Behavioral;

