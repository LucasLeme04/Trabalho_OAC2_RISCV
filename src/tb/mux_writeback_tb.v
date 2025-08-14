// ------------------------------------------------------------------
// Testbench para o Mux do estágio Write Back (mux_writeback)
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module mux_writeback_tb;

    // 1. Sinais de Entrada
    reg [31:0] alu_result_tb;
    reg [31:0] mem_data_tb;
    reg [31:0] pc_plus_4_tb;
    reg [31:0] immediate_tb;
    reg [1:0]  mem_to_reg_tb;

    // 2. Sinais de Saída
    wire [31:0] write_data_tb;

    // 3. Instanciação do Módulo (DUT)
    mux_writeback dut (
        .alu_result(alu_result_tb),
        .mem_data(mem_data_tb),
        .pc_plus_4(pc_plus_4_tb),
        .immediate(immediate_tb),
        .mem_to_reg(mem_to_reg_tb),
        .write_data(write_data_tb)
    );

    // 4. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DO MUX_WRITEBACK");
        $display("-------------------------------------------------");

        // Define valores fáceis de identificar para cada entrada de dados
        alu_result_tb = 32'hAAAAAAAA;
        mem_data_tb   = 32'hBBBBBBBB;
        pc_plus_4_tb  = 32'hCCCCCCCC;
        immediate_tb  = 32'hDDDDDDDD;
        
        // --- TESTE 1: Selecionar resultado da ALU (para R-type/I-type) ---
        mem_to_reg_tb = 2'b00;
        #10;
        $display("Controle = 00 (ALU Result) | Esperado: 0x%h | Saída: 0x%h", alu_result_tb, write_data_tb);

        // --- TESTE 2: Selecionar dados da memória (para Load) ---
        mem_to_reg_tb = 2'b01;
        #10;
        $display("Controle = 01 (Memory Data)| Esperado: 0x%h | Saída: 0x%h", mem_data_tb, write_data_tb);
        
        // --- TESTE 3: Selecionar PC+4 (para JAL) ---
        mem_to_reg_tb = 2'b10;
        #10;
        $display("Controle = 10 (PC+4)       | Esperado: 0x%h | Saída: 0x%h", pc_plus_4_tb, write_data_tb);
        
        // --- TESTE 4: Selecionar Imediato (para LUI) ---
        mem_to_reg_tb = 2'b11;
        #10;
        $display("Controle = 11 (Immediate)  | Esperado: 0x%h | Saída: 0x%h", immediate_tb, write_data_tb);

        $display("-------------------------------------------------");
        $display("FIM DO TESTBENCH.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule