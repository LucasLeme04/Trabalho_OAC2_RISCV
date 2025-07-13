// alu_tb.v
// Testbench para a Unidade Lógica e Aritmética (ALU).

`timescale 1ns/1ps

module alu_tb;

    // Entradas para a ALU
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  ALUControl;

    // Saídas da ALU
    wire [31:0] result;
    wire        zero;
    
    // Códigos para as operações da ALU (para facilitar a leitura do teste)
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;

    // Instancia a Unidade sob Teste (Unit Under Test - UUT)
    alu uut (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .result(result),
        .zero(zero)
    );
    
    // Bloco de estímulos de teste
    initial begin
        $display("Iniciando teste da ALU...");

        // --- Teste 1: ADD ---
        a = 32'd10; b = 32'd5; ALUControl = ALU_ADD; #10;
        $display("ADD : %d + %d = %d (Zero: %b)", a, b, result, zero);

        // --- Teste 2: SUB ---
        a = 32'd10; b = 32'd5; ALUControl = ALU_SUB; #10;
        $display("SUB : %d - %d = %d (Zero: %b)", a, b, result, zero);
        
        // --- Teste 3: SUB com resultado 0 ---
        a = 32'd7; b = 32'd7; ALUControl = ALU_SUB; #10;
        $display("SUB : %d - %d = %d (Zero: %b) <- Testando flag 'zero'", a, b, result, zero);
        
        // --- Teste 4: AND ---
        a = 32'h0000FFFF; b = 32'hFFFF0000; ALUControl = ALU_AND; #10;
        $display("AND : 0x%h & 0x%h = 0x%h (Zero: %b)", a, b, result, zero);

        // --- Teste 5: OR ---
        a = 32'h0000FFFF; b = 32'hFFFF0000; ALUControl = ALU_OR; #10;
        $display("OR  : 0x%h | 0x%h = 0x%h (Zero: %b)", a, b, result, zero);
        
        // --- Teste 6: SUB com resultado negativo ---
        a = 32'd20; b = 32'd30; ALUControl = ALU_SUB; #10;
        $display("SUB : %d - %d = %d (decimal) / %h (hex) (Zero: %b)", a, b, result, result, zero);

        $display("Fim dos testes.");
        $finish;
    end

endmodule