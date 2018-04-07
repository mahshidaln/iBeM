library work;
use work.my_package.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;


entity main is
	generic(m : in integer range 0 to 2 :=2;			--metabolites
	        q : in integer range 0 to 6 := 5;			--reactions not splitted
	        qsplit : in integer range 0 to 7 := 6;		--reactions splitted
	        R_rows : in integer range 0 to 7 := 6;		--qsplit
	        R_columns : in integer range 0 to 5 := 4;	--qsplit-m
	        R1_rows : in integer range 0 to 5 := 4;		--qsplit-m
	        R2_rows : in integer range 0 to 3 := 2);	--m
	port(clock, reset : in std_logic;
	    --R1_data : in std_logic_vector(1 to R1_rows*R_columns);
	    R1_data : in std_logic_vector(1 to 16);
	    --R2_data_postifx : in fixedp_array(1 to R2_rows*R_columns);
		R2_data_postfix : in std_vec_array(1 to 8);
	    SW_call : out std_logic := '0';
	    EM_columns : out integer range 0 to 10 := 0;
	    EM_rows : out integer range 0 to 7 := 0;
	    --EM_data: out std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0')
	    EM_data: out std_logic_vector(1 to 36) := (others => '0')
    );
end entity;
architecture arch of main is
--signal numr : integer := qsplit - m;	--same numr as in code

--max of columns in R after adding combination
constant max_column : integer := R_rows*(R_columns*R_columns + R_columns);  

--fixed point equal for zero
signal zero : sfixed(10 downto -10);	
signal neg_zero : sfixed(10 downto -10);	
--fixed point signal of R2 data in R2_data_postfix
signal R2_data: fixedp_array(1 to 8);

--signal jpos : int_array (1 to 20) := (others => 0);		--row_vector of indices in R2 row with positive value
--signal jneg : int_array (1 to 20) := (others => 0); 	--row_vector of indices in R2 row with negative value

--signal R1_matrix : bit_matrix(1 to R_rows, max_column downto 1);	--signal to store R1 with max size
--signal R2_matrix : int_matrix(1 to R2_rows, max_column downto 1);	--signal to store R2 with max size

--all states
type state_type is (S0, S0a, S0b, S1, S1a, S1b, S2, S3, S3a, S3aa, S3b, S4, S5, S5a, S5b, S6, S6a, S6b, S7, S7a, S8, S_f);	
--initial state
signal state : state_type := S0;
signal state_num : integer range 0 to 23 := 0;

attribute keep : string;
attribute keep of state_num : signal is "true";

--customizing fsm encoding
attribute fsm_encoding : string;
attribute fsm_encoding of state : signal is "sequential";

