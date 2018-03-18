library work;
use work.my_package.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity main is
	generic(m : in integer range 0 to 2 :=1;				--metabolites
	        q : in integer range 0 to 6 := 5;			--reactions not splitted
	        qsplit : in integer range 0 to 7 := 6;		--reactions splitted
	        R_rows : in integer range 0 to 7 := 6;		--qsplit 
	        R_columns : in integer range 0 to 5 := 4;	--qsplit-m
	        R1_rows : in integer range 0 to 5 := 4;		--qsplit-m
	        R2_rows : in integer range 0 to 3 := 2);		--m
	port(clock, reset : in std_logic;
	   --R1_data : in std_logic_vector(1 to R1_rows*R_columns);
	   R1_data : in std_logic_vector(1 to 16);
	   --R2_data : in fixedp_array(1 to R2_rows*R_columns); 
	   R2_data : in fixedp_array(1 to 8); 
	   SW_call : out std_logic := '0';
	   EM_columns : out integer range 0 to 10 := 0;
	   EM_rows : out integer range 0 to 10 := 0;
	   --EM_data: out std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0')
	   EM_data: out std_logic_vector(1 to 16) := (others => '0')
      );
end entity;
architecture arch of main is
signal numr : integer := qsplit - m;	--same numr as in code
--signal EM_data : std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0');
constant max_column : integer := R_rows*(R_columns*R_columns + R_columns);  --max of columns in R after adding combination
signal zero : sfixed(10 downto -10);	--fixed point equal for zero
signal one : sfixed(10 downto -10);		--fixed point equal for one 
		
--signal R1_matrix : bit_matrix(1 to R_rows, max_column downto 1);	--signal to store R1 with max size
--signal R2_matrix : int_matrix(1 to R2_rows, max_column downto 1);	--signal to store R2 with max size

type state_type is (S0, S0a, S0b, S1, S1a, S1b, S2, S3, S3a, S3aa, S3b, S4, S5, S5a, S5b, S6, S6a, S6b, S7, S7a, S8, S_f);	--all states
signal state : state_type := S0;	--initial state

attribute fsm_encoding : string;
attribute fsm_encoding of state : signal is "sequential";

