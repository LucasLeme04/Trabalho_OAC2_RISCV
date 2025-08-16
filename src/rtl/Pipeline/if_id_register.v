module if_id_register (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire flush,
    
    input wire [31:0] instruction_in,
    input wire [31:0] pc_in,

    output reg [31:0] instruction_out,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= 32'b0;
            pc_out          <= 32'b0;
        end
        else if (flush) begin
            instruction_out <= 32'h00000013;
            pc_out          <= 32'b0; 
        end
        else if (write_enable) begin
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
        end
    end

endmodule