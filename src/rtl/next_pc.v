module next_pc (
    input wire [31:0] pc_current,      // PC atual
    input wire [31:0] branch_offset,   // Offset para desvios (ex: bne, jal)
    input wire branch_taken,           // Controle: 1 = desvia
    output wire [31:0] pc_next         // Próximo PC
);
    // Lógica: PC+4 ou PC + offset (desvio)
    assign pc_next = branch_taken ? (pc_current + branch_offset) : (pc_current + 32'd4);
endmodule