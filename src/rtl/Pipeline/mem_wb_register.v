module mem_wb_register (
    input wire clk,
    input wire reset,
    input wire flush,
    
    // Sinais de Controle
    input wire        regwrite_in,
    input wire [1:0]  mem_to_reg_in,
    
    // Dados
    input wire [31:0] mem_read_data_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] pc_plus_4_in,
    input wire [4:0]  rd_in,

    // Saídas para o estágio WB
    output reg        regwrite_out,
    output reg [1:0]  mem_to_reg_out,
    output reg [31:0] mem_read_data_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] pc_plus_4_out,
    output reg [4:0]  rd_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset assíncrono ou flush
            regwrite_out      <= 1'b0;
            mem_to_reg_out   <= 2'b00;
            mem_read_data_out <= 32'b0;
            alu_result_out    <= 32'b0;
            pc_plus_4_out     <= 32'b0;
            rd_out            <= 5'b0;
        end else begin
            // Captura normal dos valores
            regwrite_out      <= regwrite_in;
            mem_to_reg_out    <= mem_to_reg_in;
            mem_read_data_out <= mem_read_data_in;
            alu_result_out    <= alu_result_in;
            pc_plus_4_out     <= pc_plus_4_in;
            rd_out            <= rd_in;
        end
    end

endmodule