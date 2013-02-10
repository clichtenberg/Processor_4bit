--******************************************************************************
-- File: Processor.VHD
-- Author: Caroline Lichtenberger
-- Created: 2/04/13
-- Description: Simple 4-Bit processor
--******************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY Processor IS
	PORT(
		CLK,RST	 	 :	IN STD_LOGIC;
		SWH,SWL		 :	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		DISPH,DISPL	 :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END Processor;

ARCHITECTURE beh OF Processor IS
	
	-- Carry register
	SIGNAL C	:	STD_LOGIC;
	
	-- A and B registers
	SIGNAL A,B	:	STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	
	-- Program counter
	SIGNAL PC	:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	-- Memory address register
	-- Divided into MAH(7 DOWNTO 4) and MAL (3 DOWNTO 0)
	SIGNAL MA	:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	-- Instruction register
	SIGNAL IR	:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Display register to write to seven segment displays
	SIGNAL DH,DL,SH,SL	:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Main memory (8 bit addresses; 256 words; 1 word is 4 bits wide
	TYPE MEM IS ARRAY (255 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL M	:	MEM;
	
	-- Temporary register
	SIGNAL temp	:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- States for FSM
	TYPE state IS (instrFetch, ADD0, SUB0, INC0, DEC0, NOT0, AND0, OR0, XOR0, JMPU0, JMPU1, JMPU2, JMPC0, JMPC1, JMPC2, 
					SWAP0, CPY0, WR0, WR1, WR2, RD0, RD1, RD2, IN0, IN1, OUT0, OUT1, decodeIR);
	SIGNAL currentState	:	state;
	
BEGIN

C <= temp(4);
A <= temp(3 DOWNTO 0);

PROCESS(RST, CLK)

BEGIN
	IF(RST = '0') THEN
		-- Reset state
		-- Initialize main memory
		M(0) <= "1011";
		M(1) <= "0001";
		M(3) <= "1110";
		M(4) <= "0000";
		M(5) <= "0010";
		M(6) <= "1011";
		M(7) <= "0010";
		M(8) <= "0010";
		M(9) <= "0010";
		M(10) <= "0010";
		M(11) <= "1111";
		M(12) <= "0000";
		M(13) <= "0101";
		M(14) <= "0010";
		M(15) <= "0010";
		M(16) <= "1111";
		M(17) <= "0000";
		M(18) <= "0110";
		M(19) <= "1111";
		M(20) <= "0000";
		M(21) <= "0111";
		M(22) <= "1111";
		M(23) <= "0000";
		M(24) <= "0100";
		M(25) <= "1111";
		M(26) <= "0000";
		M(27) <= "1000";
		M(28) <= "0000";
		M(29) <= "0000";
		M(30) <= "0000";
		M(31) <= "0000";
		M(32) <= "0000";
		M(33) <= "0000";
		M(34) <= "0000";
		M(35) <= "0000";
		M(36) <= "0000";
		M(37) <= "0000";
		M(38) <= "0000";
		M(39) <= "0000";
		M(40) <= "0000";
		M(41) <= "0000";
		M(42) <= "0000";
		M(43) <= "0000";
		M(44) <= "0000";
		M(45) <= "0000";
		M(46) <= "0000";
		M(47) <= "0000";
		M(48) <= "0000";
		M(49) <= "0000";
		M(50) <= "0000";
		M(51) <= "0000";
		M(52) <= "0000";
		M(53) <= "0000";
		M(54) <= "0000";
		M(55) <= "0000";
		M(56) <= "0000";
		M(57) <= "0000";
		M(58) <= "0000";
		M(59) <= "0000";
		M(60) <= "0000";
		M(61) <= "0000";
		M(62) <= "0000";
		M(63) <= "0000";
		M(64) <= "0000";
		M(65) <= "0000";
		M(66) <= "0000";
		M(67) <= "0000";
		M(68) <= "0000";
		M(69) <= "0000";
		M(70) <= "0000";
		M(71) <= "0000";
		M(72) <= "0000";
		M(73) <= "0000";
		M(74) <= "0000";
		M(75) <= "0000";
		M(76) <= "0000";
		M(77) <= "0000";
		M(78) <= "0000";
		M(79) <= "0000";
		M(80) <= "0000";
		M(81) <= "0000";
		M(82) <= "0000";
		M(83) <= "0000";
		M(84) <= "0000";
		M(85) <= "0000";
		M(86) <= "0000";
		M(87) <= "0000";
		M(88) <= "0000";
		M(89) <= "0000";
		M(90) <= "0000";
		M(91) <= "0000";
		M(92) <= "0000";
		M(93) <= "0000";
		M(94) <= "0000";
		M(95) <= "0000";
		M(96) <= "0000";
		M(97) <= "0000";
		M(98) <= "0000";
		M(99) <= "0000";
		M(100) <= "0000";
		M(101) <= "0000";
		M(102) <= "0000";
		M(103) <= "0000";
		M(104) <= "0000";
		M(105) <= "0000";
		M(106) <= "0000";
		M(107) <= "0000";
		M(108) <= "0000";
		M(109) <= "0000";
		M(110) <= "0000";
		M(111) <= "0000";
		M(112) <= "0000";
		M(113) <= "0000";
		M(114) <= "0000";
		M(115) <= "0000";
		M(116) <= "0000";
		M(117) <= "0000";
		M(118) <= "0000";
		M(119) <= "0000";
		M(120) <= "0000";
		M(121) <= "0000";
		M(122) <= "0000";
		M(123) <= "0000";
		M(124) <= "0000";
		M(125) <= "0000";
		M(126) <= "0000";
		M(127) <= "0000";
		M(128) <= "0000";
		M(129) <= "0000";
		M(130) <= "0000";
		M(131) <= "0000";
		M(132) <= "0000";
		M(133) <= "0000";
		M(134) <= "0000";
		M(135) <= "0000";
		M(136) <= "0000";
		M(137) <= "0000";
		M(138) <= "0000";
		M(139) <= "0000";
		M(140) <= "0000";
		M(141) <= "0000";
		M(142) <= "0000";
		M(143) <= "0000";
		M(144) <= "0000";
		M(145) <= "0000";
		M(146) <= "0000";
		M(147) <= "0000";
		M(148) <= "0000";
		M(149) <= "0000";
		M(150) <= "0000";
		M(151) <= "0000";
		M(152) <= "0000";
		M(153) <= "0000";
		M(154) <= "0000";
		M(155) <= "0000";
		M(156) <= "0000";
		M(157) <= "0000";
		M(158) <= "0000";
		M(159) <= "0000";
		M(160) <= "0000";
		M(161) <= "0000";
		M(162) <= "0000";
		M(163) <= "0000";
		M(164) <= "0000";
		M(165) <= "0000";
		M(166) <= "0000";
		M(167) <= "0000";
		M(168) <= "0000";
		M(169) <= "0000";
		M(170) <= "0000";
		M(171) <= "0000";
		M(172) <= "0000";
		M(173) <= "0000";
		M(174) <= "0000";
		M(175) <= "0000";
		M(176) <= "0000";
		M(177) <= "0000";		
		M(178) <= "0000";
		M(179) <= "0000";
		M(180) <= "0000";
		M(181) <= "0000";
		M(182) <= "0000";
		M(183) <= "0000";
		M(184) <= "0000";
		M(185) <= "0000";
		M(186) <= "0000";
		M(187) <= "0000";
		M(188) <= "0000";
		M(189) <= "0000";
		M(190) <= "0000";
		M(191) <= "0000";
		M(192) <= "0000";
		M(193) <= "0000";
		M(194) <= "0000";
		M(195) <= "0000";
		M(196) <= "0000";
		M(197) <= "0000";
		M(198) <= "0000";
		M(199) <= "0000";
		M(200) <= "0000";
		M(201) <= "0000";
		M(202) <= "0000";
		M(203) <= "0000";
		M(204) <= "0000";
		M(205) <= "0000";
		M(206) <= "0000";
		M(207) <= "0000";
		M(208) <= "0000";
		M(209) <= "0000";
		M(210) <= "0000";
		M(211) <= "0000";
		M(212) <= "0000";
		M(213) <= "0000";
		M(214) <= "0000";
		M(215) <= "0000";
		M(216) <= "0000";
		M(217) <= "0000";
		M(218) <= "0000";
		M(219) <= "0000";
		M(220) <= "0000";
		M(221) <= "0000";
		M(222) <= "0000";
		M(223) <= "0000";
		M(224) <= "0000";
		M(225) <= "0000";
		M(226) <= "0000";
		M(227) <= "0000";
		M(228) <= "0000";
		M(229) <= "0000";
		M(230) <= "0000";
		M(231) <= "0000";
		M(232) <= "0000";
		M(233) <= "0000";
		M(234) <= "0000";
		M(235) <= "0000";
		M(236) <= "0000";
		M(237) <= "0000";
		M(238) <= "0000";
		M(239) <= "0000";
		M(240) <= "0000";
		M(241) <= "0000";
		M(242) <= "0000";
		M(243) <= "0000";
		M(244) <= "0000";
		M(245) <= "0000";
		M(246) <= "0000";
		M(247) <= "0000";
		M(248) <= "0000";
		M(249) <= "0000";
		M(250) <= "0000";
		M(251) <= "0000";
		M(252) <= "0000";
		M(253) <= "0000";
		M(254) <= "0000";
		M(255) <= "0000";
		
		PC <= CONV_STD_LOGIC_VECTOR(0,8);
		currentState <= instrFetch;
		temp <= "00000";
		b <= "0000";
		
	ELSE
		IF(CLK'EVENT AND CLK = '1') THEN
		CASE currentState IS
			-- Instruction Fetch
			WHEN instrFetch =>
				IR <= M(CONV_INTEGER('0' & PC)); -- IR now holds opcode
				currentState <= decodeIR;
			WHEN decodeIR =>
				IF(IR = "0000") THEN
					currentState <= ADD0;
				ELSIF(IR = "0001") THEN
					currentState <= SUB0;
				ELSIF(IR = "0010") THEN
					currentState <= INC0;
				ELSIF(IR = "0011") THEN
					currentState <= DEC0;
				ELSIF(IR = "0100") THEN
					currentState <= NOT0;
				ELSIF(IR = "0101") THEN
					currentState <= AND0;
				ELSIF(IR = "0110") THEN
					currentState <= OR0;
				ELSIF(IR = "0111") THEN
					currentState <= XOR0;
				ELSIF(IR = "1000") THEN
					currentState <= JMPU0;
				ELSIF(IR = "1001") THEN
					currentState <= JMPC0;
				ELSIF(IR = "1010") THEN
					currentState <= SWAP0;
				ELSIF(IR = "1011") THEN
					currentState <= CPY0;
				ELSIF(IR = "1100") THEN
					currentState <= WR0;
				ELSIF(IR = "1101") THEN
					currentState <= RD0;
				ELSIF(IR = "1110") THEN
					currentState <= IN0;
				ELSIF(IR = "1111") THEN
					currentState <= OUT0;
				ELSE
					currentState <= instrFetch;
				END IF;
				PC <= PC + '1';
			-- Addition
			WHEN ADD0 =>
				temp <= ('0' & A) + B;
				currentState <= instrFetch;
			-- Subtraction
			WHEN SUB0 =>
				temp <= ('1' & A) - B;
				currentState <= instrFetch;
			-- Increment
			WHEN INC0 =>
				temp <= ('0' & A) + '1';
				currentState <= instrFetch;
			-- Decrement
			WHEN DEC0 =>
				temp <= ('1' & A) - '1';
				currentState <= instrFetch;
			-- Negation
			WHEN NOT0 =>
				temp(3 DOWNTO 0) <= (NOT(A));
				currentState <= instrFetch;
			-- Logical AND
			WHEN AND0 =>
				temp(3 DOWNTO 0) <= (A AND B);
				currentState <= instrFetch;
			-- Logical OR
			WHEN OR0 =>
				temp(3 DOWNTO 0) <= (A OR B);
				currentState <= instrFetch;
			-- Logical XOR
			WHEN XOR0 =>
				temp(3 DOWNTO 0) <= (A XOR B);
				currentState <= instrFetch;
			-- Unconditional Jump MC0
			WHEN JMPU0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= JMPU1;
			-- Unconditional Jump MC1
			WHEN JMPU1 =>
				-- MAL write
				MA(3 DOWNTO 0) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= JMPU2;
			-- Unconditional Jump MC2
			WHEN JMPU2 =>
				-- Execute jump
				PC <= MA;
				currentState <= instrFetch;
			-- Conditional Jump MC0
			WHEN JMPC0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= JMPC1;
			-- Conditional Jump MC1
			WHEN JMPC1 =>
				-- MAL write
				MA(3 DOWNTO 0) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= JMPC2;
			-- Conditional Jump MC2
			WHEN JMPC2 =>
				-- Execute conditional jump based on carry bit
				IF(C = '0') THEN
					PC <= MA;
					currentState <= instrFetch;
				ELSE
					currentState <= instrFetch;
				END IF;
			-- Swap A and B register contents
			WHEN SWAP0 =>
				temp(3 DOWNTO 0) <= B;
				B <= A;
				currentState <= instrFetch;
			-- Copy contents of A into B
			WHEN CPY0 =>
				B <= A;
				currentState <= instrFetch;
			-- Memory write MC0
			WHEN WR0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= WR1;
			-- Memory write MC1
			WHEN WR1 =>
				-- MAL write
				MA(3 DOWNTO 0) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= WR2;
			-- Memory write MC2
			WHEN WR2 =>
				-- Write contents of A to main memory
				M(CONV_INTEGER('0' & MA)) <= A;
				currentState <= instrFetch;
			-- Memory read MC0
			WHEN RD0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= RD1;
			-- Memory read MC1
			WHEN RD1 =>
				-- MAL write
				MA(3 DOWNTO 0) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= RD2;
			-- Memory read MC2
			WHEN RD2 =>
				-- Read contents of main memory into A
				temp(3 DOWNTO 0) <= M(CONV_INTEGER('0' & MA));
				currentState <= instrFetch;
			-- Read input peripheral into A MC0
			WHEN IN0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= IN1;
			-- Read input peripheral into A MC0
			WHEN IN1 =>
				-- Which switch to read?
				IF(MA(7) = '1') THEN
					temp(3 DOWNTO 0) <= SWH;
				ELSE
					temp(3 DOWNTO 0) <= SWL;
				END IF;
				currentState <= instrFetch;
			-- Write contents of A to output peripheral MC0
			WHEN OUT0 =>
				-- MAH write
				MA(7 DOWNTO 4) <= M(CONV_INTEGER('0' & PC));
				PC <= PC + '1';
				currentState <= OUT1;
			WHEN OUT1 =>
				-- Which display to output to?
				IF(MA(7) = '1') THEN
					DISPH <= A;
				ELSE
					DISPL <= A;
				END IF;
				currentState <= instrFetch;
			WHEN OTHERS =>
				currentState <= instrFetch;
			
		END CASE;
		END IF;
	END IF;
END PROCESS;
END beh;