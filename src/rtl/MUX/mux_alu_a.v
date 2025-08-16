module mux_alu_a (
    input [31:0] reg_data,
    input [31:0] pc_current,
    input [1:0] alu_src_a,
    output reg [31:0] alu_input_a
);

    always @(*) begin
        case (alu_src_a)
            2'b00: alu_input_a = reg_data;
            2'b01: alu_input_a = pc_current;
            2'b10: alu_input_a = 32'b0;
            default: alu_input_a = reg_data;
        endcase
    end

endmodule
