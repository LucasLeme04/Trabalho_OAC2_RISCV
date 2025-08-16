/*
Testbench para a Instruction Fetch Unit (ifu.v)
*/

`timescale 1ns/1ps

module ifu_tb;

    // Sinais do testbench
    reg clk;
    reg reset;
    reg branch_taken;
    reg [31:0] branch_target;
    wire [31:0] Instruction_Code;
    
    // Instancia do modulo a ser testado
    IFU uut (
        .clk(clk),
        .reset(reset),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .Instruction_Code(Instruction_Code)
    );
    
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end
    
    // Processo de teste
    initial begin
        // Configuracao do arquivo VCD para visualizacao de ondas
        $dumpfile("ifu_test.vcd");
        $dumpvars(0, ifu_tb);
        
        $display("\n=== TESTBENCH INSTRUCTION FETCH UNIT ===");
        $display("Testando integracao completa da IFU\n");
        
        // Inicializacao
        reset = 1'b0;
        branch_taken = 1'b0;
        branch_target = 32'h00000000;
        
        // Teste 1: Reset e inicializacao
        $display("Teste 1: Reset e inicializacao da IFU");
        reset = 1'b1;
        #10;
        $display("Reset ativo - PC deveria estar em 00000000");
        reset = 1'b0;
        #10;
        $display("Primeiro ciclo - PC: interno, Instrucao: %h", Instruction_Code);
        if (Instruction_Code == 32'h00411083)
            $display("PASSOU - Primeira instrucao LH carregada corretamente\n");
        else
            $display("FALHOU - Esperado 00411083, obtido %h\n", Instruction_Code);
        
        // Teste 2: Execucao sequencial (PC+4)
        $display("Teste 2: Execucao sequencial do programa");
        branch_taken = 1'b0;  // Execucao sequencial
        
        #10;  // Ciclo 2
        $display("Ciclo 2 - Instrucao: %h (SH)", Instruction_Code);
        
        #10;  // Ciclo 3
        $display("Ciclo 3 - Instrucao: %h (SUB)", Instruction_Code);
        
        #10;  // Ciclo 4
        $display("Ciclo 4 - Instrucao: %h (OR)", Instruction_Code);
        
        #10;  // Ciclo 5
        $display("Ciclo 5 - Instrucao: %h (ANDI)", Instruction_Code);
        
        #10;  // Ciclo 6
        $display("Ciclo 6 - Instrucao: %h (SRL)", Instruction_Code);
        
        #10;  // Ciclo 7
        $display("Ciclo 7 - Instrucao: %h (BEQ)\n", Instruction_Code);
        
        // Teste 3: Branch tomado
        $display("Teste 3: Branch tomado (BEQ verdadeiro)");
        branch_taken = 1'b1;
        branch_target = 32'h00000008;  // Volta para instrucao SUB
        #10;
        $display("Branch para %h - Instrucao: %h", branch_target, Instruction_Code);
        if (Instruction_Code == 32'h407302b3)
            $display("PASSOU - Branch executado, SUB carregada\n");
        else
            $display("FALHOU - Branch nao funcionou corretamente\n");
        
        // Teste 4: Retorno para execucao sequencial
        $display("Teste 4: Retorno para execucao sequencial");
        branch_taken = 1'b0;  // Volta para sequencial
        
        #10;  // Proxima instrucao (OR)
        $display("Sequencial apos branch - Instrucao: %h (OR)", Instruction_Code);
        
        #10;  // Proxima instrucao (ANDI)
        $display("Continuacao sequencial - Instrucao: %h (ANDI)\n", Instruction_Code);
        
        // Teste 5: Branch para inicio do programa
        $display("Teste 5: Branch para inicio do programa");
        branch_taken = 1'b1;
        branch_target = 32'h00000000;  // Volta para inicio
        #10;
        $display("Branch para inicio - Instrucao: %h (LH)", Instruction_Code);
        if (Instruction_Code == 32'h00411083)
            $display("PASSOU - Branch para inicio funcionou\n");
        else
            $display("FALHOU - Branch para inicio nao funcionou\n");
        
        // Teste 6: Sequencia completa das 7 instrucoes
        $display("Teste 6: Execucao completa das 7 instrucoes do Grupo 9");
        branch_taken = 1'b0;  // Execucao sequencial
        
        $display("Programa completo:");
        $display("1. LH   x1, 4(x2)     - %h", Instruction_Code);
        
        #10;
        $display("2. SH   x3, 8(x4)     - %h", Instruction_Code);
        
        #10;
        $display("3. SUB  x5, x6, x7    - %h", Instruction_Code);
        
        #10;
        $display("4. OR   x8, x9, x10   - %h", Instruction_Code);
        
        #10;
        $display("5. ANDI x11, x12, 0xFF - %h", Instruction_Code);
        
        #10;
        $display("6. SRL  x13, x14, x15 - %h", Instruction_Code);
        
        #10;
        $display("7. BEQ  x16, x17, 16  - %h\n", Instruction_Code);
        
        // Teste 7: Simulacao de loop com BEQ
        $display("Teste 7: Simulacao de loop com BEQ");
        
        // BEQ nao tomado (continua)
        branch_taken = 1'b0;
        #10;
        $display("BEQ nao tomado - proxima instrucao seria: %h", Instruction_Code);
        
        // BEQ tomado (loop back)
        branch_taken = 1'b1;
        branch_target = 32'h00000010;  // Volta para ANDI
        #10;
        $display("BEQ tomado - volta para ANDI: %h", Instruction_Code);
        
        // Continua o loop
        branch_taken = 1'b0;
        #10;
        $display("Continua loop - SRL: %h", Instruction_Code);
        
        #10;
        $display("Continua loop - BEQ: %h\n", Instruction_Code);
        
        // Teste 8: Reset durante execucao
        $display("Teste 8: Reset durante execucao");
        $display("Instrucao antes do reset: %h", Instruction_Code);
        
        reset = 1'b1;
        #10;
        $display("Reset ativo...");
        
        reset = 1'b0;
        #10;
        $display("Apos reset - volta para LH: %h", Instruction_Code);
        if (Instruction_Code == 32'h00411083)
            $display("PASSOU - Reset reinicia programa corretamente\n");
        else
            $display("FALHOU - Reset nao funcionou\n");
        
        // Teste 9: Branches para enderecos especificos
        $display("Teste 9: Testes de branch para enderecos especificos");
        
        branch_taken = 1'b1;
        
        // Branch para cada instrucao
        branch_target = 32'h00000004;  // SH
        #10;
        $display("Branch para SH (0x04): %h", Instruction_Code);
        
        branch_target = 32'h0000000C;  // OR
        #10;
        $display("Branch para OR (0x0C): %h", Instruction_Code);
        
        branch_target = 32'h00000014;  // SRL
        #10;
        $display("Branch para SRL (0x14): %h", Instruction_Code);
        
        branch_target = 32'h00000018;  // BEQ
        #10;
        $display("Branch para BEQ (0x18): %h\n", Instruction_Code);
        
        // Teste 10: Alinhamento de PC
        $display("Teste 10: Teste de alinhamento de PC");
        
        // PC desalinhado deveria ser forcado para alinhamento
        branch_target = 32'h00000005;  // Endereco nao alinhado
        #10;
        $display("Branch para endereco desalinhado 0x05");
        $display("Instrucao obtida: %h (deveria ser SH = 00322423)", Instruction_Code);
        
        branch_target = 32'h00000007;  // Outro endereco desalinhado
        #10;
        $display("Branch para endereco desalinhado 0x07");
        $display("Instrucao obtida: %h (deveria ser SH = 00322423)\n", Instruction_Code);
        $finish;
    end
    
endmodule