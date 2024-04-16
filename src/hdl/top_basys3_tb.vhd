--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2024 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : top_basys3.vhd
--| AUTHOR(S)     : C3C Parker Douglas
--| CREATED       : 14 Apr 2024
--| DESCRIPTION   : This file implements the top level module for a BASYS 3 to 
--|					drive the Lab 4 Design Project (Advanced Elevator Controller).
--|
--|					Inputs: clk       --> 100 MHz clock from FPGA
--|							btnL      --> Rst Clk
--|							btnR      --> Rst FSM
--|							btnU      --> Rst Master
--|							btnC      --> GO (request floor)
--|							sw(15:12) --> Passenger location (floor select bits)
--| 						sw(3:0)   --> Desired location (floor select bits)
--| 						 - Minumum FUNCTIONALITY ONLY: sw(1) --> up_down, sw(0) --> stop
--|							 
--|					Outputs: led --> indicates elevator movement with sweeping pattern (additional functionality)
--|							   - led(10) --> led(15) = MOVING UP
--|							   - led(5)  --> led(0)  = MOVING DOWN
--|							   - ALL OFF		     = NOT MOVING
--|							 an(3:0)    --> seven-segment display anode active-low enable (AN3 ... AN0)
--|							 seg(6:0)	--> seven-segment display cathodes (CG ... CA.  DP unused)
--|
--| DOCUMENTATION : None
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : MooreElevatorController.vhd, clock_divider.vhd, sevenSegDecoder.vhd
--|				   thunderbird_fsm.vhd, sevenSegDecoder, TDM4.vhd, OTHERS???
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_basys3_tb is
end top_basys3_tb;

architecture test_bench of top_basys3_tb is

    component top_basys3 is
        port(
            -- inputs
            clk     :   in std_logic; -- native 100MHz FPGA clock
            sw      :   in std_logic_vector(15 downto 0);
            btnU    :   in std_logic; -- master_reset
            btnL    :   in std_logic; -- clk_reset
            btnR    :   in std_logic; -- fsm_reset
            
            -- outputs
            led :   out std_logic_vector(15 downto 0);
            -- 7-segment display segments (active-low cathodes)
            seg :   out std_logic_vector(6 downto 0);
            -- 7-segment display active-low enables (anodes)
            an  :   out std_logic_vector(3 downto 0)
        );
    end component top_basys3;
    
    --setup test clock (10 ns --> 100 MHz)
    constant k_clk_period   : time  := 10 ns;
    
    signal w_sw   : std_logic_vector(15 downto 0) := "0000000000000000";
    signal w_btnR, w_btnU, w_btnL, w_clk : std_logic := '0';
    
    signal w_led  : std_logic_vector(15 downto 0) := "0000000000000000";
    signal w_seg  : std_logic_vector(6 downto 0)  := "0000000";
    signal w_an   : std_logic_vector(3 downto 0)  := "0000";

begin
    uut_inst : top_basys3
    port map (
        --inputs
        clk     => w_clk,
        sw      => w_sw,
        btnU    => w_btnU,
        btnL    => w_btnL,
        btnR    => w_btnR,
        
        --outputs
        led     => w_led,
        seg     => w_seg,
        an      => w_an
    );

--Clock Process
    clk_process : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        
        w_clk <= '1';
        wait for k_clk_period/2;
    end process clk_process;
    
    --Test Plan Process
    test_process : process
    begin
        wait for k_clk_period * 2;
        
        w_sw(0)   <= '0';
        w_sw(1)   <= '1';
        wait;
    end process;

end test_bench;
