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
		M(2) <= "1110";
		M(3) <= "0000";
		M(4) <= "0010";
		M(5) <= "1011";
		M(6) <= "0010";
		M(7) <= "0010";
		M(8) <= "0010";
		M(9) <= "0010";
		M(10) <= "1111";
		M(11) <= "0000";
		M(12) <= "0101";
		M(13) <= "0010";
		M(14) <= "0010";
		M(15) <= "1111";
		M(16) <= "0000";
		M(17) <= "0110";
		M(18) <= "1111";
		M(19) <= "0000";
		M(20) <= "0111";
		M(21) <= "1111";
		M(22) <= "0000";
		M(23) <= "0100";
		M(24) <= "1111";
		M(25) <= "0000";
		M(26) <= "1000";
		M(27) <= "0000";
		M(28) <= "0000";
		
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