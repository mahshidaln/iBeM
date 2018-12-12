library work;
use work.my_package.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity tb is
    port (
        clk : in std_logic;
		--wink : out std_logic;
		hw_call : in std_logic;
		pre_mat1 : in std_logic_vector(25 downto 0);
		pre_mat2 : in std_logic_vector(25 downto 0);
		pre_mat3 : in std_logic_vector(25 downto 0);
		pre_mat4 : in std_logic_vector(25 downto 0);
		pre_mat5 : in std_logic_vector(25 downto 0);
		pre_mat6 : in std_logic_vector(25 downto 0);
		pre_mat7 : in std_logic_vector(25 downto 0);
		pre_mat8 : in std_logic_vector(25 downto 0);
		sw_call : out std_logic;
		EEM_columns : out integer range 0 to 3000 := 0;
		EEM_rows : out integer range 0 to 7 := 0;
		EEM_data: out std_logic_vector(1 to 36) := (others => '0')
    );
end entity;

architecture arch_t of tb is
	component main is
		generic(
			m : in integer range 0 to 2 :=2;			--metabolites
	        q : in integer range 0 to 6 := 5;				--reactions not splitted
	        qsplit : in integer range 0 to 7 := 6;			--reactions splitted = q + revs
	        R_rows : in integer range 0 to 7 := 6;			--qsplit
	        R_columns : in integer range 0 to 5 := 4;		--qsplit-m
	        R1_rows : in integer range 0 to 5 := 4;			--qsplit-m
			R2_rows : in integer range 0 to 3 := 2;			--m
			max_column : in integer range 0 to 3000 := 16);	--max of columns in R after adding combination
		port(
			clock, reset, HW_call : in std_logic;
			R1_data : in std_logic_vector(1 to R1_rows*R_columns);
			R2_data_postfix : in std_vec_array(1 to R2_rows*R_columns);
			SW_call : out std_logic := '0';
			EM_columns : out integer range 0 to 3000 := 0;
			EM_rows : out integer range 0 to R_rows := 0;
			EM_data: out std_logic_vector(1 to 36) := (others => '0')
		);
	end component main;
    signal rst : std_logic := '0';
	signal RR1_data : std_logic_vector(1 to 16);
	signal RR2_data : std_vec_array(1 to 8); 
	
begin 
	--m = 2
	--q = 5
	--qsplit = 6
	--R_rows = 6
	--R_columns = 4
	--R1_rows = 4
	--R2_rows = 2
	rst <= '0';
	RR1_data <= ('1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1');
	-- RR2_data <= (
	-- 	"000000000001000000000000000",
	-- 	"000000000001000000000000000",
	-- 	"11111111111100000000000000",
	-- 	"00000000000000000000000000",
	-- 	"000000000001000000000000000",
	-- 	"11111111111100000000000000",
	-- 	"11111111111100000000000000",
	-- 	"00000000001000000000000000"
	-- );

	RR2_data <= (
		pre_mat1,
		pre_mat2,
		pre_mat3,
		pre_mat4,
		pre_mat5,
		pre_mat6,
		pre_mat7,
		pre_mat8
	);
	
	main_comp : main generic map (2, 5, 6, 6, 4, 4, 2, 16)
				port map (clk, rst, hw_call, RR1_data, RR2_data, sw_call, EEM_columns, EEM_rows, EEM_data);
end architecture arch_t;
