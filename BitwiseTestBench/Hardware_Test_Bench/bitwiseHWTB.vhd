--******************************************************************************
-- File: bitwiseHWTB.vhd
-- Author: Caroline Lichtenberger
-- Description: Hardware test bench for 
--
--******************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY bitwiseHWTB IS
	PORT(
		SYS_CLK_25	: IN std_logic;
		reset		: IN std_logic;
		switches	: IN std_logic_vector(3 downto 0);
		LSBa,LSBb,LSBc,LSBd,LSBe,LSBf,LSBg			: OUT std_logic
	);

END bitwiseHWTB;

architecture beh of bitwiseHWTB is
	COMPONENT Processor
		PORT(
			CLK,RST	 	 :	IN STD_LOGIC;
			SWH,SWL		 :	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			DISPH,DISPL	 :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	
		-- Decimal to seven segment decoder
	COMPONENT DEC_7SEG IS
		PORT(
			hex_digit						: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
			segment_a, segment_b, segment_c, segment_d, segment_e, 
			segment_f, segment_g 			: OUT std_logic
		 );
	END COMPONENT;
		
	COMPONENT clk_div
		PORT(
			clock_25Mhz				: IN	STD_LOGIC;
			clock_1MHz				: OUT	STD_LOGIC;
			clock_100KHz			: OUT	STD_LOGIC;
			clock_10KHz				: OUT	STD_LOGIC;
			clock_1KHz				: OUT	STD_LOGIC;
			clock_100Hz				: OUT	STD_LOGIC;
			clock_10Hz				: OUT	STD_LOGIC;
			clock_1Hz				: OUT	STD_LOGIC
		);
	END COMPONENT;

	signal clk_slow : std_logic;
	SIGNAL display_l : std_logic_vector(3 downto 0);
	
BEGIN
	--display <= not display_h; -- LEDs are active low!
		
	clk_gen : clk_div
		PORT MAP(
			clock_25Mhz			=> SYS_CLK_25,
			clock_1MHz			=> open,
			clock_100KHz		=> open,
			clock_10KHz			=> open,
			clock_1KHz			=> open,
			clock_100Hz			=> open,
			clock_10Hz			=> clk_slow,
			clock_1Hz			=> open
		);
		
	myProc : Processor
		PORT MAP(
			CLK => clk_slow,
			RST => reset,
			SWH => x"A",
			SWL => switches,
			DISPH => open,
			DISPL => display_l
		);
		
	LSD : dec_7seg
		PORT MAP(hex_digit => display_l,
				segment_a => LSBa, segment_b => LSBb, segment_c => LSBc, 
				segment_d => LSBd,	segment_e => LSBe, segment_f => LSBf, 
				segment_g => LSBg);
END beh;

