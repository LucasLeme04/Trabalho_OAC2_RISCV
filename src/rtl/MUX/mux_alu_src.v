module mux_alu_src (
    input [31:0] reg_data,
    input [31:0] immediate,
    input [1:0] alu_src_b,
    output reg [31:0] alu_input_b
);

    always @(*) begin
        case (alu_src_b)
            2'b00: alu_input_b = reg_data;
            2'b01: alu_input_b = immediate;
            2'b10: alu_input_b = 32'd4;
            default: alu_input_b = reg_data;
        endcase
    end

endmodule
