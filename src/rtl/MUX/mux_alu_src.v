/*
 * Multiplexador para o segundo operando da ALU
 * Seleciona entre:
 * 0: Dados do banco de registradores (para operações R-type)
 * 1: Valor imediato (para operações I-type e S-type)
 * 2: Constante 4 (para cálculo de PC+4 em jumps)
 */
module mux_alu_src (
    input [31:0] reg_data,      // Dados do registrador (read_data2)
    input [31:0] immediate,     // Valor imediato estendido
    input [1:0] alu_src_b,      // Sinal de controle expandido
    output reg [31:0] alu_input_b
);

    always @(*) begin
        case (alu_src_b)
            2'b00: alu_input_b = reg_data;    // Operações R-type (sub, or, srl)
            2'b01: alu_input_b = immediate;   // Operações I-type (andi) e S-type (sh)
            2'b10: alu_input_b = 32'd4;       // Para cálculo de PC+4 (jumps)
            default: alu_input_b = reg_data;  // Caso padrão (seguro)
        endcase
    end

endmodule
