/*
 * Multiplexador para o estágio Write Back
 * Seleciona entre:
 * 00: Resultado da ALU (para operações aritméticas/lógicas)
 * 01: Dados da memória (para instruções load)
 * 10: PC + 4 (para instruções de jump and link - futuro)
 * 11: Imediato (para futuras instruções LUI/AUIPC)
 */
module mux_writeback (
    input [31:0] alu_result,    // Resultado da ALU
    input [31:0] mem_data,      // Dados lidos da memória
    input [31:0] pc_plus_4,     // PC + 4 (para JAL)
    input [31:0] immediate,     // Valor imediato (para LUI/AUIPC)
    input [1:0] mem_to_reg,     // Sinal de controle expandido
    output reg [31:0] write_data // Dados para escrever no registrador
);

    always @(*) begin
        case (mem_to_reg)
            2'b00: write_data = alu_result;  // Operações R-type e I-type (sub, or, andi, srl)
            2'b01: write_data = mem_data;    // Load (lh)
            2'b10: write_data = pc_plus_4;   // Para JAL (futuro)
            2'b11: write_data = immediate;   // Para LUI/AUIPC (futuro)
            default: write_data = alu_result; // Caso padrão seguro
        endcase
    end

endmodule
