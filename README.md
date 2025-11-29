# 16-Bit-ALU-using-Verilog
📋 Overview

This repository contains the Verilog HDL implementation and verification of a comprehensive 16-bit Arithmetic Logic Unit (ALU). Designed as a core component for a 16-bit CPU, this ALU performs a wide range of arithmetic, bitwise logical, and shift/rotate operations. It features a robust status flag generation mechanism to report the outcome of operations (Carry, Zero, Negative, Overflow, Parity, and Auxiliary Carry).

The project is fully verified using a directed testbench in ModelSim, ensuring accuracy across all 20 implemented functions.

✨ Features

16-Bit Data Path: Processes two 16-bit signed/unsigned operands (A, B).

32-Operation Instruction Set: Controlled by a 5-bit opcode, supporting Arithmetic, Logic, Shift, and Rotate groups.

Unified Shifter Design: Uses a specialized Cflag input to handle both Logical Shifts and Rotates through Carry efficiently.

Complete Status Register: Generates a 6-bit status output:

C: Carry / Borrow / Shift Out

Z: Zero Result

N: Negative (Sign Bit)

V: Signed Overflow

P: Parity (Even)

AC: Auxiliary Carry (Half-Carry for BCD)
