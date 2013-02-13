--******************************************************************************
-- File: Processor.VHD
-- Author: Caroline Lichtenberger
-- Created: 2/04/13
-- Description: Simple 4-Bit processor
--******************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Multiplier_TB IS
END Multiplier_TB;

ARCHITECTURE beh OF Multiplier_TB IS
	
	COMPONENT Processor IS
		PORT(
			CLK,RST	 	 :	IN STD_LOGIC;
			SWH,SWL		 :	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			DISPH,DISPL	 :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	
	-- Inputs
	SIGNAL clock, reset	:	STD_LOGIC;
	SIGNAL SH, SL		:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Outputs
	SIGNAL DH, DL		:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	SIGNAL prod			:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	-- Delay
	CONSTANT delay : time := 100 mS;
	
	-- Clock period
	CONSTANT clk_per : time :=	100 uS;
	
BEGIN
	
	uut : Processor
	PORT MAP(
		CLK => clock,
		RST => reset,
		SWH => SH,
		SWL => SL,
		DISPH => DH,
		DISPL => DL
	);
	
	prod <= DH & DL;
	
	-- Clock signal with 50% DC
	clock_freq : PROCESS
	BEGIN
		clock <= '0';
		WAIT FOR clk_per/2;
		clock <= '1';
		WAIT FOR clk_per/2;
	END PROCESS clock_freq;
	
	-- Begin multiplication test
	verification : PROCESS
	BEGIN
		FOR i IN 0 TO 15 LOOP
			FOR j IN 0 TO 15 LOOP
				SH <= CONV_STD_LOGIC_VECTOR(i,4);
				SL <= CONV_STD_LOGIC_VECTOR(j,4);
				reset <= '0';
				WAIT FOR 40 nS;
				reset <= '1';
				WAIT FOR delay;
				ASSERT((CONV_INTEGER('0'&prod)) = (CONV_INTEGER('0'&SH))*(CONV_INTEGER('0'&SL))) REPORT "All aboard the fail bus!" SEVERITY FAILURE;
			END LOOP;
		END LOOP;
		REPORT "Done";
		wait;
	END PROCESS verification;
	
END beh;