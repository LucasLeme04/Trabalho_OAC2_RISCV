`include "inst_mem.v"

module IFU(
    input wire clk,               
    input wire reset,             // Reset síncrono
    input wire branch_taken,      // Controle de desvio (1 = pula)
    input wire [31:0] branch_target, // Endereço de desvio
    output wire [31:0] Instruction_Code
);
    reg [31:0] PC;
    wire [31:0] next_pc;

    // Lógica do próximo PC
    assign next_pc = branch_taken ? branch_target : (PC + 4);

    // Memória de instruções (alinhada a 4 bytes)
    inst_mem instr_mem(
        .PC({PC[31:2], 2'b00}),  // Força alinhamento (PC[1:0] = 00)
        .reset(reset),
        .Instruction_Code(Instruction_Code)
    );

    // Atualização do PC (síncrono)
    always @(posedge clk) begin
        if (reset)
            PC <= 32'h0000_0000;  // Reset para endereço 0
        else
            PC <= next_pc;        // Atualiza com PC+4 ou desvio
    end
endmodule