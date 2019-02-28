----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:39:08 11/17/2018 
-- Design Name: 
-- Module Name:    arbitermultiplexer - Behavioral 
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

entity arbitermultiplexer is
    generic (
	 constant rest_state : STD_LOGIC := '1';
	 constant clk_polarity : STD_LOGIC := '1';
	 constant enable_state : STD_LOGIC := '1';
	 M: integer := 4;
	 N: integer := 3
	 );
	 
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (M*N - 1 downto 0);
           output : out  STD_LOGIC_VECTOR (M - 1 downto 0);
           req : in  STD_LOGIC_VECTOR (N-1 downto 0);
           gnt : out  STD_LOGIC_VECTOR (N-1 downto 0)
			  );
end arbitermultiplexer;

architecture Behavioral of arbitermultiplexer is
signal tmp1: std_logic := '0';--Arb logic calc
signal tmp_m: STD_LOGIC_VECTOR (N - 1 downto 0);--Enable signal calc 
signal tmp_m1: STD_LOGIC := '0';--Enable signal calc no need
signal enable: std_logic:= '0'; --D flipflop enable
signal tmp_gnt : STD_LOGIC_VECTOR (N- 1 downto 0); --Arb logic output
signal tmp_gnt_a : STD_LOGIC_VECTOR (N- 1 downto 0); --D flipflop output


begin
-----------------------------------------------------------
process (tmp_gnt_a , input) --Multiplexer
begin
 for i in 0 to N-1 loop
	 if (tmp_gnt_a(i) = '1') then
		output (M-1 downto 0) <= input(M*(i+1)-1 downto M*i);
		exit;
	 else 
  null;
 end if;
 end loop;
end process;
-----------------------------------------------------------
--process (req)--Arbitration logic
--begin
----tmp1 <= '0';
--for i in 0 to N-1 loop
--	tmp1 <= '0';
--	if (i = 0) then
--		tmp_gnt(0) <= req(0);
--		else
--			for j in 0 to i-1 loop
--				tmp1 <= tmp1 or req(j);
--			end loop;
--		tmp_gnt(i)<= (not(tmp1)) and req(i);
--	end if;
--end loop;
--end process;
-----------------------------------------------------------
process (clk, reset, enable) --D flipflop
begin
if reset = rest_state then
 gnt <= (N-1 downto 0 => '0');
 tmp_gnt_a <= (N-1 downto 0 => '0');
 --tmp_gnt_a <= "010";
elsif clk'event and clk=clk_polarity then
	if enable = enable_state then
	-- insert logic before the flip - flop
	-- tmp1 <= '0';

		for i in 0 to N-1 loop
			tmp1 <= '0';
			if (i = 0) then
				gnt(0) <= req(0);
				tmp_gnt_a(0) <= req(0);
			elsif (i = 1) then
			   gnt(1) <= (not req(0)) and req(i);
				tmp_gnt_a(1) <= (not req(0)) and req(i);
			else
					for j in 0 to i-1 loop
						tmp1 <= tmp1 or req(j);
					end loop;
				   gnt(i)<= (not(tmp1)) and req(i);
					tmp_gnt_a(i)<= (not(tmp1)) and req(i);
			end if;
		end loop;
		
		
--		for i in 0 to N-1 loop
--			tmp1 <= '0';
--			if (i = 0) then
--				tmp_gnt(0) <= req(0);
--				else
--					for j in 0 to i-1 loop
--						tmp1 <= tmp1 or req(j);
--					end loop;
--				tmp_gnt(i)<= (not(tmp1)) and req(i);
--			end if;
--		end loop;
--	
--	gnt(N-1 downto 0) <= tmp_gnt(N-1 downto 0);
--	tmp_gnt_a(N-1 downto 0) <= tmp_gnt(N-1 downto 0);
	end if;
end if;
end process;
------------------------------------------------------------
process  (req, tmp_gnt_a)-- Enable signal for D FlipFlop
begin
for i in 0 to N-1 loop
  tmp_m1 <=  tmp_m1 or (req(i) and tmp_gnt_a (i));
end loop;
enable <= not tmp_m1;

--for i in 0 to N-1 loop
--  tmp_m(i) <= req(i) and tmp_gnt_a (i);
--end loop;
--
--for i in 0 to N-1 loop
--  tmp_m1 <= tmp_m(i) nor tmp_m1;
--  
--  if i = N-1 then
--  enable <= not tmp_m1;
--  end if;
--  --enable <= '1';
--end loop;
--enable <= not tmp_m1;
end process;
-------------------------ENDE------------------------------

end Behavioral;




