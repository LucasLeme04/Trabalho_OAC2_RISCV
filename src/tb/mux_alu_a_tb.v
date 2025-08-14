// ------------------------------------------------------------------
// Testbench para o Mux da primeira entrada da ALU (mux_alu_a)
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module mux_alu_a_tb;

    // 1. Sinais de Entrada
    reg [31:0] reg_data_tb;
    reg [31:0] pc_current_tb;
    reg [1:0]  alu_src_a_tb;

    // 2. Sinais de Saída
    wire [31:0] alu_input_a_tb;

    // 3. Instanciação do Módulo (DUT)
    mux_alu_a dut (
        .reg_data(reg_data_tb),
        .pc_current(pc_current_tb),
        .alu_src_a(alu_src_a_tb),
        .alu_input_a(alu_input_a_tb)
    );

    // 4. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DO MUX_ALU_A");
        $display("-------------------------------------------------");

        // Define valores fáceis de identificar para as entradas
        reg_data_tb   = 32'hAAAAAAAA;
        pc_current_tb = 32'hBBBBBBBB;
        
        // --- TESTE 1: Selecionar dados do registrador (controle = 00) ---
        alu_src_a_tb = 2'b00;
        #10; // Delay para propagação
        $display("Controle = 00 | Esperado: 0x%h | Saida: 0x%h", reg_data_tb, alu_input_a_tb);

        // --- TESTE 2: Selecionar valor do PC (controle = 01) ---
        alu_src_a_tb = 2'b01;
        #10;
        $display("Controle = 01 | Esperado: 0x%h | Saida: 0x%h", pc_current_tb, alu_input_a_tb);
        
        // --- TESTE 3: Selecionar valor ZERO (controle = 10) ---
        alu_src_a_tb = 2'b10;
        #10;
        $display("Controle = 10 | Esperado: 0x%h | Saida: 0x%h", 32'h00000000, alu_input_a_tb);
        
        // --- TESTE 4: Teste do caso DEFAULT (controle = 11) ---
        alu_src_a_tb = 2'b11;
        #10;
        $display("Controle = 11 (default) | Esperado: 0x%h | Saida: 0x%h", reg_data_tb, alu_input_a_tb);

        $display("-------------------------------------------------");
        $display("FIM DO TESTBENCH.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule