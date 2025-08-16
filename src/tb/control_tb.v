// ------------------------------------------------------------------
// Testbench para a Unidade de Controle Principal
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module control_tb;

    // 1. Entradas para a Unidade de Controle
    reg [6:0] opcode_tb;
    reg [2:0] funct3_tb;
    reg [6:0] funct7_tb;

    // 2. Saídas da Unidade de Controle
    wire [1:0] alu_src_a_tb;
    wire [1:0] alu_src_b_tb;
    wire [1:0] mem_to_reg_tb;
    wire [3:0] alu_control_tb;
    wire       regwrite_tb;
    wire       mem_read_tb;
    wire       mem_write_tb;
    wire       branch_tb;

    // 3. Instanciação do Módulo
    control dut (
        .opcode(opcode_tb),
        .funct3(funct3_tb),
        .funct7(funct7_tb),
        .alu_src_a(alu_src_a_tb),
        .alu_src_b(alu_src_b_tb),
        .mem_to_reg(mem_to_reg_tb),
        .alu_control(alu_control_tb),
        .regwrite(regwrite_tb),
        .mem_read(mem_read_tb),
        .mem_write(mem_write_tb),
        .branch(branch_tb)
    );

    // 4. Task de Verificação
    task check_signals(
        input [1:0] exp_alu_src_a, input [1:0] exp_alu_src_b, input [1:0] exp_mem_to_reg,
        input [3:0] exp_alu_control, input exp_regwrite, input exp_mem_read, 
        input exp_mem_write, input exp_branch
    );
        begin
            $display("-------------------------------------------------");
            if (alu_src_a_tb !== exp_alu_src_a) $display("ERRO: alu_src_a = %b, esperado = %b", alu_src_a_tb, exp_alu_src_a);
            if (alu_src_b_tb !== exp_alu_src_b) $display("ERRO: alu_src_b = %b, esperado = %b", alu_src_b_tb, exp_alu_src_b);
            if (mem_to_reg_tb !== exp_mem_to_reg) $display("ERRO: mem_to_reg = %b, esperado = %b", mem_to_reg_tb, exp_mem_to_reg);
            if (alu_control_tb !== exp_alu_control) $display("ERRO: alu_control = %b, esperado = %b", alu_control_tb, exp_alu_control);
            if (regwrite_tb !== exp_regwrite) $display("ERRO: regwrite = %b, esperado = %b", regwrite_tb, exp_regwrite);
            if (mem_read_tb !== exp_mem_read) $display("ERRO: mem_read = %b, esperado = %b", mem_read_tb, exp_mem_read);
            if (mem_write_tb !== exp_mem_write) $display("ERRO: mem_write = %b, esperado = %b", mem_write_tb, exp_mem_write);
            if (branch_tb !== exp_branch) $display("ERRO: branch = %b, esperado = %b", branch_tb, exp_branch);
            $display("Verificacao concluida.");
        end
    endtask

    // 5. Bloco Principal de Estímulos
    initial begin
        $display("=================================================");
        $display("INICIANDO TESTBENCH DA UNIDADE DE CONTROLE");
        $display("=================================================");

        // --- Teste 1: SUB ---
        $display("\n>>> Testando instrucao SUB...");
        opcode_tb = 7'b0110011; funct3_tb = 3'b000; funct7_tb = 7'b0100000;
        #10;
        check_signals(2'b00, 2'b00, 2'b00, 4'b0110, 1, 0, 0, 0);

        // --- Teste 2: OR ---
        $display("\n>>> Testando instrucao OR...");
        opcode_tb = 7'b0110011; funct3_tb = 3'b110; funct7_tb = 7'b0000000;
        #10;
        check_signals(2'b00, 2'b00, 2'b00, 4'b0001, 1, 0, 0, 0);

        // --- Teste 3: SRL ---
        $display("\n>>> Testando instrucao SRL...");
        opcode_tb = 7'b0110011; funct3_tb = 3'b101; funct7_tb = 7'b0000000;
        #10;
        check_signals(2'b00, 2'b00, 2'b00, 4'b1000, 1, 0, 0, 0);

        // --- Teste 4: LH ---
        $display("\n>>> Testando instrucao LH...");
        opcode_tb = 7'b0000011; funct3_tb = 3'b001;
        #10;
        check_signals(2'b00, 2'b01, 2'b01, 4'b0010, 1, 1, 0, 0);

        // --- Teste 5: ANDI ---
        $display("\n>>> Testando instrucao ANDI...");
        opcode_tb = 7'b0010011; funct3_tb = 3'b111;
        #10;
        check_signals(2'b00, 2'b01, 2'b00, 4'b0000, 1, 0, 0, 0);

        // --- Teste 6: SH ---
        $display("\n>>> Testando instrucao SH...");
        opcode_tb = 7'b0100011; funct3_tb = 3'b001;
        #10;
        check_signals(2'b00, 2'b01, 2'b00, 4'b0010, 0, 0, 1, 0);

        // --- Teste 7: BEQ ---
        $display("\n>>> Testando instrucao BEQ...");
        opcode_tb = 7'b1100011; funct3_tb = 3'b000;
        #10;
        check_signals(2'b00, 2'b00, 2'b00, 4'b0110, 0, 0, 0, 1);
        
        // --- Teste 8: Opcode Desconhecido ---
        $display("\n>>> Testando Opcode Desconhecido (Default)...");
        opcode_tb = 7'b1111111; 
        #10;
        check_signals(2'b00, 2'b00, 2'b00, 4'b1111, 0, 0, 0, 0);

        $display("\n=================================================");
        $display("FIM DO TESTBENCH DA UNIDADE DE CONTROLE.");
        $display("=================================================");
        #10 $finish;
    end

endmodule