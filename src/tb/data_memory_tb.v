// ------------------------------------------------------------------
// Testbench para a Memória de Dados (data_memory)
// Escrita (sh) e Leitura (lh) de meia-palavra.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module data_memory_tb;

    // 1. Sinais de Controle e Dados
    reg         clk;
    reg         reset;
    reg  [31:0] address_tb;
    reg  [31:0] write_data_tb;
    reg         mem_read_tb;
    reg         mem_write_tb;
    reg  [1:0]  size_tb;
    reg         unsigned_load_tb;
    wire [31:0] read_data_tb;

    // 2. Instanciação do Módulo
    data_memory dut (
        .clk(clk),
        .reset(reset),
        .address(address_tb),
        .write_data(write_data_tb),
        .mem_read(mem_read_tb),
        .mem_write(mem_write_tb),
        .size(size_tb),
        .unsigned_load(unsigned_load_tb),
        .read_data(read_data_tb)
    );

    // 3. Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DA MEMORIA DE DADOS");
        $display("-------------------------------------------------");
        
        // Inicializa os sinais
        reset = 0; mem_read_tb = 0; mem_write_tb = 0;
        address_tb = 32'b0; write_data_tb = 32'b0; 
        size_tb = 2'b01;
        unsigned_load_tb = 0;

        // --- TESTE 1: Leitura de meia-palavra (lh) com valor positivo ---
        $display("\n>>> Teste 1: Lendo meia-palavra positiva (lh)...");
        // Lendo do endereço 8, onde está 32'h00001234. Queremos os 16 bits de baixo.
        address_tb = 32'h00000008;
        mem_read_tb = 1;
        #10;
        $display("Lendo addr 0x%08h | Esperado: 0x00001234 | Saida: 0x%08h", address_tb, read_data_tb);
        mem_read_tb = 0;
        @(posedge clk);

        // --- TESTE 2: Leitura de meia-palavra (lh) com valor negativo ---
        $display("\n>>> Teste 2: Lendo meia-palavra negativa (teste de sign-extend)...");
        address_tb = 32'h0000000E;
        mem_read_tb = 1;
        #10;
        $display("Lendo addr 0x%08h | Esperado: 0xFFFFAABB | Saida: 0x%08h", address_tb, read_data_tb);
        mem_read_tb = 0;
        @(posedge clk);

        // --- TESTE 3: Escrita de meia-palavra (sh) e verificação ---
        $display("\n>>> Teste 3: Escrevendo meia-palavra (sh) e lendo de volta...");
        address_tb = 32'h00000010;
        write_data_tb = 32'hFFFFCAFE;
        mem_write_tb = 1;
        $display("Escrevendo 0xCAFE no endereco 0x%08h...", address_tb);
        @(posedge clk);
        mem_write_tb = 0;

        unsigned_load_tb = 1;
        mem_read_tb = 1;
        #10;
        $display("Lendo addr 0x%08h | Esperado: 0x0000CAFE | Saida: 0x%08h", address_tb, read_data_tb);
        mem_read_tb = 0;
        unsigned_load_tb = 0;
        
        $display("\n-------------------------------------------------");
        $display("FIM DO TESTBENCH.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule