// ------------------------------------------------------------------
// Testbench para o Registrador de Pipeline MEM/WB
// Verifica a captura de dados para diferentes instruções e o flush.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module mem_wb_register_tb;

    // 1. Sinais de Controle e Dados (Entradas)
    reg         clk;
    reg         reset;
    reg         flush_tb;
    reg         regwrite_in_tb;
    reg  [1:0]  mem_to_reg_in_tb;
    reg  [31:0] mem_read_data_in_tb;
    reg  [31:0] alu_result_in_tb;
    reg  [31:0] pc_plus_4_in_tb;
    reg  [4:0]  rd_in_tb;
    
    // 2. Sinais de Saída
    wire        regwrite_out_tb;
    wire [1:0]  mem_to_reg_out_tb;
    wire [31:0] mem_read_data_out_tb;
    wire [31:0] alu_result_out_tb;
    wire [31:0] pc_plus_4_out_tb;
    wire [4:0]  rd_out_tb;

    // 3. Instanciação do DUT
    mem_wb_register dut (
        .clk(clk),
        .reset(reset),
        .flush(flush_tb),
        .regwrite_in(regwrite_in_tb),
        .mem_to_reg_in(mem_to_reg_in_tb),
        .mem_read_data_in(mem_read_data_in_tb),
        .alu_result_in(alu_result_in_tb),
        .pc_plus_4_in(pc_plus_4_in_tb),
        .rd_in(rd_in_tb),
        .regwrite_out(regwrite_out_tb),
        .mem_to_reg_out(mem_to_reg_out_tb),
        .mem_read_data_out(mem_read_data_out_tb),
        .alu_result_out(alu_result_out_tb),
        .pc_plus_4_out(pc_plus_4_out_tb),
        .rd_out(rd_out_tb)
    );

    // 4. Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 5. Bloco de Estímulos e Verificação
    initial begin
        $display("=================================================");
        $display("INICIANDO TESTBENCH DO REGISTRADOR MEM/WB");
        $display("=================================================");
        
        // --- TESTE 1: Reset Assincrono ---
        $display("\n>>> Teste 1: Reset Assincrono");
        reset = 1;
        #10;
        $display("Reset Ativo | Saida RegWrite: %b", regwrite_out_tb);
        reset = 0;
        @(posedge clk);
        
        // --- TESTE 2: Simulação de uma instrução LH ---
        $display("\n>>> Teste 2: Captura do resultado de um LH");
        flush_tb <= 0;
        // Sinais vindos do estagio MEM para uma instrucao LH bem-sucedida
        regwrite_in_tb <= 1;
        mem_to_reg_in_tb <= 2'b01; // Seleciona dados da memoria
        mem_read_data_in_tb <= 32'h00001234; // Dado lido da memoria
        alu_result_in_tb <= 32'h00000008; // Endereco calculado pela ALU
        rd_in_tb <= 5'd5; // Destino é x5
        $display("Ciclo 1: Entradas configuradas para o resultado de um LH.");
        @(posedge clk);
        #1;
        $display("Ciclo 2: Verificando saidas capturadas...");
        $display("  - RegWrite: %b, MemToReg: %b", regwrite_out_tb, mem_to_reg_out_tb);
        $display("  - Read Data: 0x%h, ALU Result: 0x%h, Dest Reg: %d", mem_read_data_out_tb, alu_result_out_tb, rd_out_tb);

        // --- TESTE 3: Simulação de uma instrução SUB ---
        $display("\n>>> Teste 3: Captura do resultado de um SUB");
        flush_tb <= 0;
        regwrite_in_tb <= 1;
        mem_to_reg_in_tb <= 2'b00; // Seleciona resultado da ALU
        mem_read_data_in_tb <= 32'hXXXXXXXX; // Dado da memoria (nao importa)
        alu_result_in_tb <= 32'hFFFFFFFF; // Resultado da subtracao (-1)
        rd_in_tb <= 5'd6; // Destino e x6
        $display("Ciclo 2: Entradas configuradas para o resultado de um SUB.");
        @(posedge clk);
        #1;
        $display("Ciclo 3: Verificando saidas capturadas...");
        $display("  - RegWrite: %b, MemToReg: %b", regwrite_out_tb, mem_to_reg_out_tb);
        $display("  - Read Data: 0x%h, ALU Result: 0x%h, Dest Reg: %d", mem_read_data_out_tb, alu_result_out_tb, rd_out_tb);
        
        $display("\n=================================================");
        $display("FIM DO TESTBENCH.");
        $display("=================================================");
        #10 $finish;
    end

endmodule