module GF256_Multiply (
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] Result // A * B mod m(x)
);

    // Irreducible polynomial constant (0x1B = x^4 + x^3 + x + 1)
    localparam RED_CONST = 8'h1B;
    
    // Prod will store the current term A * x^i
    reg [7:0] Prod;   
    // Red will accumulate the final result
    reg [7:0] Red;    
    integer i;
    
    always @(*) begin
        // The result starts at zero
        Red = 8'h00; 
        
        // Prod starts at the multiplicand A (the term for B[0] * A)
        Prod = A; 
        
        // Loop 8 times, corresponding to the 8 bits of B
        for (i = 0; i < 8; i = i + 1) begin
            
            // Step 1: Accumulate the product if the current bit of B is 1
            if (B[i]) begin
                // If B[i] is 1, XOR the current partial product (A * x^i) into the result
                Red = Red ^ Prod;
            end
            
            // Step 2: Calculate the next partial product: Prod * x
            // This is equivalent to shifting Prod left by one bit.
            
            // Check if the current product's MSB is 1 (will spill over 8 bits)
            if (Prod[7]) begin
                // Shift Prod left (A * x)
                Prod = Prod << 1;
                // Reduce the result by XORing with the reduction polynomial constant 0x1B
                Prod = Prod ^ RED_CONST;
            end else begin
                // Simple shift left (A * x)
                Prod = Prod << 1;
            end
        end
        
        // The final accumulated result
        Result = Red; 
    end
    
endmodule



// Affine Transformation Module (Final part of SubBytes)
module Affine_Transform (
    input [7:0] b_in,     // 8-bit output of the Multiplicative Inverse (b)
    output [7:0] s_out    // 8-bit final SubBytes output (s')
);

    // Constant vector c = 0x63 (01100011)
    localparam C_VECTOR = 8'h63; 
    
    // Decompose input bits for clarity
    // (Ensure you are using the b_in bits correctly)
    wire b0 = b_in[0];
    wire b1 = b_in[1];
    wire b2 = b_in[2];
    wire b3 = b_in[3];
    wire b4 = b_in[4];
    wire b5 = b_in[5];
    wire b6 = b_in[6];
    wire b7 = b_in[7];
    
    // Standard AES Affine Transformation Equations
    assign s_out[0] = b0 ^ b4 ^ b5 ^ b6 ^ b7 ^ C_VECTOR[0]; // s'0
    assign s_out[1] = b0 ^ b1 ^ b5 ^ b6 ^ b7 ^ C_VECTOR[1]; // s'1
    assign s_out[2] = b0 ^ b1 ^ b2 ^ b6 ^ b7 ^ C_VECTOR[2]; // s'2
    assign s_out[3] = b0 ^ b1 ^ b2 ^ b3 ^ b7 ^ C_VECTOR[3]; // s'3
    assign s_out[4] = b0 ^ b1 ^ b2 ^ b3 ^ b4 ^ C_VECTOR[4]; // s'4
    assign s_out[5] = b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ C_VECTOR[5]; // s'5
    assign s_out[6] = b_in[2] ^ b_in[3] ^ b_in[4] ^ b_in[5] ^ b_in[6] ^ C_VECTOR[6]; 
    assign s_out[7] = b_in[2] ^ b_in[3] ^ b_in[4] ^ b_in[5] ^ b_in[6] ^ b_in[7] ^ C_VECTOR[7];



endmodule
