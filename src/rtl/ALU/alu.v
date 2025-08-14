
module ALU (
    input [31:0] in1, in2, 
    input [3:0] alu_control,
    output reg [31:0] alu_result,
    output reg zero_flag
);
    
    always @(*) begin
        case(alu_control)
            // Operações lógicas
            4'b0000: alu_result = in1 & in2;        // AND
            4'b0001: alu_result = in1 | in2;        // OR
            4'b0010: alu_result = in1 + in2;        // ADD
            4'b0110: alu_result = in1 - in2;        // SUB
            4'b0111: alu_result = in1 ^ in2;        // XOR
            
            // Operações de deslocamento (shift)
            4'b1000: alu_result = in1 >> in2[4:0];  // SRL (logical)
            4'b1001: alu_result = in1 << in2[4:0];  // SLL
            4'b1010: alu_result = $signed(in1) >>> in2[4:0]; // SRA (arithmetic)
            
            // Operações de comparação (para SLT, etc)
            4'b1100: alu_result = ($signed(in1) < $signed(in2)) ? 32'b1 : 32'b0;  // SLT
            4'b1101: alu_result = (in1 < in2) ? 32'b1 : 32'b0;  // SLTU
            
            // Operações adicionais
            4'b1110: alu_result = in2;              // LUI (pass-through)
            4'b1111: alu_result = in1;              // NOP ou pass-through
            
            default: alu_result = 32'b0;
        endcase

        // Flag zero é ativada quando o resultado é zero
        zero_flag = (alu_result == 32'b0);
    end
    
endmodule