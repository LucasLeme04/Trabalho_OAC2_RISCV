module reg_file (
    input clock,
    input reset,
    input regwrite,
    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    // Array de 32 registradores de 32 bits
    reg [31:0] reg_memory [0:31];
    
    // Escrita síncrona
    always @(posedge clock) begin
        if (regwrite && (write_reg != 5'b00000)) begin
            reg_memory[write_reg] <= write_data;
        end
    end

    // Leitura com Forwarding Interno
    assign read_data1 = (read_reg_num1 == 5'b00000) ? 32'b0 : 
                        (regwrite && (write_reg == read_reg_num1) && (write_reg != 5'b00000)) ? write_data :
                        reg_memory[read_reg_num1];
                        
    assign read_data2 = (read_reg_num2 == 5'b00000) ? 32'b0 : 
                        (regwrite && (write_reg == read_reg_num2) && (write_reg != 5'b00000)) ? write_data :
                        reg_memory[read_reg_num2];

    initial begin
        for (integer i = 0; i < 32; i = i + 1) begin
            reg_memory[i] = 32'b0;
        end
    end
endmodule