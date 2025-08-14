/*
 * Multiplexador para o primeiro operando da ALU
 * Seleciona entre:
 * 0: Dados do banco de registradores (para operações normais)
 * 1: Valor do PC (para cálculo de endereço de branch)
 * 2: Valor zero (para operações com imediato como primeiro operando)
 */
module mux_alu_a (
    input [31:0] reg_data,      // Dados do registrador (read_data1)
    input [31:0] pc_current,    // Valor atual do PC
    input [1:0] alu_src_a,      // Controle expandido para 2 bits
    output reg [31:0] alu_input_a
);

    always @(*) begin
        case (alu_src_a)
            2'b00: alu_input_a = reg_data;    // Uso normal (registrador)
            2'b01: alu_input_a = pc_current;  // Cálculo de branch/jump
            2'b10: alu_input_a = 32'b0;       // Para certas operações com imediato
            default: alu_input_a = reg_data;   // Caso padrão
        endcase
    end

endmodule
