----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:41:09 11/11/2018 
-- Design Name: 
-- Module Name:    listctrl - Behavioral 
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

entity listctrl is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           listnext : in  STD_LOGIC;
           listprev : in  STD_LOGIC;
           req : out  STD_LOGIC;
           gnt : in  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
           busiv : out  STD_LOGIC;
           ctrl : out  STD_LOGIC;
           busy : in  STD_LOGIC;
           info_start : out  STD_LOGIC;
           info_ready : in  STD_LOGIC);
end listctrl;

architecture Behavioral of listctrl is

type stateMealy_type is (idle, wrdy, winfo); -- 2 states are required for Mealy
signal stateMealy_reg, stateMealy_next : stateMealy_type;
signal temp_hold : STD_LOGIC_VECTOR (7 downto 0);
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
begin   
   
	process(clk, reset)
    begin
        if (reset = '1') then -- go to state zero if reset
            stateMealy_reg <= idle;
        elsif (clk'event and clk = '1') then -- otherwise update the states
            stateMealy_reg <= stateMealy_next;
        else
            null;
        end if; 
    end process;

    -- Mealy Design
    process(stateMealy_reg, listnext, listprev, gnt, info_ready, busy)
    begin 
        -- store current state as next
        stateMealy_next <= stateMealy_reg; --required: when no case statement is satisfied
        
--		  busiv <= '0';
--      req <= '0';
--		  ctrl <= '-';
--		  info_start <= '0';
		  
        case stateMealy_reg is 
            when idle =>  -- set 'tick = 1' if state = zero and level = '1'
                if (listnext = '0' and listprev = '0') then -- if level is 1, then go to state one,
                    stateMealy_next <= idle; -- otherwise remain in same state.
                    
					 elsif (listnext = '1') then
							stateMealy_next <= wrdy; -- otherwise remain in same state.
                     req <= '1';
							temp_hold <= x"00";
					elsif (listprev = '1') then
							stateMealy_next <= wrdy; -- otherwise remain in same state.
                     req <= '1';
							temp_hold <= x"01";
						end if; 
            
				when wrdy =>  
                if (gnt = '0' and busy = '1') then  -- if level is 0, then go to zero state,
                    stateMealy_next <= wrdy; -- otherwise remain in one state.
                    req <= '1';
						  
						  
					 elsif (gnt = '1' and busy = '0') then
							stateMealy_next <= winfo; -- otherwise remain in same state.
							req <= '1';
							busiv <= '1';
							ctrl <= '1';
							info_start <= '1';
							busi <= temp_hold;
					 end if;
					 
				when winfo =>  
                if (info_ready = '0') then  -- if level is 0, then go to zero state,
                    stateMealy_next <= winfo; -- otherwise remain in one state.
						  req <= '1';
                elsif (info_ready = '1') then  -- if level is 0, then go to zero state,
                    stateMealy_next <= idle; -- otherwise remain in one state.
						  
					 end if;
        end case; 
    end process;
      

end Behavioral;

