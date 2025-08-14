// ------------------------------------------------------------------
// Testbench para a Unidade Lógica e Aritmética (ALU)
// Foco: Operações para o Grupo 9 (sub, or, andi, srl, beq) + add
// ------------------------------------------------------------------

`timescale 1ns / 1ps // Define a escala de tempo da simulação

module alu_tb;

    // 1. Sinais de Entrada para a ALU (declarados como 'reg')
    reg  [31:0] in1_tb, in2_tb;
    reg  [3:0]  alu_control_tb;

    // 2. Sinais de Saída da ALU (declarados como 'wire')
    wire [31:0] alu_result_tb;
    wire        zero_flag_tb;

    // 3. Parâmetros para facilitar a leitura dos testes (códigos de controle da ALU)
    parameter ALU_AND = 4'b0000;
    parameter ALU_OR  = 4'b0001;
    parameter ALU_ADD = 4'b0010;
    parameter ALU_SUB = 4'b0110;
    parameter ALU_SRL = 4'b1000;

    // 4. Instanciação do Módulo da ALU (DUT - Design Under Test)
    // Conecta os sinais do testbench às portas do módulo da ALU
    ALU dut (
        .in1(in1_tb),
        .in2(in2_tb),
        .alu_control(alu_control_tb),
        .alu_result(alu_result_tb),
        .zero_flag(zero_flag_tb)
    );

    // 5. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DA ALU PARA O GRUPO 9");
        $display("-------------------------------------------------");

        // --- TESTE 1: SUB (para a instrução 'sub') ---
        in1_tb = 32'd10;         // 10
        in2_tb = 32'd7;          // 7
        alu_control_tb = ALU_SUB;
        #10; // Espera 10 unidades de tempo para os sinais propagarem
        $display("Teste SUB: 10 - 7 = %d. Resultado da ALU: %d", (in1_tb - in2_tb), alu_result_tb);
        
        // --- TESTE 2: OR (para a instrução 'or') ---
        in1_tb = 32'h0000_FFFF;  // 0...01...1
        in2_tb = 32'hFFFF_0000;  // 1...10...0
        alu_control_tb = ALU_OR;
        #10;
        $display("Teste OR: 0x%h | 0x%h = 0x%h. Resultado da ALU: 0x%h", in1_tb, in2_tb, (in1_tb | in2_tb), alu_result_tb);

        // --- TESTE 3: AND (para a instrução 'andi') ---
        in1_tb = 32'b1100;       // 12
        in2_tb = 32'b1010;       // 10 (simulando um imediato)
        alu_control_tb = ALU_AND;
        #10;
        $display("Teste AND: %b & %b = %b. Resultado da ALU: %b", in1_tb, in2_tb, (in1_tb & in2_tb), alu_result_tb);
        
        // --- TESTE 4: SRL (para a instrução 'srl') ---
        in1_tb = 32'h80000000;   // 1000...0
        in2_tb = 32'd2;          // Deslocar 2 bits
        alu_control_tb = ALU_SRL;
        #10;
        $display("Teste SRL: 0x%h >> 2 = 0x%h. Resultado da ALU: 0x%h", in1_tb, (in1_tb >> 2), alu_result_tb);

        // --- TESTE 5: BEQ (caso em que o desvio OCORRE) ---
        // A instrução BEQ usa SUB e verifica a 'zero_flag'
        in1_tb = 32'd50;
        in2_tb = 32'd50;
        alu_control_tb = ALU_SUB;
        #10;
        $display("Teste BEQ (iguais): 50 - 50. Flag Zero Esperada: 1. Flag Zero da ALU: %b", zero_flag_tb);

        // --- TESTE 6: BEQ (caso em que o desvio NÃO OCORRE) ---
        in1_tb = 32'd50;
        in2_tb = 32'd49;
        alu_control_tb = ALU_SUB;
        #10;
        $display("Teste BEQ (diferentes): 50 - 49. Flag Zero Esperada: 0. Flag Zero da ALU: %b", zero_flag_tb);

        // --- TESTE 7: ADD (para cálculo de endereço de 'lh' e 'sh') ---
        in1_tb = 32'd1000;       // Endereço base de um registrador
        in2_tb = 32'd4;          // Deslocamento (offset)
        alu_control_tb = ALU_ADD;
        #10;
        $display("Teste ADD: 1000 + 4 = %d. Resultado da ALU: %d", (in1_tb + in2_tb), alu_result_tb);

        $display("-------------------------------------------------");
        $display("FIM DO TESTBENCH DA ALU.");
        $display("-------------------------------------------------");
        #10 $finish; // Termina a simulação
    end

endmodule