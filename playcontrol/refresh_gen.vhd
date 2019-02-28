----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:01:02 11/17/2018 
-- Design Name: 
-- Module Name:    refresh_gen - Behavioral 
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
use ieee . std_logic_arith .all;
use ieee . std_logic_unsigned .all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity refresh_gen is
generic(
    constant reset_state : std_logic := '1';
	 constant clk_polarity : std_logic := '1';
	 constant enable_state : std_logic := '1'
   );

port (
  clk: in STD_LOGIC;
  reset : in STD_LOGIC;
  BUSO: in STD_LOGIC_VECTOR (31 downto 0);
  BUSOV: in STD_LOGIC;
  lcdc_busy: in STD_LOGIC;
  chrm_wdata: out STD_LOGIC_VECTOR (7 downto 0);
  chrm_addr: out STD_LOGIC_VECTOR (7 downto 0);
  chrm_wr: out STD_LOGIC;
  lcdc_cmd: out STD_LOGIC_VECTOR (1 downto 0);
  -----------------------DUMMY For NOW------------------------------
  t_info_start: in STD_LOGIC;--Input to Data Counter Block
  t_info_ready: out STD_LOGIC;-- Input to Refresh Ctrl Block
  t_file_size: out STD_LOGIC_VECTOR (31 downto 0); --File size for Reg Block
  t_counter: OUT  std_logic_vector(3 downto 0)
  ------------------------------------------------------------------
);

end refresh_gen;

architecture Behavioral of refresh_gen is

signal info_start: STD_LOGIC; --Input to Data Counter Block
signal info_ready:  STD_LOGIC; -- Input to Refresh Ctrl Block
signal file_size:  STD_LOGIC_VECTOR (31 downto 0); -- Output of Reg Block

signal chrm_ready : std_logic ; --Signal for lcdc_cmd generator
signal t_lcdc_cmd: STD_LOGIC_VECTOR (1 downto 0); -- Refresh command output from Refresh Ctrl block
signal counter : std_logic_vector (3 downto 0); --DWORDS data counter
signal filenamereg: std_logic_vector (95 downto 0); --3-DWORDS(12 Bytes) data storage
signal count3 : std_logic ; -- 7 to 8 data count check for data counter
signal refcounter : std_logic_vector (3 downto 0); --CHRM data write counter
signal t_refcounter : std_logic_vector (3 downto 0);--CHRM data write counter check
signal t_chrm_wr : std_logic ; --CHRM data write enable



begin
---------------------DATA COUNTER----------------------------
process (clk, reset, t_info_start)
	begin
	 if reset = reset_state then
		 counter <= "1000"; -- asynchronous global reset
		 t_counter <= "1000";
	 elsif clk'event and clk = clk_polarity then
		 if t_info_start = '1' then -- synchronous reset
			counter <= "0000";
			t_counter <= "0000";
		 elsif busov = '1' and counter /="1000" then
			counter <= counter+1;
			t_counter <= counter+1;
		 end if;
	 end if;
end process ;

---------------------12-BYTE REGISTER-------------------------
process (clk , reset, BUSO, counter, BUSOV)
begin
	 if reset = reset_state then
			filenamereg <= (others => '0'); 
	 elsif clk'event and clk = clk_polarity then
		 if BUSOV = enable_state and counter = "0000" then 
			filenamereg (31 downto 0) <= BUSO (31 downto 0);
		 elsif BUSOV = enable_state and counter = "0001" then 
			filenamereg (63 downto 32) <= BUSO (31 downto 0);          ----CHECK FOR VALUE OF COUNTER
		 elsif BUSOV = enable_state and counter = "0010" then 
			filenamereg (95 downto 64) <= BUSO (31 downto 0);
		 else
			null;
		 end if;
	 end if;
end process ;

--------------------FILE_SIZE REGISTER------------------------
process (clk , reset, BUSO, counter, BUSOV)
begin
 if reset = reset_state then
		t_file_size <= (others => '0'); 
 elsif clk'event and clk = clk_polarity then
	 if BUSOV = enable_state and counter = "0111" then 
		t_file_size (31 downto 0) <= BUSO (31 downto 0);
	 else
		null;
	 end if;
 end if;
end process ;

--------INFO READY GEN/ COUNTER SWITCH DETECTION -------------
process (clk , reset, counter)
begin
 if reset = reset_state then
	 count3 <= '1';
	 info_ready <= '0';
	 t_info_ready <= '0';
 elsif clk'event and clk = clk_polarity then
	 count3 <= counter(3);
	if count3 = '0' and counter(3) = '1' then
	 info_ready <= '1';
	 t_info_ready <= '1';
	else
	 info_ready <= '0';
	 t_info_ready <= '0';
	end if;
 end if;
end process ;

--------------------REFRESH CTRL BLOCK -----------------------
process (clk , reset, info_ready)
begin

--if (info_ready = '1') then
		 if reset = reset_state then
			 refcounter <= "1011"; -- asynchronous global reset
			 t_refcounter <= "1011";
--			 t_chrm_wr <= '0';
--			 chrm_wr <= '0';
		 elsif clk'event and clk = clk_polarity then
				if info_ready = '1' then -- synchronous reset
					refcounter <= "0000";
					t_refcounter <= "0000";
				elsif refcounter /="1011" then                               ----Needs to be updated the condition
					refcounter <= refcounter + 1;
					t_refcounter <= "1010";

				end if;
		 end if;
		 
		 --------------------SEL BLOCK -------------------------------
	  if (refcounter /="1011") then
	  chrm_addr (7 downto 4) <= "0000";
	  chrm_addr (3 downto 0) <= refcounter;
		 case refcounter (3 downto 0) is
		 when "0000" =>
			chrm_wdata <= filenamereg (7 downto 0);
		 when "0001" =>
			chrm_wdata <= filenamereg (15 downto 8);
		 when "0010" =>
			chrm_wdata <= filenamereg (23 downto 16);
		 when "0011" =>
			chrm_wdata <= filenamereg (31 downto 24);
		 when "0100" =>
			chrm_wdata <= filenamereg (39 downto 32);
		 when "0101" =>
			chrm_wdata <= filenamereg (47 downto 40);
		 when "0110" =>
			chrm_wdata <= filenamereg (55 downto 48);
		 when "0111" =>
			chrm_wdata <= filenamereg (63 downto 56);
		 when "1000" =>
			chrm_wdata <= filenamereg (71 downto 64);
		 when "1001" =>
			chrm_wdata <= filenamereg (79 downto 72);
		 when others =>
			chrm_wdata <= filenamereg (87 downto 80);
		 end case ;
		  
		end if;
--end if;
end process ;

--------------------REFRESH COMMAND GENERATION BLOCK -------------------------------
 process (clk , reset )
  begin
	 if reset = reset_state then
		chrm_ready <= '0';
	 elsif clk'event and clk = clk_polarity then
		 if t_lcdc_cmd = "10" then
			chrm_ready <= '0';
		 elsif refcounter = "1010" then
			chrm_ready <= '1';
		 end if;
	 end if;
 end process ;

 process (clk , reset )
	 begin
		 if reset = reset_state then
			lcdc_cmd <= "00"; --no command
			t_lcdc_cmd <= "00";
		 elsif clk ' event and clk = clk_polarity then
			 if t_lcdc_cmd = "10" then
				lcdc_cmd <= "00";
				t_lcdc_cmd <= "00";
			 elsif lcdc_busy = '0' and chrm_ready = '1' then
				lcdc_cmd <= "10"; -- refresh command
				t_lcdc_cmd <= "10";
			 end if;
	 end if;
 end process ;

end Behavioral;