begin	
    zero <=  to_sfixed(0.0, zero);
    one <= to_sfixed(1.0, one);
    process(clock)
    --counters for different loops
    variable l1_counter, l2_counter, l3_counter, l4_counter, l5_counter, l6_counter, l7_counter, l8_counter : integer := 1;

    --counter for additional loops that implements matrix iteration
    variable lg_counter, lh_counter : integer;
    variable la_counter, lb_counter, lc_counter, ld_counter, lf_counter, li_counter, lj_counter, lk_counter, ll_counter, lm_counter : integer := 1;

    --variables the same as pseudo code
	variable new_numr : integer := numr;
	variable p : integer := q-m;	--main loop counter
	variable k : integer := 0;		--jneg loop counter 	
	variable l : integer := 0;		--jpos loop counter
	variable r : integer := 0;		--test loop counter
	variable adj : integer := 0;	--test result
	variable nullbits : integer := 0;	--number of zeros in newr 
	variable newr : std_logic_vector(1 to R_rows) := (others => '0');	--new column to be added
	variable testr : std_logic_vector(1 to R_rows):= (others => '0');	--test column
	
	--variables to store R1 and R2 with max size
	variable R1_matrix : bit_matrix(1 to R_rows, max_column downto 1) := (others =>(others => '0'));
	variable R2_matrix : fixedp_matrix(1 to R2_rows, max_column downto 1) := (others =>(others => zero));

	--jneg and jpos row_vectors and their size
	variable jneg : int_array (1 to max_column) := (others => 0); 	--row_vector of indices in R2 row with negative value
	variable jpos : int_array (1 to max_column) := (others => 0);	--row_vector of indices in R2 row with positive value
	variable jneg_size, jpos_size : integer := 0;					--size of jneg/jpos

	--S1 variables
	variable wanted_row : integer := 0;		--the row number of R2 which is being changed
	variable wanted_R2 : fixedp_array(1 to max_column) := (others => zero);	--the row_vector of R2 which is being changed
	variable pos_neg_index : integer := 1;	--index that is added to jpos or jneg	
	
	--S5 variables
	variable num_of_added : integer := 0;	--total number of columns added to R1 and R2
	variable valid_column : integer := R_columns;	--total number of valid columns in R2 and R1


	variable R1_valid_row : integer := R1_rows;		--total number of valid rows in R1
	variable R2_valid_row : integer := R2_rows;		--total number of valid rows in R2
	
	variable newR2element : sfixed(10 downto -10);		--
	
	begin
	  	if(rising_edge(clock)) then
	    	if (reset = '1') then
	    		state <= S0;
	    	else
	    		case state is
	    			when S0 =>	
	    				-- initializing some variables
		    			p := q-m;
		    			k := 0;
		    			l := 0;
		    			r := 0;
		    			l1_counter := 1;
		    			l2_counter := 1;
		    			la_counter := 1;
						lb_counter := 1;
						lc_counter := 1;
						ld_counter := 1;
						lf_counter := 1;
						wanted_row := 0;
						new_numr := numr;
						R1_valid_row := R1_rows;
		    			state <= S0a;
		
		    		when S0a =>
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
							state <= S0b;
						end if;

		    		when S0b =>
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
							state <= S1;
						end if;

	    			when S1 =>
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
	    				--find_neg and find_pos implementation
	    				if((l3_counter < valid_column) or (l3_counter = valid_column))  then
	    					if(wanted_R2(l3_counter) > zero) then
	    						jpos_size := jpos_size + 1;
	    						jpos(jpos_size) := l3_counter;
	    					elsif(wanted_R2(l3_counter) < zero) then
	    						jneg_size := jneg_size + 1;
	    						jneg(jneg_size) := l3_counter;
	    					end if;
	    					l3_counter := l3_counter + 1;
	    					state <= S1b;
	    				else
	    					state <= S2;
	    				end if;

	    			when S2 =>
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
	    				--bitwise or of two columns of R1; one negative and one positive
	    				if(lg_counter > R1_valid_row) then
	    					l := l+1;
	    					lg_counter := 1;
	    					state <= S3;
	    				else 
		    				if((l < jpos_size) or (l = jpos_size)) then
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
		    			end if;	

	    			when S3a =>
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
	    				--check the minimum number of zeros
						if(nullbits+1 < qsplit-m-1) then	--????????????????????????????????
							lg_counter := R1_valid_row + 1;
	    					state <= S3;
	    				else
	    					state <= S3b;
	    				end if;

	    			when S3b => 
	    				--initialization for adjacency test
	    				adj := 1;
						r := 0;
						lh_counter := R1_valid_row + 1;
	    				state <= S4;

	    			when S4 =>
	    				--adjacency test: r+ or r- != r+ or r- or (other R columns)
	    				if(lh_counter > R1_valid_row) then 
	    					r := r+1;
	    					lh_counter := 1;
	    					state <= S4;
	    				else
		    				if((r < numr) and (adj = 1)) then
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
		  				--initializtion for combination loop in S5a
		  				if(adj = 1) then
							new_numr := new_numr + 1;
							num_of_added := num_of_added + 1;
							valid_column := valid_column + 1;
							li_counter := 1;
							state <= S5a;
		    			else
		    				lg_counter := R1_valid_row + 1;
		    				state <= S3;
		    			end if;

	    			when S5a =>
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
	    				--copy the last columns of R1 in the place of columns with negative rows
	    				if((l6_counter < jneg_size) or (l6_counter = jneg_size)) then
	    					R1_matrix(lj_counter, jneg(l6_counter)) := R1_matrix(lj_counter, valid_column - l6_counter + 1);
	    					R1_matrix(lj_counter,valid_column - l6_counter + 1) := '0';
	    					lj_counter := lj_counter + 1;
							if(lj_counter > R1_rows) then
								lk_counter := 1;
	    						state <= S6a;
	    					else
	    						state <= S6;
	    					end if;
	    				else
	    					state <= S7;		
	    				end if;
	    			when S6a =>
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
	    				--some reset initiation for copy loops(deletion of neg rays)
	    				lj_counter := 1;
	    				l6_counter := l6_counter + 1;	
	    				state <= S6;

	    			when S7 =>
	    				--edit required after delete process
						numr <= new_numr - jneg_size;
						new_numr := new_numr - jneg_size;
	    				valid_column := valid_column - jneg_size;
	    				
	    				--initialization to copy the last editted row of R2 into R1;
	    				R1_valid_row := R1_valid_row + 1;
	    				l7_counter := 1;
	    				state <= S7a;
	    				
	    			when S7a =>
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