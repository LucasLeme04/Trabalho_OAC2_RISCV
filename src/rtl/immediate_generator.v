module ImmediateGenerator (
    input  logic [31:0] instruction,
    output logic [31:0] imm_out
);

    always_comb begin
        case (instruction[6:0])
            7'b0000011:  // lh (I-type)
                imm_out <= $signed(instruction[31:20]);

            7'b0100011:  // sh (S-type)
                imm_out <= $signed({instruction[31:25], instruction[11:7]});

            7'b0010011:  // andi (I-type)
                imm_out <= $signed(instruction[31:20]);

            7'b1100011:  // beq (B-type)
                imm_out <= $signed({
                    instruction[31],       // bit 12
                    instruction[7],        // bit 11
                    instruction[30:25],    // bits 10:5
                    instruction[11:8],     // bits 4:1
                    1'b0                   // bit 0
                });

            default:
                imm_out <= 32'b0;
        endcase
    end

endmodule