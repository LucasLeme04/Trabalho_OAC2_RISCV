module inst_mem(
    input [31:0] PC,
    input reset,
    output [31:0] Instruction_Code
);
    reg [7:0] Memory [31:0];

    assign Instruction_Code = {Memory[PC+3], Memory[PC+2], Memory[PC+1], Memory[PC]};

    // Initialize memory on reset
    always @(reset) begin
        if (reset == 1) begin
            // lh x1, 4(x2) => 0x00411083
            Memory[3] = 8'h00;
            Memory[2] = 8'h41;
            Memory[1] = 8'h10;
            Memory[0] = 8'h83;

            // sh x3, 8(x4) => 0x00322423
            Memory[7] = 8'h00;
            Memory[6] = 8'h32;
            Memory[5] = 8'h24;
            Memory[4] = 8'h23;

            // sub x5, x6, x7 => 0x407302b3
            Memory[11] = 8'h40;
            Memory[10] = 8'h73;
            Memory[9] = 8'h02;
            Memory[8] = 8'hb3;

            // or x8, x9, x10 => 0x00a4e433
            Memory[15] = 8'h00;
            Memory[14] = 8'ha4;
            Memory[13] = 8'he4;
            Memory[12] = 8'h33;

            // andi x11, x12, 0xFF => 0x0ff67593
            Memory[19] = 8'h0f;
            Memory[18] = 8'hf6;
            Memory[17] = 8'h75;
            Memory[16] = 8'h93;

            // srl x13, x14, x15 => 0x00f755b3
            Memory[23] = 8'h00;
            Memory[22] = 8'hf7;
            Memory[21] = 8'h55;
            Memory[20] = 8'hb3;

            // beq x16, x17, LABEL (offset = 16) => 0x01180863
            Memory[27] = 8'h01;
            Memory[26] = 8'h18;
            Memory[25] = 8'h08;
            Memory[24] = 8'h63;
        end
    end
endmodule