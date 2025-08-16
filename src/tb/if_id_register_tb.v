// ------------------------------------------------------------------
// Testbench para o Registrador de Pipeline IF/ID
// Verifica os modos: Escrita, Stall (Hold) e Flush.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module if_id_register_tb;

    // 1. Sinais de Controle e Dados
    reg         clk;
    reg         reset;
    reg         write_enable_tb;
    reg         flush_tb;
    reg  [31:0] instruction_in_tb;
    reg  [31:0] pc_in_tb;
    wire [31:0] instruction_out_tb;
    wire [31:0] pc_out_tb;

    // 2. Instanciação do Módulo
    if_id_register dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable_tb),
        .flush(flush_tb),
        .instruction_in(instruction_in_tb),
        .pc_in(pc_in_tb),
        .instruction_out(instruction_out_tb),
        .pc_out(pc_out_tb)
    );

    // 3. Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Bloco de Estímulos e Verificação
    initial begin
        $display("=================================================");
        $display("INICIANDO TESTBENCH DO REGISTRADOR IF/ID");
        $display("=================================================");

        // --- TESTE 1: Reset Assincrono ---
        $display("\n>>> Teste 1: Reset Assincrono");
        reset = 1;
        #10;
        $display("Reset Ativo | Saida PC: 0x%h | Saida Instrucao: 0x%h", pc_out_tb, instruction_out_tb);
        reset = 0;
        @(posedge clk);

        // --- TESTE 2: Escrita Normal ---
        $display("\n>>> Teste 2: Escrita Normal (write_enable = 1)");
        write_enable_tb <= 1;
        flush_tb        <= 0;
        instruction_in_tb <= 32'hAAAAAAAA; // Nova instrucao na entrada
        pc_in_tb          <= 32'h00000004; // Novo PC na entrada
        $display("Ciclo 1: Entradas -> PC=0x4, INST=0xAAAA. Saidas ainda sao as antigas.");
        @(posedge clk); // Borda do clock para capturar os dados
        #1; // Delay para permitir que as saídas atualizem
        $display("Ciclo 2: Saidas atualizadas -> PC: 0x%h, INST: 0x%h", pc_out_tb, instruction_out_tb);

        // --- TESTE 3: Stall ---
        $display("\n>>> Teste 3: Stall/Hold (write_enable = 0)");
        write_enable_tb <= 0; // Desabilita a escrita (stall)
        instruction_in_tb <= 32'hBBBBBBBB; // Novas entradas que devem ser ignoradas
        pc_in_tb          <= 32'h00000008;
        $display("Ciclo 2: Entradas -> PC=0x8, INST=0xBBBB. Saidas ainda sao as antigas.");
        @(posedge clk);
        #1;
        $display("Ciclo 3: Saidas mantiveram o valor (Stall) -> PC: 0x%h, INST: 0x%h", pc_out_tb, instruction_out_tb);

        // --- TESTE 4: Flush ---
        $display("\n>>> Teste 4: Flush (Prioridade sobre write_enable)");
        flush_tb <= 1;
        write_enable_tb <= 1; // Mesmo com write_enable=1, flush deve vencer
        instruction_in_tb <= 32'hCCCCCCCC; // Entradas que serão ignoradas
        pc_in_tb          <= 32'h0000000C;
        $display("Ciclo 3: Entradas -> PC=0xC, INST=0xCCCC. Sinal de FLUSH ativo.");
        @(posedge clk);
        #1;
        $display("Ciclo 4: Saidas foram limpas (Flush) -> PC: 0x%h, INST: 0x%h (NOP)", pc_out_tb, instruction_out_tb);
        
        $display("\n=================================================");
        $display("FIM DO TESTBENCH.");
        $display("=================================================");
        #10 $finish;
    end

endmodule