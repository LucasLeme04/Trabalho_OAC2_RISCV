// ------------------------------------------------------------------
// Testbench para o Banco de Registradores (Register File)
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module reg_file_tb;

    // 1. Sinais de Controle e Dados para o reg_file (entradas)
    reg         clock;
    reg         reset;
    reg         regwrite;
    reg  [4:0]  read_reg_num1;
    reg  [4:0]  read_reg_num2;
    reg  [4:0]  write_reg;
    reg  [31:0] write_data;

    // 2. Sinais de Saída do reg_file
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // 3. Instanciação do Módulo Register File (DUT)
    reg_file dut (
        .clock(clock),
        .reset(reset),
        .regwrite(regwrite),
        .read_reg_num1(read_reg_num1),
        .read_reg_num2(read_reg_num2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // 4. Geração de Clock
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // 5. Bloco de Estímulos e Verificação
    initial begin
    $display("-------------------------------------------------");
    $display("INICIANDO TESTBENCH DO BANCO DE REGISTRADORES (V2)");
    $display("-------------------------------------------------");
    
    // --- TESTE 1: RESET ---
    reset = 1;
    @(posedge clock);
    $display("Tempo: %0t ns | Teste RESET: Lendo x5. Valor esperado: 0. Valor lido: %d", $time, read_data1);
    reset = 0;
    @(posedge clock);

    // --- TESTE 2: ESCRITA SIMPLES ---
    $display("\n--- Teste de Escrita Simples ---");
    regwrite = 1;
    write_reg = 5'd10;
    write_data = 32'd100;
    @(posedge clock);
    $display("Tempo: %0t ns | Escrito valor 100 em x10.", $time);
    write_reg = 5'd11;
    write_data = 32'd200;
    @(posedge clock);
    $display("Tempo: %0t ns | Escrito valor 200 em x11.", $time);
    regwrite = 0;
    @(posedge clock);
    read_reg_num1 = 5'd10;
    read_reg_num2 = 5'd11;
    #1;
    $display("Tempo: %0t ns | Lendo x10 e x11. Valores lidos: x10=%d, x11=%d", $time, read_data1, read_data2);

    // --- TESTE 3: PROTEÇÃO DO REGISTRADOR x0 ---
    $display("\n--- Teste de Proteção do Registrador x0 ---");
    regwrite = 1;
    write_reg = 5'd0;
    write_data = 32'd999;
    read_reg_num1 = 5'd0;
    @(posedge clock);
    regwrite = 0;
    #1;
    $display("Tempo: %0t ns | Lendo x0. Valor esperado: 0. Valor lido: %d", $time, read_data1);

    // --- TESTE 4: FORWARDING E ARMAZENAMENTO ---
    $display("\n--- Teste de Forwarding e Armazenamento ---");
    // 4a: Configurar a escrita e verificar o forwarding combinacional
    regwrite = 1;
    write_reg = 5'd5;
    write_data = 32'd555;
    read_reg_num1 = 5'd5;
    #1; // Delay para a lógica combinacional
    $display("Tempo: %0t ns | Teste 4a (Forwarding): Lendo x5 durante a escrita. Valor lido: %d", $time, read_data1);

    // 4b: Permitir que o clock suba para efetivar a escrita
    @(posedge clock);
    $display("Tempo: %0t ns | Borda do clock! A escrita em x5 foi efetivada na memória.", $time);

    // 4c: Desligar a escrita e verificar o valor ARMAZENADO
    regwrite = 0;
    #1; // Delay para garantir que o sinal de 'regwrite' se propague como 0
    $display("Tempo: %0t ns | Teste 4c (Armazenamento): Lendo x5 após a escrita. Valor lido: %d", $time, read_data1);
    
    $display("\n-------------------------------------------------");
    $display("FIM DO TESTBENCH DO BANCO DE REGISTRADORES.");
    $display("-------------------------------------------------");
    #10 $finish;
end
endmodule