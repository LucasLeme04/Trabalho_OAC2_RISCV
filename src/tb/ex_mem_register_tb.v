// ------------------------------------------------------------------
// Testbench para o Registrador de Pipeline EX/MEM
// Verifica a captura de dados e o flush.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module ex_mem_register_tb;

    // 1. Sinais de Controle e Dados (Entradas)
    reg         clk;
    reg         reset;
    reg         flush_tb;
    reg         regwrite_in_tb;
    reg         mem_read_in_tb;
    reg         mem_write_in_tb;
    reg  [1:0]  mem_to_reg_in_tb;
    reg         branch_in_tb;
    reg  [31:0] alu_result_in_tb;
    reg  [31:0] branch_target_in_tb;
    reg  [31:0] write_data_in_tb;
    reg  [4:0]  rd_in_tb;
    reg         zero_flag_in_tb;
    
    // 2. Sinais de Saída
    wire        regwrite_out_tb;
    wire        mem_read_out_tb;
    wire        mem_write_out_tb;
    wire [1:0]  mem_to_reg_out_tb;
    wire        branch_out_tb;
    wire [31:0] alu_result_out_tb;
    wire [31:0] branch_target_out_tb;
    wire [31:0] write_data_out_tb;
    wire [4:0]  rd_out_tb;
    wire        zero_flag_out_tb;

    // 3. Instanciação do DUT
    ex_mem_register dut (
        .clk(clk),
        .reset(reset),
        .flush(flush_tb),
        .regwrite_in(regwrite_in_tb),
        .mem_read_in(mem_read_in_tb),
        .mem_write_in(mem_write_in_tb),
        .mem_to_reg_in(mem_to_reg_in_tb),
        .branch_in(branch_in_tb),
        .alu_result_in(alu_result_in_tb),
        .branch_target_in(branch_target_in_tb),
        .write_data_in(write_data_in_tb),
        .rd_in(rd_in_tb),
        .zero_flag_in(zero_flag_in_tb),
        .regwrite_out(regwrite_out_tb),
        .mem_read_out(mem_read_out_tb),
        .mem_write_out(mem_write_out_tb),
        .mem_to_reg_out(mem_to_reg_out_tb),
        .branch_out(branch_out_tb),
        .alu_result_out(alu_result_out_tb),
        .branch_target_out(branch_target_out_tb),
        .write_data_out(write_data_out_tb),
        .rd_out(rd_out_tb),
        .zero_flag_out(zero_flag_out_tb)
    );

    // 4. Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 5. Bloco de Estímulos e Verificação
    initial begin
        $display("=================================================");
        $display("INICIANDO TESTBENCH DO REGISTRADOR EX/MEM");
        $display("=================================================");
        
        // --- TESTE 1: Reset Assincrono ---
        $display("\n>>> Teste 1: Reset Assincrono");
        reset = 1;
        #10;
        $display("Reset Ativo | Saida RegWrite: %b, Saida Branch: %b", regwrite_out_tb, branch_out_tb);
        reset = 0;
        @(posedge clk);
        
        // --- TESTE 2: Captura Normal de Dados ---
        $display("\n>>> Teste 2: Captura Normal de Dados");
        flush_tb <= 0;
        // Simula os resultados de uma instrução 'beq' que foi tomada
        regwrite_in_tb <= 0; mem_read_in_tb <= 0; mem_write_in_tb <= 0; branch_in_tb <= 1;
        mem_to_reg_in_tb <= 2'b00;
        alu_result_in_tb <= 32'b0; // Resultado de rs1-rs2
        branch_target_in_tb <= 32'h00000FF0; // Endereco do desvio
        write_data_in_tb <= 32'hCCCCCCCC; // Conteudo de rs2
        rd_in_tb <= 5'b0; // Nao usado por beq
        zero_flag_in_tb <= 1; // 'beq' foi bem-sucedido
        $display("Ciclo 1: Entradas configuradas para o resultado de um BEQ bem-sucedido.");
        @(posedge clk);
        #1;
        $display("Ciclo 2: Verificando saidas capturadas...");
        $display("  - Branch: %b, Zero Flag: %b", branch_out_tb, zero_flag_out_tb);
        $display("  - ALU Result: 0x%h", alu_result_out_tb);
        $display("  - Branch Target: 0x%h", branch_target_out_tb);
        
        // --- TESTE 3: Flush ---
        $display("\n>>> Teste 3: Flush (Limpando o pipeline)");
        flush_tb <= 1;
        $display("Ciclo 2: Sinal de FLUSH ativo.");
        @(posedge clk);
        #1;
        $display("Ciclo 3: Verificando saidas (devem estar zeradas)...");
        $display("  - Branch: %b, Zero Flag: %b", branch_out_tb, zero_flag_out_tb);
        $display("  - ALU Result: 0x%h", alu_result_out_tb);
        
        $display("\n=================================================");
        $display("FIM DO TESTBENCH.");
        $display("=================================================");
        #10 $finish;
    end

endmodule