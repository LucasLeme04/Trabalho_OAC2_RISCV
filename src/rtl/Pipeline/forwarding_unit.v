/*
 * Forwarding Unit para o pipeline RISC-V
 * Resolve hazards RAW (Read After Write) por encaminhamento de dados
 * 
 * Funcionamento:
 * - Verifica se os registradores fonte da instrução em EX foram alterados por instruções
 *   em MEM ou WB que ainda não foram escritas no banco de registradores
 * - Prioriza dados mais recentes (MEM sobre WB)
 */
module forwarding_unit (
    // Registradores fonte da instrução em EX
    input [4:0] rs1_ex,        // Primeiro operando
    input [4:0] rs2_ex,        // Segundo operando
    
    // Informações das instruções em MEM e WB
    input [4:0] rd_mem,        // Registrador destino em MEM
    input       regwrite_mem,   // Sinal de escrita em MEM
    input [4:0] rd_wb,         // Registrador destino em WB
    input       regwrite_wb,    // Sinal de escrita em WB
    
    // Sinais de controle de forwarding
    output reg [1:0] forward_a, // Controle para operando A
    output reg [1:0] forward_b  // Controle para operando B
);

    always @(*) begin
        // Valores padrão: sem forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // Forwarding do estágio MEM (prioridade máxima)
        if (regwrite_mem && (rd_mem != 0)) begin
            if (rd_mem == rs1_ex)
                forward_a = 2'b10; // Encaminha do estágio MEM
            if (rd_mem == rs2_ex)
                forward_b = 2'b10; // Encaminha do estágio MEM
        end
        
        // Forwarding do estágio WB (prioridade menor)
        if (regwrite_wb && (rd_wb != 0)) begin
            if ((rd_wb == rs1_ex) && !(regwrite_mem && (rd_mem == rs1_ex) && (rd_mem != 0)))
                forward_a = 2'b01; // Encaminha do estágio WB
            if ((rd_wb == rs2_ex) && !(regwrite_mem && (rd_mem == rs2_ex) && (rd_mem != 0)))
                forward_b = 2'b01; // Encaminha do estágio WB
        end
    end

endmodule