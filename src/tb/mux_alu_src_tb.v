// ------------------------------------------------------------------
// Testbench para o Mux da segunda entrada da ALU (mux_alu_src)
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module mux_alu_src_tb;

    // 1. Sinais de Entrada
    reg [31:0] reg_data_tb;
    reg [31:0] immediate_tb;
    reg [1:0]  alu_src_b_tb;

    // 2. Sinais de Saída
    wire [31:0] alu_input_b_tb;

    // 3. Instanciação do Módulo (DUT)
    mux_alu_src dut (
        .reg_data(reg_data_tb),
        .immediate(immediate_tb),
        .alu_src_b(alu_src_b_tb),
        .alu_input_b(alu_input_b_tb)
    );

    // 4. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DO MUX_ALU_SRC");
        $display("-------------------------------------------------");

        // Define valores fáceis de identificar para as entradas
        reg_data_tb  = 32'hAAAAAAAA;
        immediate_tb = 32'hDDDDDDDD;
        
        // --- TESTE 1: Selecionar dados do registrador (para R-type) ---
        alu_src_b_tb = 2'b00;
        #10;
        $display("Controle = 00 (Reg Data)   | Esperado: 0x%h | Saída: 0x%h", reg_data_tb, alu_input_b_tb);

        // --- TESTE 2: Selecionar valor imediato (para I-type/S-type) ---
        alu_src_b_tb = 2'b01;
        #10;
        $display("Controle = 01 (Immediate)  | Esperado: 0x%h | Saída: 0x%h", immediate_tb, alu_input_b_tb);
        
        // --- TESTE 3: Selecionar constante 4 (para PC+4) ---
        alu_src_b_tb = 2'b10;
        #10;
        $display("Controle = 10 (Constant 4) | Esperado: 0x%h | Saída: 0x%h", 32'd4, alu_input_b_tb);
        
        // --- TESTE 4: Teste do caso DEFAULT ---
        alu_src_b_tb = 2'b11;
        #10;
        $display("Controle = 11 (Default)    | Esperado: 0x%h | Saída: 0x%h", reg_data_tb, alu_input_b_tb);

        $display("-------------------------------------------------");
        $display("FIM DO TESTBENCH.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule