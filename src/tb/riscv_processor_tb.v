`timescale 1ns / 1ps

// Inclui o processador. O processador, por sua vez, já inclui todos os outros módulos.
`include "rtl/riscv_processor.v"

module riscv_processor_tb;

    // 1. Sinais para o DUT
    reg clk;
    reg reset;

    // 2. Instanciação do Processador (DUT - Design Under Test)
    riscv_processor dut (
        .clk(clk),
        .reset(reset)
    );

    // 3. Geração de Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock de 100MHz (período de 10ns)
    end

    // 4. Bloco de Simulação e Verificação
    initial begin
        // Configuração para GTKWave
        $dumpfile("riscv_processor_waveform.vcd");
        $dumpvars(0, riscv_processor_tb);
        
        $display("=================================================");
        $display("INICIANDO TESTBENCH DE INTEGRACAO DO PROCESSADOR");
        $display("=================================================");
        
        reset = 1;
        #20; // Mantém o reset por 2 ciclos de clock
        reset = 0;
        
        $display("Reset liberado. O programa esta executando...");
        
        // Deixa o programa rodar por um numero suficiente de ciclos
        #200; 

        // 5. Verificacao dos Resultados Finais
        $display("\n=================================================");
        $display("VERIFICACAO FINAL - 7 INSTRUCOES DO GRUPO");
        $display("=================================================");
        $display("Instrucoes testadas: lh, sh, sub, or, andi, srl, beq");
        $display("-------------------------------------------------");

        // Acessamos hierarquicamente o conteudo da memoria do banco de registradores
        $display("x14 (sub)    | Esperado: 35 (50-15) | Recebido: %d", dut.reg_file_inst.reg_memory[14]);
        $display("x15 (or)     | Esperado: 51 (35|50) | Recebido: %d", dut.reg_file_inst.reg_memory[15]);
        $display("x16 (andi)   | Esperado: 15 (15&31) | Recebido: %d", dut.reg_file_inst.reg_memory[16]);
        $display("x17 (lh)     | Esperado: 51 (load)  | Recebido: %d", dut.reg_file_inst.reg_memory[17]);
        $display("x18 (srl)    | Esperado: 3 (15>>2)  | Recebido: %d", dut.reg_file_inst.reg_memory[18]);
        $display("x19 (flush)  | Esperado: 0 (branch) | Recebido: %d", dut.reg_file_inst.reg_memory[19]);
        $display("-------------------------------------------------");
        
        // Verificação detalhada do SH (Store Halfword)
        $display("SH DETALHADO:");
        $display("  Valor em x15 (origem): %d (0x%04h)", dut.reg_file_inst.reg_memory[15], dut.reg_file_inst.reg_memory[15]);
        $display("  Memoria[0] completa: 0x%08h", dut.data_mem.memory[0]);
        $display("  Halfword armazenado [15:0]: 0x%04h", dut.data_mem.memory[0][15:0]);
        $display("  Halfword superior [31:16]: 0x%04h", dut.data_mem.memory[0][31:16]);
        if (dut.data_mem.memory[0][15:0] == dut.reg_file_inst.reg_memory[15][15:0])
            $display("  [OK] SH FUNCIONOU: Valor correto armazenado!");
        else
            $display("  [ERRO] SH FALHOU: Valor incorreto!");
            
        // Verificação detalhada do LH (Load Halfword)  
        $display("LH DETALHADO:");
        $display("  Valor carregado em x17: %d (0x%04h)", dut.reg_file_inst.reg_memory[17], dut.reg_file_inst.reg_memory[17]);
        if (dut.reg_file_inst.reg_memory[17] == dut.data_mem.memory[0][15:0])
            $display("  [OK] LH FUNCIONOU: Valor correto carregado!");
        else
            $display("  [ERRO] LH FALHOU: Valor incorreto!");
            
        $display("-------------------------------------------------");
        $display("beq: Branch equal executado (visivel pelo flush de x19)");
        
        $display("\n=================================================");
        $display("ESTADO FINAL DA MEMORIA DE DADOS");
        $display("=================================================");
        
        // Mostra as primeiras palavras da memória de dados
        for (integer j = 0; j < 8; j = j + 1) begin
            $display("memoria[%2d]: 0x%08h", j, dut.data_mem.memory[j]);
        end
        
        $display("\n=================================================");
        $display("ESTADO FINAL DE TODOS OS REGISTRADORES");
        $display("=================================================");
        
        // Mostra todos os 32 registradores
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("register[%2d]: %d", i, dut.reg_file_inst.reg_memory[i]);
        end
        
        $display("\nExemplo de saida no terminal apos execucao da simulacao.");
        
        $display("\nSimulacao concluida.");
        #10 $finish;
    end

endmodule