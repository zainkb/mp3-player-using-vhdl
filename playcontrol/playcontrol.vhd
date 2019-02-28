library ieee;
use ieee.std_logic_1164.all;
--use work.system_constants_pkg.all;

entity playcontrol is
  port (
    clk         : in std_logic;               --clock signal
    reset       : in std_logic;               --asynchronous reset

    key_empty   : in  std_logic;
    key_rd      : out std_logic;
    key_rd_ack  : in  std_logic;
    key_data    : in  std_logic_vector(7 downto 0);

    ctrl    : out std_logic;
    busi    : out std_logic_vector(7 downto 0);
    busiv   : out std_logic;
    busy    : in  std_logic;
    busov   : in  std_logic;
    buso    : in  std_logic_vector(31 downto 0);

    chrm_wdata  : out std_logic_vector(7 downto 0);
    chrm_wr     : out std_logic;
    chrm_addr   : out std_logic_vector(7 downto 0);
    lcdc_cmd    : out std_logic_vector(1 downto 0);
    lcdc_busy   : in  std_logic;
    ccrm_wdata  : out std_logic_vector(35 downto 0);
    ccrm_addr   : out std_logic_vector(4 downto 0);
    ccrm_wr     : out std_logic;

    hw_full     : in  std_logic;
    hw_wr       : out std_logic;
    hw_din      : out std_logic_vector(31 downto 0);

    dbuf_almost_full : in  std_logic;
    dbuf_wr          : out std_logic;
    dbuf_din         : out std_logic_vector(31 downto 0);
    dbuf_rst         : out std_logic;

    sbuf_full   : in  std_logic;
    sbuf_empty  : in  std_logic;
    sbuf_rst    : out std_logic;

    dec_rst     : out std_logic;
    dec_status  : in  std_logic

    );
end playcontrol;

architecture playcontrol_arch of playcontrol is

component listctrl is
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
end component;

component arbitermultiplexer is
    generic (
	 constant rest_state : STD_LOGIC := '1';
	 constant clk_polarity : STD_LOGIC := '1';
	 constant enable_state : STD_LOGIC := '1';
	 M: integer := 10;
	 N: integer := 3
	 );
	 
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (M*N - 1 downto 0);
           output : out  STD_LOGIC_VECTOR (M - 1 downto 0);
           req : in  STD_LOGIC_VECTOR (N-1 downto 0);
           gnt : out  STD_LOGIC_VECTOR (N-1 downto 0)
			  );
end component;

component refresh_gen is
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
end component;

component keycodecomp is
    Port ( rd : out  STD_LOGIC;
           rd_ack : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           empty : in  STD_LOGIC;
           listnext : out  STD_LOGIC;
           listprev : out  STD_LOGIC);
end component;


signal listprev, listnext: STD_LOGIC;
signal t_ctrl, t_busiv: STD_LOGIC;
signal t_busi: STD_LOGIC_VECTOR(7 downto 0);
signal req, gnt: STD_LOGIC;
signal t_req, t_gnt: STD_LOGIC_VECTOR(2 downto 0);
signal info_start, info_ready: STD_LOGIC;
signal file_size: STD_LOGIC_VECTOR(31 downto 0);
signal counter: STD_LOGIC_VECTOR(3 downto 0);
signal t_input,t_output: STD_LOGIC_VECTOR(9 downto 0);


begin

KBC_interface:  keycodecomp 
    Port map( rd => key_rd,
           rd_ack => key_rd_ack,
           data => key_data,
           empty => key_empty,
           listnext => listnext,
           listprev => listprev);


list_ctrl:  listctrl port map ( clk => clk,
           reset => reset,
           listnext => listnext,
           listprev => listprev,
           req => req,
           gnt => gnt,
           busi => t_busi,
           busiv => t_busiv,
           ctrl => t_ctrl,
           busy => busy,
           info_start => info_start,
           info_ready => info_ready);
			  
			  t_input(8 downto 1) <= t_busi;
			  t_input(0) <= t_ctrl;
			  t_input(9) <= t_busiv;
			  t_req(2) <= req;
			  t_req(1 downto 0) <= "00";
			  t_gnt(2) <= gnt;
			  t_gnt(1 downto 0) <= "00";
			  ctrl <= t_output(0);
			  busi <= t_output(8 downto 1);
			  busiv <= t_output(9);

arbiter_multiplexer: arbitermultiplexer
    generic map(
				rest_state => '1',
				clk_polarity => '1',
				enable_state => '1',
				M => 10,
				N => 3
	 )
	 Port map ( clk =>  clk,
           reset => reset,
           input => t_input,
           output => t_output,
           req => t_req,
           gnt => t_gnt
			  );

refreshgen: refresh_gen
	generic map(
			  reset_state => '1',
			  clk_polarity => '1',
			  enable_state => '1'
			)
	port map (
			  clk => clk,
			  reset => reset,
			  BUSO => buso,
			  BUSOV => busov,
			  lcdc_busy => lcdc_busy,
			  chrm_wdata => chrm_wdata,
			  chrm_addr => chrm_addr, 
			  chrm_wr => chrm_wr,
			  lcdc_cmd => lcdc_cmd,
			  -----------------------DUMMY For NOW------------------------------
			  t_info_start => info_start, 
			  t_info_ready =>info_ready,
			  t_file_size => file_size,  
			  t_counter=> counter
			  ------------------------------------------------------------------
);

	 ccrm_wdata  <= x"000000000";
    ccrm_addr   <= "00000";
    ccrm_wr     <= '0';

    hw_wr       <= '0';
    hw_din      <= x"00000000";

    dbuf_wr     <=  '0';
    dbuf_din    <= x"00000000";
    dbuf_rst    <=  '0';

    sbuf_rst    <=  '0';

    dec_rst     <=  '0';




end architecture playcontrol_arch;
