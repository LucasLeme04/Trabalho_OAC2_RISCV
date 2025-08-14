// ------------------------------------------------------------------
// Testbench para o Registrador de Pipeline ID/EX
// Verifica a captura de dados e o flush.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module id_ex_register_tb;

    // 1. Sinais de Controle e Dados (Entradas)
    reg         clk;
    reg         reset;
    reg         flush_tb;
    reg         regwrite_in_tb;
    reg         mem_read_in_tb;
    reg         mem_write_in_tb;
    reg         branch_in_tb;
    reg  [1:0]  alu_src_a_in_tb;
    reg  [1:0]  alu_src_b_in_tb;
    reg  [1:0]  mem_to_reg_in_tb;
    reg  [3:0]  alu_control_in_tb;
    reg  [31:0] read_data1_in_tb;
    reg  [31:0] read_data2_in_tb;
    reg  [31:0] pc_in_tb;
    reg  [31:0] immediate_in_tb;
    reg  [4:0]  rs1_in_tb, rs2_in_tb, rd_in_tb;
    
    // 2. Sinais de Saída
    wire        regwrite_out_tb;
    wire        mem_read_out_tb;
    wire        mem_write_out_tb;
    wire        branch_out_tb;
    wire [1:0]  alu_src_a_out_tb;
    wire [1:0]  alu_src_b_out_tb;
    wire [1:0]  mem_to_reg_out_tb;
    wire [3:0]  alu_control_out_tb;
    wire [31:0] read_data1_out_tb;
    wire [31:0] read_data2_out_tb;
    wire [31:0] pc_out_tb;
    wire [31:0] immediate_out_tb;
    wire [4:0]  rs1_out_tb, rs2_out_tb, rd_out_tb;

    // 3. Instanciação do DUT
    id_ex_register dut (
        .clk(clk),
        .reset(reset),
        .flush(flush_tb),
        .regwrite_in(regwrite_in_tb),
        .mem_read_in(mem_read_in_tb),
        .mem_write_in(mem_write_in_tb),
        .branch_in(branch_in_tb),
        .alu_src_a_in(alu_src_a_in_tb),
        .alu_src_b_in(alu_src_b_in_tb),
        .mem_to_reg_in(mem_to_reg_in_tb),
        .alu_control_in(alu_control_in_tb),
        .read_data1_in(read_data1_in_tb),
        .read_data2_in(read_data2_in_tb),
        .pc_in(pc_in_tb),
        .immediate_in(immediate_in_tb),
        .rs1_in(rs1_in_tb),
        .rs2_in(rs2_in_tb),
        .rd_in(rd_in_tb),
        .regwrite_out(regwrite_out_tb),
        .mem_read_out(mem_read_out_tb),
        .mem_write_out(mem_write_out_tb),
        .branch_out(branch_out_tb),
        .alu_src_a_out(alu_src_a_out_tb),
        .alu_src_b_out(alu_src_b_out_tb),
        .mem_to_reg_out(mem_to_reg_out_tb),
        .alu_control_out(alu_control_out_tb),
        .read_data1_out(read_data1_out_tb),
        .read_data2_out(read_data2_out_tb),
        .pc_out(pc_out_tb),
        .immediate_out(immediate_out_tb),
        .rs1_out(rs1_out_tb),
        .rs2_out(rs2_out_tb),
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
        $display("INICIANDO TESTBENCH DO REGISTRADOR ID/EX");
        $display("=================================================");
        
        // --- TESTE 1: Reset Assincrono ---
        $display("\n>>> Teste 1: Reset Assincrono");
        reset = 1;
        #10;
        $display("Reset Ativo | Saida RegWrite: %b", regwrite_out_tb);
        reset = 0;
        @(posedge clk);
        
        // --- TESTE 2: Captura Normal de Dados ---
        $display("\n>>> Teste 2: Captura Normal de Dados");
        flush_tb <= 0;
        // Simula os sinais para uma instrução 'lh x5, -16(x1)'
        regwrite_in_tb <= 1; mem_read_in_tb <= 1; mem_write_in_tb <= 0; branch_in_tb <= 0;
        alu_src_a_in_tb <= 2'b00; alu_src_b_in_tb <= 2'b01; mem_to_reg_in_tb <= 2'b01; alu_control_in_tb <= 4'b0010; // ADD
        read_data1_in_tb <= 32'hAAAAAAAA; // Valor de x1
        pc_in_tb <= 32'h00000100; immediate_in_tb <= 32'hFFFFFFF0; // -16
        rd_in_tb <= 5'd5;
        $display("Ciclo 1: Entradas configuradas para uma instrucao LH.");
        @(posedge clk);
        #1;
        $display("Ciclo 2: Verificando saidas capturadas...");
        $display("  - RegWrite: %b, MemRead: %b, Branch: %b", regwrite_out_tb, mem_read_out_tb, branch_out_tb);
        $display("  - ALUControl: %b", alu_control_out_tb);
        $display("  - PC: 0x%h, Immediate: 0x%h", pc_out_tb, immediate_out_tb);
        $display("  - Dest Reg (rd): %d", rd_out_tb);
        
        // --- TESTE 3: Flush ---
        $display("\n>>> Teste 3: Flush (Limpando o pipeline)");
        flush_tb <= 1;
        // As entradas continuam com os valores de LH, mas devem ser ignoradas
        $display("Ciclo 2: Sinal de FLUSH ativo.");
        @(posedge clk);
        #1;
        $display("Ciclo 3: Verificando saidas (devem estar zeradas/NOP)...");
        $display("  - RegWrite: %b, MemRead: %b, Branch: %b", regwrite_out_tb, mem_read_out_tb, branch_out_tb);
        $display("  - ALUControl: %h (NOP)", alu_control_out_tb);
        $display("  - PC: 0x%h, Immediate: 0x%h", pc_out_tb, immediate_out_tb);
        
        $display("\n=================================================");
        $display("FIM DO TESTBENCH.");
        $display("=================================================");
        #10 $finish;
    end

endmodule