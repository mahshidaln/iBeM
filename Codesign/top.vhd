----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2018 01:09:32 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

library work;
use work.my_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
      Port (
        reset : in std_logic;
	    --R1_data : in std_logic_vector(1 to R1_rows*R_columns);
	    R1_data : in std_logic_vector(1 to 16);
	    --R2_data_postfix : in std_vec_array(1 to R2_rows*R_columns);
		R2_data_postfix : in std_vec_array(1 to 8);
	    SW_call : out std_logic := '0';
	    EM_columns : out integer range 0 to 10 := 0;
	    EM_rows : out integer range 0 to 10 := 0;
	    --EM_data: out std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0')
	    EM_data: out std_logic_vector(1 to 36) := (others => '0');
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC
    );
end top;

architecture Behavioral of top is
    signal clk : std_logic;
    component main is    
    generic(m : in integer range 0 to 2 :=1;			--metabolites
                q : in integer range 0 to 6 := 5;			--reactions not splitted
                qsplit : in integer range 0 to 7 := 6;		--reactions splitted
                R_rows : in integer range 0 to 7 := 6;		--qsplit
                R_columns : in integer range 0 to 5 := 4;	--qsplit-m
                R1_rows : in integer range 0 to 5 := 4;		--qsplit-m
                R2_rows : in integer range 0 to 3 := 2);	--m
        port(clock, reset : in std_logic;
            --R1_data : in std_logic_vector(1 to R1_rows*R_columns);
            R1_data : in std_logic_vector(1 to 16);
            --R2_data : in fixedp_array(1 to R2_rows*R_columns);
            --R2_data : in fixedp_array(1 to 8);
            R2_data_postfix : in std_vec_array(1 to 8);
            SW_call : out std_logic := '0';
            EM_columns : out integer range 0 to 10 := 0;
            EM_rows : out integer range 0 to 10 := 0;
            --EM_data: out std_logic_vector(1 to R_rows*((R_columns)*(R_columns) + R_columns)) := (others => '0')
            EM_data: out std_logic_vector(1 to 36) := (others => '0')
        );
    end component main;
    component design_1_wrapper is
        port (
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC;
        clk : out STD_LOGIC
        );
    end component design_1_wrapper; 
begin
    wrapper_map: design_1_wrapper port map (DDR_addr, DDR_ba, DDR_cas_n, DDR_ck_n, DDR_ck_p, DDR_cke, DDR_cs_n, DDR_dm, DDR_dq, 
    DDR_dqs_n, DDR_dqs_p, DDR_odt, DDR_ras_n, DDR_reset_n, DDR_we_n, FIXED_IO_ddr_vrn, FIXED_IO_ddr_vrp, FIXED_IO_mio, FIXED_IO_ps_clk,
    FIXED_IO_ps_porb, FIXED_IO_ps_srstb, clk);
    main_map: main generic map(1, 5, 6, 6, 4, 4, 2) port map (clk, reset, R1_data, R2_data_postfix, SW_call, EM_columns, EM_rows, EM_data);
    


end Behavioral;
