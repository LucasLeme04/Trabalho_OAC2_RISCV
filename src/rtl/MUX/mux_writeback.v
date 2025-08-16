module mux_writeback (
    input [31:0] alu_result,
    input [31:0] mem_data,
    input [31:0] pc_plus_4,
    input [31:0] immediate,
    input [1:0] mem_to_reg,
    output reg [31:0] write_data 
);

    always @(*) begin
        case (mem_to_reg)
            2'b00: write_data = alu_result;
            2'b01: write_data = mem_data;
            2'b10: write_data = pc_plus_4;
            2'b11: write_data = immediate;
            default: write_data = alu_result;
        endcase
    end

endmodule
