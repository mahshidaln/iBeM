library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb is
end entity;

architecture Behavioral of tb is
    
	component main is
		port (
		  clock : in STD_LOGIC;
		  reset : in STD_LOGIC;
		  R1_data : in STD_LOGIC_VECTOR ( 1 to 16 );
		  \R2_data_postfix[1]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[2]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[3]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[4]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[5]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[6]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[7]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  \R2_data_postfix[8]\ : in STD_LOGIC_VECTOR ( 20 downto 0 );
		  SW_call : out STD_LOGIC;
		  EM_columns : out STD_LOGIC_VECTOR ( 3 downto 0 );
		  EM_rows : out STD_LOGIC_VECTOR ( 3 downto 0 );
		  EM_data : out STD_LOGIC_VECTOR ( 1 to 36 )
		);
	end component main;
	signal EEM_columns : STD_LOGIC_VECTOR ( 3 downto 0 );
	signal EEM_rows : STD_LOGIC_VECTOR ( 3 downto 0 );
	signal SSW_call : std_logic := '0';
	signal EEM_data : std_logic_vector(1 to 36)  := (others => '0');
	signal rst, clk : std_logic := '0';

	signal RR1_data : std_logic_vector(1 to 16);
	type std_vec_array is array(natural range<>) of std_logic_vector(20 downto 0);
	signal RR2_data : std_vec_array(1 to 8); 

	--signal m : in integer range 0 to 2;			--metabolites
	--signal q : in integer range 0 to 6;			--reactions not splitted
	--signal qsplit : in integer range 0 to 7;		--reactions splitted
	--signal R_rows : in integer range 0 to 7;		--qsplit
	--signal R_columns : in integer range 0 to 5;	--qsplit-m
	--signal R1_rows : in integer range 0 to 5;		--qsplit-m
	--signal R2_rows : in integer range 0 to 3;
	
begin 
	--m <= 2;
	--q <= 5;
	--qsplit <= 6;
	--R_rows <= 6;
	--R_columns <= 4;
	--R1_rows <= 4;
	--R2_rows <= 2;
	
	RR1_data <= ('1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1');
	RR2_data <= ("000000000001000000000", "111111111111000000000", "111111111111000000000", "000000000010000000000", "000000000001000000000", "000000000001000000000", "111111111111000000000", "000000000000000000000");

	clk <= not clk after 100 us;

	--main_comp : main generic map (m => 2, q=> 5 , qsplit => 6 , R_rows => 6, R_columns => 4,R1_rows => 4, R2_rows => 2)
	main_comp : main port map (clk, rst, RR1_data, RR2_data(1), RR2_data(2), RR2_data(3), RR2_data(4),
	RR2_data(5), RR2_data(6), RR2_data(7),RR2_data(8), SSW_call, EEM_columns, EEM_rows, EEM_data);

end Behavioral;
