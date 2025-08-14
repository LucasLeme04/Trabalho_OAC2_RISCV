module immediate_generator (
    input  [31:0] instruction,
    output reg [31:0] imm_out
);

    // Definições de opcode (mais legível)
    localparam OPCODE_LOAD   = 7'b0000011;  // lh
    localparam OPCODE_OP_IMM = 7'b0010011;  // andi
    localparam OPCODE_STORE  = 7'b0100011;  // sh
    localparam OPCODE_BRANCH = 7'b1100011;  // beq

   always @(*) begin
        // Atribui um valor padrão para evitar a criação de latches.
        // Se nenhum caso do 'case' for satisfeito, a saída terá este valor.
        imm_out = 32'hDEADBEEF; 

        case (instruction[6:0])
            OPCODE_LOAD: begin // lh (I-type)
                imm_out = {{20{instruction[31]}}, instruction[31:20]};  // sign-extend
            end
            
            OPCODE_OP_IMM: begin // andi (I-type)
                // Zero-extend para ANDI (funct3 = 3'b111)
                imm_out = instruction[14:12] == 3'b111 ? 
                          {20'b0, instruction[31:20]} :                  // zero-extend para ANDI
                          {{20{instruction[31]}}, instruction[31:20]}; // sign-extend para outros I-type
            end
            
            7'b0110011: begin // Case para Tipo-R
                // Instruções do tipo R não usam imediato.
                imm_out = 32'b0; // Atribui um valor limpo
            end

            OPCODE_STORE: begin // sh (S-type)
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  // sign-extend
            end
            
            OPCODE_BRANCH: begin // beq (B-type)
                // B-type: CORRIGINDO DEFINITIVAMENTE!
                // Reconstrução: imm[12:0] = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}
                imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            
            default: begin
                imm_out = 32'hDEADBEEF;
                $display("Warning: Unknown opcode in immediate generator: %b", instruction[6:0]);
            end
        endcase
    end

endmodule
