// alu.v
// Unidade Lógica e Aritmética para o processador RISC-V simplificado.
// Implementa as operações base: AND, OR, ADD, SUB.

module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  ALUControl, // Sinal que define qual operação executar
    output reg [31:0] result,     // Resultado da operação
    output        zero        // Flag que é 1 se o resultado for 0
);

    // Códigos para as operações da ALU (ALUOp)
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;

    // A lógica principal da ALU é implementada com um case.
    // O resultado da operação é armazenado no registrador 'result'.
    always @(*) begin
        case (ALUControl)
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            default: result = 32'hxxxxxxxx; // Valor indefinido para controle não implementado
        endcase
    end

    // A flag 'zero' é 1 se todos os bits do resultado forem 0.
    assign zero = (result == 32'b0);

endmodule