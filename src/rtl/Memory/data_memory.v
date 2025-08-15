module data_memory (
    input wire clk,
    input wire reset,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    input wire [1:0] size,        // 00: byte, 01: halfword, 10: word
    input wire unsigned_load,     // 0: sign-extend, 1: zero-extend
    output reg [31:0] read_data
);

    // Memória de dados - 1024 palavras (4KB)
    reg [31:0] memory [0:1023];

    wire [9:0] word_addr = address[11:2];
    wire [1:0] byte_offset = address[1:0];

    // Inicialização mais completa para testes
    initial begin
        // Inicializa a memória com valores de teste - memória "limpa"
        memory[0] = 32'h00000000;  // Memória inicialmente vazia
        memory[1] = 32'h00000000;  // Posição extra
        
        // Preenche o resto com zeros
        for (integer i = 2; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
    end

    // Lógica de leitura (assíncrona)
    always @(*) begin
        if (mem_read) begin
            case (size)
                2'b01: begin // halfword (lh)
                    case (byte_offset)
                        2'b00: read_data = unsigned_load ? 
                                        {16'b0, memory[word_addr][15:0]} :
                                        {{16{memory[word_addr][15]}}, memory[word_addr][15:0]};
                        2'b10: read_data = unsigned_load ?
                                        {16'b0, memory[word_addr][31:16]} :
                                        {{16{memory[word_addr][31]}}, memory[word_addr][31:16]};
                        default: read_data = 32'h00000000;
                    endcase
                end
                // Adicione outros tamanhos aqui se necessário
                default: read_data = 32'h00000000;
            endcase
        end else begin
            read_data = 32'h00000000;
        end
    end
    
    // Lógica de escrita (síncrona)
    always @(posedge clk) begin
        if (mem_write) begin
            case (size)
                2'b01: begin // sh (halfword)
                    case (byte_offset)
                        2'b00: memory[word_addr][15:0] <= write_data[15:0];
                        2'b10: memory[word_addr][31:16] <= write_data[15:0];
                    endcase
                end
                // Adicione outros tamanhos aqui se necessário
            endcase
        end
    end

endmodule
