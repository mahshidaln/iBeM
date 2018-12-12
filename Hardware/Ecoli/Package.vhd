library ieee;
use ieee.fixed_pkg.all;
use ieee.std_logic_1164.all;

Package my_package is 
	type int_array is array (natural range <>) of integer;
	type fixedp_array is array (natural range <>) of sfixed(3 downto -4);
	type int_matrix is array(natural range <>, natural range <>) of integer;
	type fixedp_matrix is array(natural range <>, natural range <>) of sfixed(3 downto -4);
	type bit_matrix is array(natural range <>, natural range <>) of std_logic;
	type std_vec_array is array(natural range<>) of std_logic_vector(7 downto 0);
end;