module inst_mem(
    input [31:0] PC,
    input reset,
    output [31:0] Instruction_Code
);
    reg [31:0] Memory [0:1023];
    
    // Endereço de palavra
    wire [31:0] word_addr_full = PC[31:2];
    wire [9:0] word_addr = PC[11:2];

    // Inicialização com programa
    integer i;
    initial begin
        // 7 instruções: lh, sh, sub, or, andi, srl, beq
        // Assembly:                      // Hex:               // Comentário
        Memory[0]  = 32'h03200613;        // addi x12, x0, 50   -> x12 = 50
        Memory[1]  = 32'h00F00693;        // addi x13, x0, 15   -> x13 = 15
        Memory[2]  = 32'h40D60733;        // sub  x14, x12, x13 -> x14 = 50-15 = 35
        Memory[3]  = 32'h00C767B3;        // or   x15, x14, x12 -> x15 = 35|50 = 51
        Memory[4]  = 32'h01F6F813;        // andi x16, x13, 31  -> x16 = 15&31 = 15
        Memory[5]  = 32'h00F01023;        // sh   x15, 0(x0)    -> store halfword x15 no addr 0
        Memory[6]  = 32'h00001883;        // lh   x17, 0(x0)    -> load halfword do addr 0
        Memory[7]  = 32'h00285913;        // srli x18, x16, 2   -> x18 = 15>>2 = 3
        Memory[8]  = 32'h00C60863;        // beq  x12, x12, +8  -> branch (50 == 50? YES)
        Memory[9]  = 32'h0FF00993;        // addi x19, x0, 255  -> shouldn't execute (flush)
        Memory[10] = 32'h00000013;        // nop (branch target)
        Memory[11] = 32'h0000006F;        // jal x0, 0 (infinite loop to end)
        
        // Preenche o resto com NOPs
        for (i = 12; i < 1024; i = i + 1) begin
            Memory[i] = 32'h00000013;
        end
    end

    // Saída assíncrona com proteção contra endereços inválidos
    assign Instruction_Code = (PC[1:0] != 2'b00) ? 32'h00000013 :
                            (word_addr_full >= 1024) ? 32'h00000013 :
                            Memory[word_addr];

endmodule
