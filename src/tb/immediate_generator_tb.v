// ------------------------------------------------------------------
// Testbench para o Gerador de Imediatos (Immediate Generator)
// Foco: Formatos I-type, S-type e B-type para o Grupo 9
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module imm_gen_tb;

    // 1. Sinais de Entrada e Saída
    reg  [31:0] instruction_tb;
    wire [31:0] imm_out_tb;

    // 2. Instanciação do Módulo (DUT)
    immediate_generator dut (
        .instruction(instruction_tb),
        .imm_out(imm_out_tb)
    );

    // 3. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DO GERADOR DE IMEDIATOS");
        $display("-------------------------------------------------");

        // --- TESTE 1: lh (I-type, load halfword) ---
        // lh x10, -20(x5) -> imm = -20 (0xFFFFFFEC)
        // imm[11:0] = 1111 1110 1100
        // instruction = {imm[11:0], rs1, funct3, rd, opcode}
        // instruction = {111111101100, 00101, 001, 01010, 0000011} 
        instruction_tb = 32'b11111110110000101001010100000011;
        #10;
        $display("Teste LH (-20): Esperado: %d (0x%h). Recebido: %d (0x%h)", -20, -20, $signed(imm_out_tb), $signed(imm_out_tb));

        // --- TESTE 2: sh (S-type, store halfword) ---
        // sh x10, 40(x5) -> imm = 40 (0x28 = 101000)
        // imm[11:5] = 0000001, imm[4:0] = 01000
        // instruction = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode}
        // instruction = {0000001, 01010, 00101, 001, 01000, 0100011}
        instruction_tb = 32'b00000010101000101001010000100011;
        #10;
        $display("Teste SH (40): Esperado: %d (0x%h). Recebido: %d (0x%h)", 40, 40, $signed(imm_out_tb), $signed(imm_out_tb));

        // --- TESTE 3: andi (I-type, AND immediate) ---
        // andi x10, x5, 255 -> imm = 255 (0xFF), com zero-extend (pela sua lógica)
        // imm[11:0] = 0000 1111 1111
        // instruction = {imm[11:0], rs1, funct3, rd, opcode}
        // instruction = {000011111111, 00101, 111, 01010, 0010011}
        instruction_tb = 32'b00001111111100101111010100010011;
        #10;
        $display("Teste ANDI (255): Esperado: %d (0x%h). Recebido: %d (0x%h)", 255, 255, $signed(imm_out_tb), $signed(imm_out_tb));
        
        // --- TESTE 4: beq (B-type, branch if equal) ---
        // beq x1, x2, -16 -> imm = -16 (0xFFFFFFF0)  
        // -16 = 1111111110000 (13 bits em complemento de 2)
        // imm[12]=1, imm[11]=1, imm[10:5]=111111, imm[4:1]=1000, imm[0]=0
        // Formato B-type: {imm[12], imm[10:5], rs2, rs1, 000, imm[4:1], imm[11], 1100011}
        // instruction = {1, 111111, 00010, 00001, 000, 1000, 1, 1100011}
        instruction_tb = 32'b11111110001000001000100011100011;
        #1;
        $display("Teste BEQ (-16): Esperado: %d (0x%h). Recebido: %d (0x%h)", -16, -16, $signed(imm_out_tb), $signed(imm_out_tb));        $display("-------------------------------------------------");
        $display("FIM DO TESTBENCH DO GERADOR DE IMEDIATOS.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule