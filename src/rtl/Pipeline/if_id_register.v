/*
 * Registro IF/ID do pipeline RISC-V
 * Armazena a instrução e o PC atual entre os estágios IF e ID
 * 
 * Melhorias:
 * - Adicionado sinal de flush para hazards de controle
 * - Saída registrada para melhor timing
 * - Reset assíncrono completo
 */
module if_id_register (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire flush,           // Novo: sinal para limpar o registro (hazards de controle)
    
    input wire [31:0] instruction_in,
    input wire [31:0] pc_in,    // PC atual (não PC+4)

    output reg [31:0] instruction_out,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset assíncrono
            instruction_out <= 32'b0;
            pc_out          <= 32'b0;
        end
        else if (flush) begin
            // Limpa o registro em caso de branch/jump tomado
            instruction_out <= 32'h00000013; // Valor explícito de NOP
            pc_out          <= 32'b0; 
        end
        else if (write_enable) begin
            // Captura normal dos valores
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
        end
        // Se write_enable=0, mantém os valores atuais
    end

endmodule