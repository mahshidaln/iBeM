library ieee;
use ieee.fixed_pkg.all;
use ieee.std_logic_1164.all;
Package my_package is 
	--type float is range -1000.00 to +1000.00;
	--type fixed is ufixed(10 downto -10); 
	type int_array is array (natural range <>) of integer;
	type fixedp_array is array (natural range <>) of sfixed(10 downto -10);
	type int_matrix is array(natural range <>, natural range <>) of integer;
	type fixedp_matrix is array(natural range <>, natural range <>) of sfixed(10 downto -10);
	type bit_matrix is array(natural range <>, natural range <>) of std_logic;
end;