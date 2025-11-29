module ALU_16 (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,     // For arithmetic operations with carry/borrow
    input  wire        Cflag,   // For shift/rotate operations
    input  wire [4:0]  opcode,  // F[4:0]
    output reg  [15:0] result,
    output wire [5:0]  status   // {C, Z, N, V, P, AC}
);

    // Named flags
    reg C, Z, N, V, P, AC;
    assign status = {C, Z, N, V, P, AC};

    reg [16:0] temp_full;    // Wide arithmetic
    reg [4:0]  temp_low;     // Low nibble arithmetic

    always @(*) begin
        // --- Defaults ---
        result = 16'b0;
        C = 1'b0; Z = 1'b0; N = 1'b0; V = 1'b0; P = 1'b0; AC = 1'b0;
        temp_full = 17'b0;
        temp_low = 5'b0;

        case (opcode)
            // ----------------------
            // PASS A / B
            // ----------------------
            5'b00000: result = A; // PASS A
            5'b00010: result = B; // PASS B

            // ----------------------
            // INC / DEC
            // ----------------------
            5'b00001: begin // INC
                temp_full = {1'b0,A} + 17'd1;
                result = temp_full[15:0];
                C = temp_full[16];
                temp_low = {1'b0,A[3:0]} + 5'd1;
                AC = temp_low[4];
                V = (~A[15] & result[15]);
            end
            5'b00011: begin // DEC
                temp_full = {1'b0,A} - 17'd1;
                result = temp_full[15:0];
                C = temp_full[16];
                temp_low = {1'b0,A[3:0]} + 5'b1111;
                AC = temp_low[4];
                V = (A[15] & ~result[15]);
            end

            // ----------------------
            // ADD / ADD_CARRY
            // ----------------------
            5'b00100: begin
                temp_full = {1'b0,A} + {1'b0,B};
                result = temp_full[15:0];
                C = temp_full[16];
                V = (A[15]&B[15]&~result[15]) | (~A[15]&~B[15]&result[15]);
                temp_low = {1'b0,A[3:0]} + {1'b0,B[3:0]};
                AC = temp_low[4];
            end
            5'b00101: begin // ADD_CARRY
                temp_full = {1'b0,A} + {1'b0,B} + {16'b0,Cin};
                result = temp_full[15:0];
                C = temp_full[16];
                V = (A[15]&B[15]&~result[15]) | (~A[15]&~B[15]&result[15]);
                temp_low = {1'b0,A[3:0]} + {1'b0,B[3:0]} + {4'b0,Cin};
                AC = temp_low[4];
            end

            // ----------------------
            // SUB / SUB_BORROW
            // ----------------------
            5'b00110: begin // SUB
                temp_full = {1'b0,A} + {1'b0,~B} + 17'd1;
                result = temp_full[15:0];
                C = temp_full[16];
                V = (A[15]&~B[15]&~result[15]) | (~A[15]&B[15]&result[15]);
                temp_low = {1'b0,A[3:0]} + {1'b0,~B[3:0]} + 5'd1;
                AC = temp_low[4];
            end
            5'b00111: begin // SUB_BORROW
                temp_full = {1'b0,A} + {1'b0,~B} + {16'b0,~Cin};
                result = temp_full[15:0];
                C = temp_full[16];
                V = (A[15]&~B[15]&~result[15]) | (~A[15]&B[15]&result[15]);
                temp_low = {1'b0,A[3:0]} + {1'b0,~B[3:0]} + {4'b0,~Cin};
                AC = temp_low[4];
            end

            // ----------------------
            // LOGIC: AND / OR / XOR / NOT
            // ----------------------
            5'b01000: result = A & B;
            5'b01001: result = A | B;
            5'b01010: result = A ^ B;
            5'b01011: result = ~A;

            // Clear C, V, AC for logic
            5'b01000,5'b01001,5'b01010,5'b01011: begin C=0; V=0; AC=0; end

            // ----------------------
            // SHIFTS
            // ----------------------
            5'b10000: begin // SHL
                C = A[15];
                result = {A[14:0], Cflag};
                V = 0; AC = 0;
            end
            5'b10001: begin // SHR
                C = A[0];
                result = {Cflag, A[15:1]};
                V = 0; AC = 0;
            end
            5'b10010: begin // SAL
                C = A[15];
                result = {A[14:0], Cflag};
                V = 0; AC = 0;
            end
            5'b10011: begin // SAR
                C = A[0];
                result = {A[15], A[15:1]};
                V = 0; AC = 0;
            end

            // ----------------------
            // ROTATES
            // ----------------------
            5'b10100: begin // ROL
                C = A[15];
                result = {A[14:0], Cflag};
                V = 0; AC = 0;
            end
            5'b10101: begin // ROR
                C = A[0];
                result = {Cflag, A[15:1]};
                V = 0; AC = 0;
            end
            5'b10110: begin // RCL
                C = A[15];
                result = {A[14:0], Cflag};
                V = 0; AC = 0;
            end
            5'b10111: begin // RCR
                C = A[0];
                result = {Cflag, A[15:1]};
                V = 0; AC = 0;
            end

            // ----------------------
            // DEFAULT
            // ----------------------
            default: result = A;
        endcase

        // --- Common Flags ---
        Z = (result==16'b0);
        N = result[15];
        P = ~(^result);
    end

endmodule

