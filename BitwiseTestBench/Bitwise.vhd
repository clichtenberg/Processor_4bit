--******************************************************************************
-- File: Bitwise.VHD
-- Author: Caroline Lichtenberger
-- Created: 2/04/13
-- Description: Bitwise logic function test bench
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Bitwise IS
END Bitwise;

ARCHITECTURE beh OF Bitwise IS

-- Place opcodes in memory initialization in the reset in Processor.VHD

	COMPONENT Processor IS
		PORT(
			CLK,RST	 	 :	IN STD_LOGIC;
			SWH,SWL		 :	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			DISPH,DISPL	 :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	
	-- Inputs
	SIGNAL clock, reset	:	STD_LOGIC;
	SIGNAL SH, SL	:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- Outputs
	SIGNAL DH,DL 	:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Delay time
	CONSTANT delay : time := 65 nS;
	
	-- Clock period
	CONSTANT clk_per : time :=	100 uS;
	
BEGIN
	uut:Processor
	PORT MAP(
		CLK => clock,
		RST => reset,
		SWH => SH,
		SWL => SL,
		DISPH => DH,
		DISPL => DL
	);
	
	-- Clock signal with 50% DC
	clock_freq : PROCESS
	BEGIN
		clock <= '0';
		WAIT FOR clk_per/2;
		clock <= '1';
		WAIT FOR clk_per/2;
	END PROCESS clock_freq;
	
	-- Begin bitwise test
	verification: PROCESS
	BEGIN
			WAIT FOR 20 nS;
			reset <= '0';
			SH <= "0000";
			SL <= "0110";
			WAIT FOR 50 nS;
			reset <= '1';
			wait;
	END PROCESS verification;
END beh;