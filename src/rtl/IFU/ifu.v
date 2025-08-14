`include "rtl/IFU/inst_mem.v"

module IFU(
    input wire clk,
    input wire reset,
    input wire stall,           // Novo: sinal de stall do hazard unit
    input wire branch_taken,
    input wire jump_taken,      // Novo: sinal para instruções de jump
    input wire [31:0] branch_target,
    input wire [31:0] jump_target, // Novo: alvo para jumps
    output wire [31:0] Instruction_Code,
    output reg [31:0] PC,
    output wire [31:0] PC_plus_4 // Novo: PC+4 para instruções JAL
);
    // Lógica do próximo PC
    wire [31:0] next_pc;
    assign next_pc = (branch_taken) ? branch_target :
                    (jump_taken)  ? jump_target :
                    (PC + 4);

    // Memória de instruções
    inst_mem instr_mem(
        .PC(PC),
        .reset(reset),
        .Instruction_Code(Instruction_Code)
    );

    // Cálculo de PC+4 (para JAL)
    assign PC_plus_4 = PC + 4;

    // Registrador PC
    always @(posedge clk) begin
        if (reset)
            PC <= 32'h0000_0000;
        else if (!stall)  // Só atualiza se não houver stall
            PC <= next_pc;
    end
endmodule