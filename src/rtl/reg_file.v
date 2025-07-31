// Banco de registradores com 32 registradores de 32 bits (x0 a x31)

module reg_file (
    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2,
    input regwrite,
    input clock,
    input reset
);

    reg [31:0] reg_memory [0:31];

    // Inicializa os registradores no reset
    integer i;
    always @(posedge reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            reg_memory[i] = i;
        end
        reg_memory[0] = 32'b0; // x0 sempre 0
    end

    // Leitura assíncrona dos registradores
    assign read_data1 = reg_memory[read_reg_num1];
    assign read_data2 = reg_memory[read_reg_num2];

    // Escrita síncrona
    always @(posedge clock) begin
        if (regwrite && write_reg != 0) begin
            reg_memory[write_reg] <= write_data;
        end
    end

endmodule