begin
    zero <=  to_sfixed(0.0, zero);
	
	--initialize R2_data with fixed_point values read from R2_data_postfix
	for_label:
	for i in 1 to 8 generate
		R2_data(i) <= to_sfixed(R2_data_postfix(i), 10 , -10);
	end generate for_label;

	process(clock, zero, state_num)

	--counters for different loops
	variable l1_counter : integer range 1 to 40 := 1;
	variable l2_counter : integer range 1 to 40 := 1;
	variable l3_counter : integer range 1 to 40 := 1;
	variable l4_counter : integer range 1 to 40 := 1;
	variable l5_counter : integer range 1 to 40 := 1;
	variable l6_counter : integer range 1 to 40 := 1;
	variable l7_counter : integer range 1 to 40 := 1;
	variable l8_counter : integer range 1 to 40 := 1;

    --counter for additional loops that implements matrix iteration
	variable la_counter : integer range 1 to 40 := 1;
	variable lb_counter : integer range 0 to 100 := 1;
	variable lc_counter : integer range 1 to 40 := 1;
	variable ld_counter : integer range 1 to 40 := 1;
	variable lf_counter : integer range 1 to 40 := 1;
	variable lg_counter : integer range 1 to 40 := 1;
	variable lh_counter : integer range 1 to 40 := 1;
	variable li_counter : integer range 1 to 40 := 1;
	variable lj_counter : integer range 1 to 40 := 1;
	variable lk_counter : integer range 1 to 40 := 1;
	variable ll_counter : integer range 1 to 40 := 1;
	variable lm_counter : integer range 1 to 40 := 1;

    --variables the same as pseudo code
	variable new_numr : integer range 0 to 10 := qsplit - m;
	variable p : integer range 0 to 10 := q-m;			--main loop counter
	variable k : integer range 0 to 10 := 0;			--jneg loop counter
	variable l : integer range 0 to 10 := 0;			--jpos loop counter		
	variable r : integer range 0 to 10 := 0;			--test loop counter
	variable adj : integer range 0 to 2 := 0;			--test result	
	variable nullbits : integer range 0 to 10 := 0;		--number of zeros in newr
	variable newr : std_logic_vector(1 to R_rows) := (others => '0');	--new column to be added
	variable testr : std_logic_vector(1 to R_rows):= (others => '0');	--test column

	--variables to store R1 and R2 with max size
	variable R1_matrix : bit_matrix(1 to R_rows, 20 downto 1) := (others =>(others => '0'));
	variable R2_matrix : fixedp_matrix(1 to R2_rows, 20 downto 1) := (others =>(others => zero));

	--jneg and jpos row_vectors and their size
	variable jpos : int_array (1 to max_column) := (others => 0);	--row_vector of indices in R2 row with positive value
	variable jneg : int_array (1 to max_column) := (others => 0); 	--row_vector of indices in R2 row with negative value
	
	variable jneg_size : integer range 0 to 10 := 0;				--size of jneg
	variable jpos_size : integer range 0 to 10 := 0;				--size of jpos

	--S1 variables
	variable wanted_row : integer range 0 to 10 := 0;						--the row number of R2 which is being changed
	variable wanted_R2 : fixedp_array(1 to 20) := (others => zero);	--the row_vector of R2 which is being changed

	--last valid state of the result matrix
	variable valid_column : integer range 0 to 10 := R_columns;		--total number of valid columns in R2 and R1
	variable R1_valid_row : integer range 0 to 10 := R1_rows;		--total number of valid rows in R1
	--variable R2_valid_row : integer range 0 to 10 := R2_rows;		--total number of valid rows in R2

	variable newR2element : sfixed(21 downto -21);	--result of subtraction and multiply in R2 new values, not necessary

	begin
	  	if rising_edge(clock) then
	    	if (reset = '1') then
	    		state <= S0;
	    	else
	    		case state is
					when S0 =>
						state_num <= 0;
	    				-- initializing some variables
		    			p := q-m;
		    			k := 0;
		    			l := 0;
		    			r := 0;
		    			l1_counter := 1;
						l2_counter := 1;
						l3_counter := 1;
						l4_counter := 1;
						l5_counter := 1;
						l6_counter := 1;
						l7_counter := 1;
						l8_counter := 1;
		    			la_counter := 1;
						lb_counter := 1;
						lc_counter := 1;
						ld_counter := 1;
						lf_counter := 1;
						li_counter := 1;
						lj_counter := 1;
						lk_counter := 1;
						ll_counter := 1;
						lm_counter := 1;
						wanted_row := 0;
						valid_column := R_columns;
						R1_valid_row := R1_rows;
						new_numr := qsplit - m;
						jneg_size := 0;
						jpos_size := 0;
						state <= S0a;

					when S0a =>
						state_num <= 1;
		    			-- turn the row vector of R1 into a 2D matrix
		    			if(l1_counter < R1_rows or l1_counter = R1_rows) then
							R1_matrix(l1_counter, la_counter) := R1_data(lb_counter);
		    				la_counter := la_counter + 1;
		    				lb_counter := lb_counter + 1;
		    				if(la_counter > R_columns) then
		    					la_counter := 1;
								l1_counter := l1_counter + 1;
								state <= S0a;
							else
								state <= S0a;
							end if;
						else
							l2_counter := 1;
							lc_counter := 1;
							ld_counter := 1;
							state <= S0b;
						end if;

					when S0b =>
						state_num <= 2;
		    			-- turn the row vector of R2 into a 2D matrix
		    			if(l2_counter < R2_rows or l2_counter = R2_rows) then
							R2_matrix(l2_counter, lc_counter) := R2_data(ld_counter);
		    				lc_counter := lc_counter + 1;
		    				ld_counter := ld_counter + 1;
		    				if(lc_counter > R_columns) then
								lc_counter := 1;
								l2_counter := l2_counter + 1;
								state <= S0b;
							else
								state <= S0b;
							end if;
						else
							p := q-m;
							state <= S1;
						end if;

					when S1 =>
						state_num <= 3;
	    				--main loop
						p := p+1;
	    				if((p < q) or (p = q)) then
	    					-- determine the row of R2 which is being changed
							wanted_row := wanted_row + 1;
							lf_counter := 1;
							state <= S1a;
							k := 0;
						else
							l8_counter := 1;
							ll_counter := 1;
							lm_counter := 1;
	    					state <= S8;
	    				end if;

					when S1a =>
						state_num <= 4;
	    				--copy values of wanted row from R2 into wanted_R2 to find neg and pos values
						wanted_R2(lf_counter) := R2_matrix(wanted_row, lf_counter);
	    				lf_counter := lf_counter + 1;
	    				if(lf_counter > valid_column) then
	    					-- initiazlization for S1b
							jneg_size := 0;
							jpos_size := 0;
							jneg := (others => 0);
							jpos := (others => 0);
	    					l3_counter := 1;
	    					state <= S1b;
	    				else
	    					state <= S1a;
	    				end if;

					when S1b =>
						state_num <= 5;
	    				--find_neg and find_pos implementation
						if((l3_counter < valid_column) or (l3_counter = valid_column))  then
	    					if(Is_Negative(wanted_R2(l3_counter)) = false) then
	    						jpos_size := jpos_size + 1;
								jpos(jpos_size) := l3_counter;
	    					elsif(Is_Negative(wanted_R2(l3_counter)) = true) then
	    						jneg_size := jneg_size + 1;
								jneg(jneg_size) := l3_counter;
							end if;
	    					l3_counter := l3_counter + 1;
	    					state <= S1b;
						else
							--k := k+1;
	    					state <= S2;
	    				end if;

					when S2 =>
						state_num <= 6;
	    				k := k+1;
	    				--go to the inner loop for jpos
						if((k < jneg_size) or (k = jneg_size)) then
							lg_counter := R1_valid_row + 1;
							l := 0;
	    					state <= S3;
						else
							lj_counter := 1;
							l6_counter := 1;
	    					state <= S6;
	    				end if;

					when S3 =>
						state_num <= 7;
	    				--bitwise or of two columns of R1; one negative and one positive
	    				if(lg_counter > R1_valid_row) then	
	    					l := l+1;
	    					lg_counter := 1;
	    					state <= S3;
	    				elsif((l < jpos_size) or (l = jpos_size)) then
							newr(lg_counter) := R1_matrix(lg_counter,jneg(k)) or R1_matrix(lg_counter,jpos(l));
							lg_counter := lg_counter + 1;
							if(lg_counter > R1_valid_row) then
								l4_counter := 1;
								nullbits := 0;
								state <= S3a;
							else
								state <= S3;
							end if;
						else
							state <= s2;
						end if;

					when S3a =>
						state_num <= 8;
	    				--count the number of null bits in newr (the result of bitwise or in S3)
	    				if((l4_counter < R1_valid_row) or (l4_counter = R1_valid_row)) then
	    					if(newr(l4_counter) = '0') then
	    						nullbits := nullbits + 1;
	    					end if;
	    					l4_counter := l4_counter + 1;
	    					state <= S3a;
						else
	    					state <= S3aa;
	    				end if;

					when S3aa =>
						state_num <= 9;			
	    				--check the minimum number of zeros
						if(nullbits+1 < qsplit-m-1) then	--????????????????????????????????
							lg_counter := R1_valid_row + 1;
	    					state <= S3;
	    				else
	    					state <= S3b;
						end if;

					when S3b =>
						state_num <= 10;
	    				--initialization for adjacency test
	    				adj := 1;
						r := 0;
						lh_counter := R1_valid_row + 1;
	    				state <= S4;

					when S4 =>
						state_num <= 11;		
	    				--adjacency test: r+ or r- != r+ or r- or (other R columns)
	    				if(lh_counter > R1_valid_row) then
	    					r := r+1;
	    					lh_counter := 1;
	    					state <= S4;
	    				else
		    				if((r < valid_column or r = valid_column) and (adj = 1)) then
								testr(lh_counter) := newr(lh_counter) or R1_matrix(lh_counter, r);
		    					lh_counter := lh_counter + 1;
		    					if(lh_counter > R1_valid_row) then
									if ((r /= jpos(l)) and (r /= jneg(k)) and (testr = newr)) then
			    						adj := 0;
			    					else
			    					    adj := 1;
									end if;
			    					state <= S4;
								else
			    					state <= S4;
								end if;
							else
		    					state <= S5;
		  					end if;
						  end if;

					  when S5 =>
					  	state_num <= 12;
		  				--initializtion for combination loop in S5a
		  				if(adj = 1) then
							new_numr := new_numr + 1;
							valid_column := valid_column + 1;
							li_counter := 1;
							state <= S5a;
		    			else
		    				lg_counter := R1_valid_row + 1;
		    				state <= S3;
						end if;

					when S5a =>
						state_num <= 13;
	    				--combine and add the result of combination to R1
						R1_matrix(li_counter, new_numr) := newr(li_counter);
    			        li_counter := li_counter + 1;
    			        if(li_counter > R1_valid_row) then
    						l5_counter := wanted_row;
    						state <= S5b;
						else
    						state <= S5a;
    					end if;

					when S5b =>
						state_num <= 14;
	    				--combine and add the result of combination to R2
	    				if((l5_counter < R2_rows) or (l5_counter = R2_rows)) then
							newR2element := (R2_matrix(wanted_row, jpos(l))*R2_matrix(l5_counter, jneg(k)) - R2_matrix(wanted_row, jneg(k))*R2_matrix(l5_counter, jpos(l)));
							R2_matrix(l5_counter, new_numr) := newR2element(10 downto -10);
	    					l5_counter := l5_counter + 1;
	    					state <= S5b;
						else
							lg_counter := R1_valid_row + 1;
	    					state <= S3;
	    				end if;

					when S6 =>
						state_num <= 15;
	    				--copy the last columns of R1 in the place of columns with negative rows
	    				if((l6_counter < jneg_size) or (l6_counter = jneg_size)) then
							R1_matrix(lj_counter, jneg(l6_counter)) := R1_matrix(lj_counter, valid_column - l6_counter + 1);
	    					R1_matrix(lj_counter,valid_column - l6_counter + 1) := '0';
	    					lj_counter := lj_counter + 1;
							if(lj_counter > R1_valid_row) then
								lk_counter := 1;
	    						state <= S6a;
	    					else
	    						state <= S6;
	    					end if;
	    				else
	    					state <= S7;
	    				end if;
					when S6a =>
						state_num <= 16;
	    				--copy the last columns of R2 in the place of columns with negative rows
						R2_matrix(lk_counter, jneg(l6_counter)) := R2_matrix(lk_counter, valid_column - l6_counter + 1);
						R2_matrix(lk_counter, valid_column - l6_counter + 1) := zero;
						lk_counter := lk_counter + 1;
						if(lk_counter > R2_rows) then
							state <= S6b;
						else
							state <= S6a;
						end if;

					when S6b =>
						state_num <= 17;
	    				--some reset initiation for copy loops(deletion of neg rays)
	    				lj_counter := 1;
	    				l6_counter := l6_counter + 1;
	    				state <= S6;

					when S7 =>
						state_num <= 18;	
	    				--edit required after delete process
						--numr <= new_numr - jneg_size;
						new_numr := new_numr - jneg_size;
	    				valid_column := valid_column - jneg_size;
	    				--initialization to copy the last editted row of R2 into R1;
	    				R1_valid_row := R1_valid_row + 1;
	    				l7_counter := 1;
	    				state <= S7a;

					when S7a =>
						state_num <= 19;
	    				--copy the new binary row of R2 into R1;
	    				if((l7_counter < valid_column) or (l7_counter = valid_column)) then
	    					if(R2_matrix(wanted_row, l7_counter) > zero)then
	    						R1_matrix(R1_valid_row, l7_counter) := '1';
	    					elsif(R2_matrix(wanted_row, l7_counter) = zero) then
	    						R1_matrix(R1_valid_row, l7_counter) := '0';
							end if;
	    					l7_counter := l7_counter + 1;
	    					state <= S7a;
	    				else
	    					state <= S1;
						end if;

					when S8 =>
						state_num <= 20;
						--turn the 2D R2_matrix into a vector
						if((l8_counter < R1_valid_row) or (l8_counter = R1_valid_row)) then
							EM_data(lm_counter) <= R1_matrix(l8_counter, ll_counter);
							lm_counter := lm_counter + 1;
							ll_counter := ll_counter + 1;
							if(ll_counter > valid_column) then
								l8_counter := l8_counter + 1;
								ll_counter := 1;
								state <= S8;
							else
								state <= S8;
							end if;
						else
							state <= S_f;
						end if;

					when S_f =>
						state_num <= 21;
						--set the value of output signals and call software
						EM_columns <= valid_column;
						EM_rows <= R1_valid_row;
						SW_call <= '1';

	    			when others =>
	    				state <= S0;
	    			end case;
	  		end if;
	  	end if;
	end process;
end architecture;
