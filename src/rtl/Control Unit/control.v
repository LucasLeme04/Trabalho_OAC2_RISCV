// control.v - VERSÃO CORRIGIDA E ATUALIZADA
module control(
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] opcode,
    
    // --- SAÍDAS DE CONTROLE ATUALIZADAS ---
    output reg [1:0] alu_src_a,      // Controle do MUX A da ALU (00: Reg, 01: PC)
    output reg [1:0] alu_src_b,      // Controle do MUX B da ALU (00: Reg, 01: Imm)
    output reg [1:0] mem_to_reg,     // Controle do MUX de Write-Back (00: ALU, 01: Mem)
    output reg [3:0] alu_control,
    output reg       regwrite,
    output reg       mem_read,
    output reg       mem_write,
    output reg       branch
);

    always @(*) begin
        // --- VALORES PADRÃO (SEGUROS, EQUIVALENTE A UM NOP) ---
        alu_src_a   = 2'b00;
        alu_src_b   = 2'b00;
        mem_to_reg  = 2'b00;
        alu_control = 4'b1111; // Operação NOP na ULA
        regwrite    = 0;
        mem_read    = 0;
        mem_write   = 0;
        branch      = 0;

        case (opcode)
            // TIPO I - Load (lh - load halfword)
            7'b0000011: begin
                regwrite    = 1;
                mem_read    = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador (para endereço)
                alu_src_b   = 2'b01; // Operando B = Imediato (para endereço)
                mem_to_reg  = 2'b01; // Escrever resultado da Memória
                alu_control = 4'b0010; // ULA faz ADD para calcular endereço
            end

            // TIPO S - Store (sh - store halfword)
            7'b0100011: begin
                mem_write   = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador base
                alu_src_b   = 2'b01; // Operando B = Imediato (offset)
                alu_control = 4'b0010; // ULA faz ADD para calcular endereço
            end

            // TIPO I - Aritmética (andi)
            7'b0010011: begin
                regwrite    = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador
                alu_src_b   = 2'b01; // Operando B = Imediato
                mem_to_reg  = 2'b00; // Escrever resultado da ULA
                
                case (funct3)
                    3'b000: alu_control = 4'b0010; // ADDI: ULA faz ADD
                    3'b111: alu_control = 4'b0000; // ANDI: ULA faz AND
                    3'b110: alu_control = 4'b0001; // ORI: ULA faz OR
                    3'b101: alu_control = 4'b1000; // SRLI: ULA faz SRL
                    default: alu_control = 4'b0010; // Default: ADD
                endcase
            end

            // TIPO R - Registrador (sub, or, srl)
            7'b0110011: begin
                regwrite    = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador rs1
                alu_src_b   = 2'b00; // Operando B = Registrador rs2
                mem_to_reg  = 2'b00; // Escrever resultado da ULA
                
                case ({funct7[5], funct3}) // Combina funct7[5] e funct3 para decodificar
                    4'b1000: alu_control = 4'b0110; // SUB (funct7[5]=1, funct3=000)
                    4'b0110: alu_control = 4'b0001; // OR  (funct7[5]=0, funct3=110)
                    4'b0101: alu_control = 4'b1000; // SRL (funct7[5]=0, funct3=101)
                    default: alu_control = 4'b0010; // Default: ADD
                endcase
            end

            // TIPO B - Branch (beq)
            7'b1100011: begin
                branch      = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador rs1
                alu_src_b   = 2'b00; // Operando B = Registrador rs2
                alu_control = 4'b0110; // ULA faz SUB para comparação
            end

            // TIPO S - Store (sh)
            7'b0100011: begin
                mem_write   = 1;
                alu_src_a   = 2'b00; // Operando A = Registrador (para end.)
                alu_src_b   = 2'b01; // Operando B = Imediato (para end.)
                alu_control = 4'b0010; // ULA faz ADD para calcular endereço
            end

            // TIPO B - Branch (beq)
            7'b1100011: begin
                branch      = 1;
                alu_src_a   = 2'b00; // Operando A vem do Registrador (rs1)
                alu_src_b   = 2'b00; // Operando B vem do Registrador (rs2)
                alu_control = 4'b0110; // ULA faz SUB para comparar
            end
        endcase
    end
endmodule