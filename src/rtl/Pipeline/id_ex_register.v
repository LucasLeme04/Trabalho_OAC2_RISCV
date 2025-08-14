/*
 * Registro ID/EX do pipeline RISC-V - VERSÃO CORRIGIDA
 * Armazena sinais de controle e dados entre os estágios ID e EX
 */
module id_ex_register (
    input wire clk,
    input wire reset,
    input wire flush,           // Sinal para limpar o registro

    // --- SINAIS DE CONTROLE CORRIGIDOS ---
    input wire        regwrite_in,
    input wire        mem_read_in,
    input wire        mem_write_in,
    input wire        branch_in,
    input wire [1:0]  alu_src_a_in,     // NOVO: Controle do MUX A da ALU
    input wire [1:0]  alu_src_b_in,     // NOVO: Controle do MUX B da ALU
    input wire [1:0]  mem_to_reg_in,
    input wire [3:0]  alu_control_in,

    // Dados do Banco de Registradores e PC
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] pc_in,
    input wire [31:0] immediate_in,
    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    input wire [4:0]  rd_in,

    // --- SAÍDAS CORRIGIDAS ---
    output reg        regwrite_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        branch_out,
    output reg [1:0]  alu_src_a_out,    // NOVO
    output reg [1:0]  alu_src_b_out,    // NOVO
    output reg [1:0]  mem_to_reg_out,
    output reg [3:0]  alu_control_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] pc_out,
    output reg [31:0] immediate_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Limpa todos os sinais para um estado NOP
            regwrite_out    <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_out      <= 1'b0;
            alu_src_a_out   <= 2'b00;
            alu_src_b_out   <= 2'b00;
            mem_to_reg_out  <= 2'b00;
            alu_control_out <= 4'hF; // NOP
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            pc_out          <= 32'b0;
            immediate_out   <= 32'b0;
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            rd_out          <= 5'b0;
        end else begin
            // Captura normal dos valores
            regwrite_out    <= regwrite_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            branch_out      <= branch_in;
            alu_src_a_out   <= alu_src_a_in;
            alu_src_b_out   <= alu_src_b_in;
            mem_to_reg_out  <= mem_to_reg_in;
            alu_control_out <= alu_control_in;
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            pc_out          <= pc_in;
            immediate_out   <= immediate_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;
        end
    end
endmodule