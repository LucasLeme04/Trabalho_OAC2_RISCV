// ------------------------------------------------------------------
// Testbench para a Memória de Instruções (inst_mem)
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module inst_mem_tb;

    // 1. Sinais de Entrada e Saída
    reg  [31:0] pc_tb;
    wire [31:0] instruction_tb;

    // 2. Instanciação do Módulo (DUT)
    // A entrada 'reset' não é usada na lógica, então podemos deixá-la desconectada.
    inst_mem dut (
        .PC(pc_tb),
        .Instruction_Code(instruction_tb)
    );

    // 3. Bloco de Estímulos e Verificação
    initial begin
        $display("-------------------------------------------------");
        $display("INICIANDO TESTBENCH DA MEMORIA DE INSTRUCOES");
        $display("-------------------------------------------------");

        // --- TESTE 1: Ler instruções válidas do programa ---
        $display("\n>>> Teste 1: Lendo instrucoes pre-carregadas...");
        
        // Ler a primeira instrução (lh) no endereço 0x00
        pc_tb = 32'h00000000;
        #10;
        $display("PC = 0x%08h | Esperado: 0x00801083 | Saida: 0x%08h", pc_tb, instruction_tb);
        
        // Ler a setima instrucao (beq) no endereco 0x18 (6 * 4)
        pc_tb = 32'h00000018;
        #10;
        $display("PC = 0x%08h | Esperado: 0x00510463 | Saida: 0x%08h", pc_tb, instruction_tb);

        // --- TESTE 2: Ler um NOP de uma área não programada ---
        $display("\n>>> Teste 2: Lendo NOP de area nao programada...");
        pc_tb = 32'h00000100; // Endereco 256
        #10;
        $display("PC = 0x%08h | Esperado: 0x00000013 | Saida: 0x%08h", pc_tb, instruction_tb);

        // --- TESTE 3: Testar tratamento de erros ---
        $display("\n>>> Teste 3: Verificando tratamento de erros...");
        
        // a) Endereco nao alinhado (nao eh multiplo de 4)
        pc_tb = 32'h00000005; 
        #10;
        $display("PC = 0x%08h ( desalinhado ) | Esperado: 0x00000013 (NOP) | Saida: 0x%08h", pc_tb, instruction_tb);
        
        // b) Endereco fora dos limites (maior que 4KB)
        pc_tb = 32'h00001000; // Endereco 4096, que eh o word_addr 1024 (invalido)
        #10;
        $display("PC = 0x%08h ( fora de limites ) | Esperado: 0x00000013 (NOP) | Saida: 0x%08h", pc_tb, instruction_tb);

        $display("\n-------------------------------------------------");
        $display("FIM DO TESTBENCH.");
        $display("-------------------------------------------------");
        #10 $finish;
    end

endmodule