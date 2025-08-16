module ex_mem_register (
    input wire clk,
    input wire reset,
    input wire flush,
    
    // Sinais de Controle
    input wire        regwrite_in,
    input wire        mem_read_in,
    input wire        mem_write_in,
    input wire [1:0]  mem_to_reg_in,
    input wire        branch_in,
    
    // Dados e Flags
    input wire [31:0] alu_result_in,
    input wire [31:0] branch_target_in,
    input wire [31:0] write_data_in,
    input wire [4:0]  rd_in,
    input wire        zero_flag_in,

    // Saídas para o estágio MEM
    output reg        regwrite_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg [1:0]  mem_to_reg_out,
    output reg        branch_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] branch_target_out,
    output reg [31:0] write_data_out,
    output reg [4:0]  rd_out,
    output reg        zero_flag_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset assíncrono ou flush
            regwrite_out   <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b00;
            branch_out     <= 1'b0;
            alu_result_out <= 32'b0;
            branch_target_out <= 32'b0;
            write_data_out <= 32'b0;
            rd_out         <= 5'b0;
            zero_flag_out  <= 1'b0;
        end else begin
            // Captura normal dos valores
            regwrite_out   <= regwrite_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out     <= branch_in;
            alu_result_out <= alu_result_in;
            branch_target_out <= branch_target_in;
            write_data_out <= write_data_in;
            rd_out         <= rd_in;
            zero_flag_out  <= zero_flag_in;
        end
    end

endmodule