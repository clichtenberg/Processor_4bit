--******************************************************************************
-- File: multiplierHWTB.vhd
-- Author: Caroline Lichtenberger
-- Description: Hardware test bench for multiplier
--******************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY multiplierHWTB IS
	PORT(
		SYS_CLK_25							: IN std_logic;
		reset								: IN std_logic;
		switchesl, switchesh				: IN std_logic_vector(3 downto 0);
		MSBa,MSBb,MSBc,MSBd,MSBe,MSBf,MSBg,
		LSBa,LSBb,LSBc,LSBd,LSBe,LSBf,LSBg	: OUT std_logic
	);

END multiplierHWTB;

ARCHITECTURE Behavioral OF multiplierHWTB IS
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
	
	SIGNAL display_l,display_h : std_logic_vector(3 downto 0);
	
BEGIN
		
	myProc : Processor
		PORT MAP(
			CLK => SYS_CLK_25,
			RST => reset,
			SWH => switchesh,
			SWL => switchesl,
			DISPH => display_h,
			DISPL => display_l
		);
		
	MSD : dec_7seg
		PORT MAP(hex_digit => display_h,
				segment_a => MSBa, segment_b => MSBb, segment_c => MSBc, 
				segment_d => MSBd,	segment_e => MSBe, segment_f => MSBf, 
				segment_g => MSBg);	
	
	LSD : dec_7seg
		PORT MAP(hex_digit => display_l,
				segment_a => LSBa, segment_b => LSBb, segment_c => LSBc, 
				segment_d => LSBd,	segment_e => LSBe, segment_f => LSBf, 
				segment_g => LSBg);
END Behavioral;

