/*
 * Hazard Detection Unit para o pipeline RISC-V - VERSÃO FINAL
 * Detecta e resolve hazards de dados e controle de forma explícita
 */
module hazard_detection_unit (
    // Entradas do estágio ID
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    
    // Entradas do estágio EX
    input wire       mem_read_ex,
    input wire [4:0] rd_ex,
    
    // Entradas do estágio MEM
    input wire       branch_taken,
    
    // Sinais de saída para controle
    output reg       pc_write_enable,
    output reg       if_id_write_enable,
    output reg       id_ex_flush,
    output reg       if_id_flush,
    output reg       ex_mem_flush  // Novo: flush para EX/MEM quando branch é tomado
);

    always @(*) begin
        // --- Valores padrão: pipeline opera normalmente ---
        pc_write_enable    = 1'b1;
        if_id_write_enable = 1'b1;
        id_ex_flush        = 1'b0;
        if_id_flush        = 1'b0;
        ex_mem_flush       = 1'b0; // Novo
        
        // --- Hazard de dados: load-use (causa um STALL e uma BOLHA) ---
        if (mem_read_ex && (rd_ex != 5'b0) && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            pc_write_enable    = 1'b0; // Para o PC
            if_id_write_enable = 1'b0; // Para o registrador IF/ID
            id_ex_flush        = 1'b1; // Insere uma bolha (NOP) no próximo estágio
        end
        // --- Hazard de controle: branch tomado (causa um FLUSH) ---
        else if (branch_taken) begin
            if_id_flush        = 1'b1; // Limpa a instrução incorreta que foi buscada
            id_ex_flush        = 1'b1; // Limpa também o próximo estágio
            ex_mem_flush       = 1'b1; // Limpa a instrução no estágio EX
        end
    end
endmodule