module program_counter (
    input wire clk,                     // clock principal
    input wire reset,                   // reset assíncrono
    input wire [31:0] pc_next,          // próximo valor do PC (PC + 4 ou PC + offset)
    input wire pc_write,                // controle: atualiza o PC se for 1
    output reg [31:0] pc_current        // valor atual do PC
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;        // começa do endereço 0
        else if (pc_write)
            pc_current <= pc_next;      // atualiza com o valor vindo de fora
    end

endmodule
