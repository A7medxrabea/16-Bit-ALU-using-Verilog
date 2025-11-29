`timescale 10ps / 1ps

module ALU_16_tb;

    // ----------------------------------------------------
    // 1. DUT Signals (Testbench Wires/Regs)
    // ----------------------------------------------------
    reg  [15:0] A;
    reg  [15:0] B;
    reg         Cin;    // Arithmetic Carry/Borrow In
    reg         Cflag;  // Shift/Rotate Bit In
    reg  [4:0]  opcode;
    wire [15:0] result;
    wire [5:0]  status;
    
    // Deconstruct status flags for easier reading (C, Z, N, V, P, AC)
    wire C, Z, N, V, P, AC;
    assign {C, Z, N, V, P, AC} = status;

    // ----------------------------------------------------
    // 2. Instantiate the Device Under Test (DUT)
    // ----------------------------------------------------
    ALU_16 DUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Cflag(Cflag),
        .opcode(opcode),
        .result(result),
        .status(status)
    );

    // ----------------------------------------------------
    // 3. Test Stimulus Generation
    // ----------------------------------------------------
    initial begin
        $dumpfile("ALU_16.vcd");
        $dumpvars(0, ALU_16_tb);
        
        // Initialize inputs
        A = 16'h0000; B = 16'h0000;
        Cin = 1'b0; Cflag = 1'b0;
        opcode = 5'b00000;
        
        $display("----------------------------------------------------------------------------------------------------------------");
        $display("Starting ALU_16 Comprehensive Testbench (All 20 Functions)");
        $display("Time | Op | Operation | A      | B      | Cin Cf | Result | C Z N V P AC | Expected Result/Flags (C Z N V P AC)");
        $display("----------------------------------------------------------------------------------------------------------------");

        #10;
        
        // =====================================================================
        // GROUP 1: ARITHMETIC & PASS (Cin matters, Cflag is don't care)
        // =====================================================================

        // TEST 1: PASS A (00000)
        A = 16'hA5A5; B = 16'hFFFF; Cin = 0; Cflag = 0; opcode = 5'b00000; 
        #10 $display("%0t | %b | PASS A  | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | A5A5  (0 0 1 0 1 0)", 
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 2: PASS B (00010) - NEW
        A = 16'h0000; B = 16'h1234; Cin = 0; opcode = 5'b00010;
        #10 $display("%0t | %b | PASS B  | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 1234  (0 0 0 0 1 0)", 
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 3: INC (00001) (Overflow V=1, AC=1)
        A = 16'h7FFF; Cin = 0; opcode = 5'b00001;
        #10 $display("%0t | %b | INC (V) | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8000  (0 0 1 1 0 1)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 4: DEC (00011) (Underflow V=1)
        A = 16'h8000; opcode = 5'b00011;
        #10 $display("%0t | %b | DEC (V) | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 7FFF  (0 0 0 1 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 5: ADD (00100) (V=1)
        A = 16'h7000; B = 16'h1000; opcode = 5'b00100;
        #10 $display("%0t | %b | ADD (V) | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8000  (0 0 1 1 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 6: ADD_CARRY (00101)
        A = 16'h0001; B = 16'hFFF0; Cin = 1; opcode = 5'b00101;
        // FFF2 has 13 set bits (Odd). P should be 0.
        #10 $display("%0t | %b | ADD_C   | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | FFF2  (0 0 1 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 7: SUB (00110) (Z=1, No Borrow -> C=1)
        A = 16'h1000; B = 16'h1000; Cin = 0; opcode = 5'b00110;
        #10 $display("%0t | %b | SUB (Z) | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0000  (1 1 0 0 1 1)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 8: SUB_BORROW (00111) (5 - 3 - 1 = 1)
        // Uses ~Cin logic. If Cin=1 (Borrow is active), result is 5 - 3 - 1.
        A = 16'h0005; B = 16'h0003; Cin = 1; opcode = 5'b00111; 
        #10 $display("%0t | %b | SUB_BOR | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0001  (1 0 0 0 0 1)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // =====================================================================
        // GROUP 2: LOGIC (Cflag is don't care, Arith Flags cleared)
        // =====================================================================
        
        // TEST 9: AND (01000)
        A = 16'hA5A5; B = 16'hF00F; opcode = 5'b01000;
        #10 $display("%0t | %b | AND     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | A005  (0 0 1 0 1 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 10: OR (01001) - NEW
        A = 16'h00F0; B = 16'h0F00; opcode = 5'b01001;
        #10 $display("%0t | %b | OR      | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0FF0  (0 0 0 0 1 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 11: XOR (01010) - NEW
        A = 16'hFFFF; B = 16'hFFFF; opcode = 5'b01010;
        #10 $display("%0t | %b | XOR     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0000  (0 1 0 0 1 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 12: NOT (01011) - NEW
        A = 16'h0000; opcode = 5'b01011;
        #10 $display("%0t | %b | NOT     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | FFFF  (0 0 1 0 1 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // =====================================================================
        // GROUP 3: SHIFT/ROTATE (Cflag is Critical!)
        // =====================================================================
        
        A = 16'hC33C; // 1100_0011_0011_1100
        
        // TEST 13: SHL (10000) (Shift Logic Left)
        // Standard SHL shifts in 0. We must set Cflag = 0.
        opcode = 5'b10000; Cflag = 0;
        #10 $display("%0t | %b | SHL     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8678  (1 0 1 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 14: SHR (10001) (Shift Logic Right)
        // Standard SHR shifts in 0. We must set Cflag = 0.
        A = 16'h1000; 
        opcode = 5'b10001; Cflag = 0;
        #10 $display("%0t | %b | SHR     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0800  (0 0 0 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 15: SAL (10010) (Arithmetic Left) - NEW
        // Behaves same as SHL in this design. Cflag = 0.
        A = 16'hC33C; opcode = 5'b10010; Cflag = 0;
        #10 $display("%0t | %b | SAL     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8678  (1 0 1 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 16: SAR (10011) (Arithmetic Right) - NEW
        // Preserves Sign. Input 8000 (Neg), shifts right to C000. Cflag is ignored for sign fill.
        A = 16'h8000; opcode = 5'b10011; Cflag = 0; 
        #10 $display("%0t | %b | SAR     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | C000  (0 0 1 0 1 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 17: ROL (10100) (Rotate Left)
        // ROL shifts in the MSB. We must set Cflag = A[15].
        A = 16'h8000; // 1000...
        opcode = 5'b10100; Cflag = A[15]; // Cflag = 1
        // A[15] is 1, so Carry (C) should be 1.
        #10 $display("%0t | %b | ROL     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0001  (1 0 0 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 18: ROR (10101) (Rotate Right)
        // ROR shifts in the LSB. We must set Cflag = A[0].
        A = 16'h0001; // ...0001
        opcode = 5'b10101; Cflag = A[0]; // Cflag = 1
        #10 $display("%0t | %b | ROR     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8000  (1 0 1 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        // TEST 19: RCL (10110) (Rotate Through Carry Left)
        // RCL shifts in the old Carry. We'll simulate Carry=1 by setting Cflag=1.
        A = 16'h0000; 
        opcode = 5'b10110; Cflag = 1; 
        #10 $display("%0t | %b | RCL     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 0001  (0 0 0 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);
            
        // TEST 20: RCR (10111) (Rotate Through Carry Right)
        // RCR shifts in the old Carry. We'll simulate Carry=1 by setting Cflag=1.
        A = 16'h0000;
        opcode = 5'b10111; Cflag = 1;
        #10 $display("%0t | %b | RCR     | %h | %h |  %b  %b | %h | %b %b %b %b %b %b | 8000  (0 0 1 0 0 0)",
            $time, opcode, A, B, Cin, Cflag, result, C, Z, N, V, P, AC);

        $display("----------------------------------------------------------------------------------------------------------------");
        $display("ALU_16 Testbench finished.");
        $finish;
    end

endmodule
