library work;
use work.my_package.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity main_t is
end entity;

architecture arch_t of main_t is
	component main is
	generic(m : in integer :=2;				--metabolites
	        q : in integer := 5;			--reactions not splitted
	        qsplit : in integer := 6;		--reactions splitted
	        R_rows : in integer := 6;		--qsplit 
	        R_columns : in integer := 4;	--qsplit-m
	        R1_rows : in integer := 4;		--qsplit-m
	        R2_rows : in integer := 2);		--m
	port(clock, reset: in std_logic;
       R1_data: in std_logic_vector(1 to R1_rows*R_columns);
       R2_data: in fixedp_array(1 to R2_rows*R_columns); 
	   SW_call : out std_logic := '0';
	   EM_columns : out integer := 0 ;
	   EM_rows : out integer := 0;
       EM_data: out std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0')
      );
	end component main;
	signal EEM_columns : integer;
	signal EEM_rows : integer;
	signal SSW_call : std_logic;
	signal EEM_data : std_logic_vector(1 to 120);
	signal rst, clk : std_logic := '0';
	signal RR1_data : std_logic_vector(1 to 16);
	signal RR2_data : fixedp_array(1 to 8); 
	
begin 
	--m = 2
	--q = 5
	--qsplit = 6
	--R_rows = 6
	--R_columns = 4
	--R1_rows = 4
	--R2_rows = 2
	RR1_data <= ('1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1');
	RR2_data <= (to_sfixed(0.5, 10, -10), to_sfixed(-0.5, 10, -10), to_sfixed(-0.5, 10, -10), to_sfixed(1, 10, -10), to_sfixed(0.5, 10, -10), to_sfixed(0.5, 10, -10), to_sfixed(-0.5, 10, -10), to_sfixed(0, 10, -10));
	clk <= not clk after 10 ms;
	main_comp : main generic map (2, 5, 6, 6, 4, 4, 2)
					 port map (clk, rst, RR1_data, RR2_data, SSW_call, EEM_columns, EEM_rows, EEM_data);
end architecture arch_t;
