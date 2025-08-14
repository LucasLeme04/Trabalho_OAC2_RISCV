/*
 * Processador RISC-V Pipeline de 5 estágios - VERSÃO FINAL CORRIGIDA
 * - Com todas as unidades e lógica de controle de hazard integradas
 */

// Os `includes` são opcionais se você passar todos os arquivos para o compilador
// Mas os manteremos aqui para referência do projeto.
`include "rtl/ALU/alu.v"
`include "rtl/Control Unit/control.v"
`include "rtl/IFU/ifu.v"
`include "rtl/IFU/immediate_generator.v"
`include "rtl/Memory/data_memory.v"
`include "rtl/Register/reg_file.v"
`include "rtl/MUX/mux_alu_a.v"
`include "rtl/MUX/mux_alu_src.v"
`include "rtl/MUX/mux_writeback.v"
`include "rtl/Pipeline/if_id_register.v"
`include "rtl/Pipeline/id_ex_register.v"
`include "rtl/Pipeline/ex_mem_register.v"
`include "rtl/Pipeline/mem_wb_register.v"
`include "rtl/Pipeline/forwarding_unit.v"
`include "rtl/Pipeline/hazard_detection_unit.v"

module riscv_processor (
    input wire clk,
    input wire reset
);

    //================================================================
    // Declaração de Fios (Wires) - ATUALIZADA
    //================================================================

    // --- Sinais entre IF e ID ---
    wire [31:0] pc_if, instruction_if;
    wire [31:0] pc_id, instruction_id;
    wire        if_id_flush;
    wire        ex_mem_flush;  // Novo sinal para flush do EX/MEM

    // --- Sinais gerados no estágio ID ---
    wire [31:0] imm_out_id;
    wire [31:0] read_data1_id, read_data2_id;
    wire [4:0]  rs1_id, rs2_id, rd_id;
    // Sinais de controle da Control Unit
    wire [1:0]  alu_src_a_id, alu_src_b_id, mem_to_reg_id;
    wire [3:0]  alu_control_id;
    wire        regwrite_id, mem_read_id, mem_write_id, branch_id;
    
    // --- Sinais da Hazard Unit ---
    wire        pc_write_enable, if_id_write_enable, id_ex_bubble_enable;

    // --- Sinais entre ID e EX ---
    wire [31:0] pc_ex, read_data1_ex, read_data2_ex, imm_out_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire [1:0]  alu_src_a_ex, alu_src_b_ex, mem_to_reg_ex;
    wire [3:0]  alu_control_ex;
    wire        regwrite_ex, mem_read_ex, mem_write_ex, branch_ex;

    // --- Sinais gerados no estágio EX ---
    wire [31:0] alu_input_a, alu_input_b;
    wire [31:0] forwarded_data_a, forwarded_data_b;
    wire [31:0] alu_result_ex, branch_target_ex;
    wire [31:0] branch_target_mem;
    wire        zero_flag_ex;
    wire [1:0]  forward_a, forward_b;
    
    // --- Sinais entre EX e MEM ---
    wire [31:0] alu_result_mem, write_data_mem;
    wire [4:0]  rd_mem;
    wire [1:0]  mem_to_reg_mem;
    wire        zero_flag_mem;
    wire        regwrite_mem, mem_read_mem, mem_write_mem, branch_mem;
    
    // --- Sinais gerados no estágio MEM ---
    wire [31:0] mem_read_data_mem;
    wire        branch_taken_mem;

    // --- Sinais entre MEM e WB ---
    wire [31:0] mem_read_data_wb, alu_result_wb, pc_plus_4_wb;
    wire [4:0]  rd_wb;
    wire [1:0]  mem_to_reg_wb;
    wire        regwrite_wb;

    // --- Sinais gerados no estágio WB ---
    wire [31:0] write_data_wb;

    //================================================================
    // Debug básico a cada clock
    //================================================================

    //================================================================
    // Estágio IF - Busca de Instruções
    //================================================================
    IFU ifu_inst (
        .clk(clk),
        .reset(reset),
        .stall(~pc_write_enable),
        .branch_taken(branch_taken_mem),
        .jump_taken(1'b0),
        .branch_target(branch_target_mem),
        .jump_target(32'b0),
        .Instruction_Code(instruction_if),
        .PC(pc_if),
        .PC_plus_4() // PC+4 é passado pelo pipeline para JAL
    );
    
    if_id_register if_id_reg (
        .clk(clk),
        .reset(reset),
        .write_enable(if_id_write_enable),
        .flush(if_id_flush), // Conectado ao novo sinal da Hazard Unit
        .instruction_in(instruction_if),
        .pc_in(pc_if),
        .instruction_out(instruction_id),
        .pc_out(pc_id)
    );

    //================================================================
    // Estágio ID - Decodificação
    //================================================================
    assign rs1_id = instruction_id[19:15];
    assign rs2_id = instruction_id[24:20];
    assign rd_id  = instruction_id[11:7];

    control control_inst (
        .funct7(instruction_id[31:25]),
        .funct3(instruction_id[14:12]),
        .opcode(instruction_id[6:0]),
        // Saídas Corrigidas
        .alu_src_a(alu_src_a_id),
        .alu_src_b(alu_src_b_id),
        .mem_to_reg(mem_to_reg_id),
        .alu_control(alu_control_id),
        .regwrite(regwrite_id),
        .mem_read(mem_read_id),
        .mem_write(mem_write_id),
        .branch(branch_id)
    );

    reg_file reg_file_inst (
        .read_reg_num1(rs1_id),
        .read_reg_num2(rs2_id),
        .write_reg(rd_wb),
        .write_data(write_data_wb),
        .read_data1(read_data1_id),
        .read_data2(read_data2_id),
        .regwrite(regwrite_wb),
        .clock(clk),
        .reset(reset)
    );

    immediate_generator imm_gen (
        .instruction(instruction_id),
        .imm_out(imm_out_id)
    );
    
    hazard_detection_unit hazard_unit (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .mem_read_ex(mem_read_ex),
        .rd_ex(rd_ex),
        .branch_taken(branch_taken_mem),
        // Saídas Corrigidas
        .pc_write_enable(pc_write_enable),
        .if_id_write_enable(if_id_write_enable),
        .id_ex_flush(id_ex_bubble_enable),
        .if_id_flush(if_id_flush),
        .ex_mem_flush(ex_mem_flush)  // Novo sinal
    );

    id_ex_register id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_bubble_enable),
        // Entradas Corrigidas
        .regwrite_in(regwrite_id),
        .mem_read_in(mem_read_id),
        .mem_write_in(mem_write_id),
        .branch_in(branch_id),
        .alu_src_a_in(alu_src_a_id),
        .alu_src_b_in(alu_src_b_id),
        .mem_to_reg_in(mem_to_reg_id),
        .alu_control_in(alu_control_id),
        .read_data1_in(read_data1_id),
        .read_data2_in(read_data2_id),
        .pc_in(pc_id),
        .immediate_in(imm_out_id),
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        // Saídas Corrigidas
        .regwrite_out(regwrite_ex),
        .mem_read_out(mem_read_ex),
        .mem_write_out(mem_write_ex),
        .branch_out(branch_ex),
        .alu_src_a_out(alu_src_a_ex),
        .alu_src_b_out(alu_src_b_ex),
        .mem_to_reg_out(mem_to_reg_ex),
        .alu_control_out(alu_control_ex),
        .read_data1_out(read_data1_ex),
        .read_data2_out(read_data2_ex),
        .pc_out(pc_ex),
        .immediate_out(imm_out_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex)
    );

    //================================================================
    // Estágio EX - Execução
    //================================================================
    forwarding_unit fwd_unit (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_mem(rd_mem),
        .regwrite_mem(regwrite_mem),
        .rd_wb(rd_wb),
        .regwrite_wb(regwrite_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // MUX de Forwarding A (corrigido para LW)
    assign forwarded_data_a = (forward_a == 2'b00) ? read_data1_ex  :
                              (forward_a == 2'b01) ? write_data_wb  :
                              (forward_a == 2'b10) ? (mem_read_mem ? mem_read_data_mem : alu_result_mem) :
                              32'b0; // Default

    // MUX de Forwarding B (corrigido para LW)  
    assign forwarded_data_b = (forward_b == 2'b00) ? read_data2_ex  :
                              (forward_b == 2'b01) ? write_data_wb  :
                              (forward_b == 2'b10) ? (mem_read_mem ? mem_read_data_mem : alu_result_mem) :
                              32'b0; // Default

    mux_alu_a alu_a_mux (
        .reg_data(forwarded_data_a),
        .pc_current(pc_ex),
        .alu_src_a(alu_src_a_ex),
        .alu_input_a(alu_input_a)
    );

    mux_alu_src alu_src_mux (
        .reg_data(forwarded_data_b),
        .immediate(imm_out_ex),
        .alu_src_b(alu_src_b_ex),
        .alu_input_b(alu_input_b)
    );

    ALU alu (
        .in1(alu_input_a),
        .in2(alu_input_b),
        .alu_control(alu_control_ex),
        .alu_result(alu_result_ex),
        .zero_flag(zero_flag_ex)
    );

    assign branch_target_ex = pc_ex + imm_out_ex;

    ex_mem_register ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .flush(ex_mem_flush), // Agora usa o sinal de flush do branch
        .regwrite_in(regwrite_ex),
        .mem_read_in(mem_read_ex),
        .mem_write_in(mem_write_ex),
        .mem_to_reg_in(mem_to_reg_ex),
        .branch_in(branch_ex),
        .alu_result_in(alu_result_ex),
        .branch_target_in(branch_target_ex),
        .write_data_in(forwarded_data_b), // Dado para Store (sh)
        .rd_in(rd_ex),
        .zero_flag_in(zero_flag_ex),
        .regwrite_out(regwrite_mem),
        .mem_read_out(mem_read_mem),
        .mem_write_out(mem_write_mem),
        .mem_to_reg_out(mem_to_reg_mem),
        .branch_out(branch_mem),
        .alu_result_out(alu_result_mem),
        .branch_target_out(branch_target_mem),
        .write_data_out(write_data_mem),
        .rd_out(rd_mem),
        .zero_flag_out(zero_flag_mem)
    );

    //================================================================
    // Estágio MEM - Acesso à Memória
    //================================================================
    data_memory data_mem (
        .clk(clk),
        .reset(reset),
        .address(alu_result_mem),
        .write_data(write_data_mem),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .size(2'b01), // Simplificado para halfword (lh, sh)
        .unsigned_load(1'b0), // Simplificado para signed (lh)
        .read_data(mem_read_data_mem)
    );

    assign branch_taken_mem = branch_mem & zero_flag_mem;
    

    mem_wb_register mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),
        .regwrite_in(regwrite_mem),
        .mem_to_reg_in(mem_to_reg_mem),
        .mem_read_data_in(mem_read_data_mem),
        .alu_result_in(alu_result_mem),
        .pc_plus_4_in(32'b0), // Conectar se JAL for implementado
        .rd_in(rd_mem),
        .regwrite_out(regwrite_wb),
        .mem_to_reg_out(mem_to_reg_wb),
        .mem_read_data_out(mem_read_data_wb),
        .alu_result_out(alu_result_wb),
        .pc_plus_4_out(pc_plus_4_wb),
        .rd_out(rd_wb)
    );

    //================================================================
    // Estágio WB - Write Back
    //================================================================
    mux_writeback wb_mux (
        .alu_result(alu_result_wb),
        .mem_data(mem_read_data_wb),
        .pc_plus_4(pc_plus_4_wb),
        .immediate(32'b0), // Não usado
        .mem_to_reg(mem_to_reg_wb),
        .write_data(write_data_wb)
    );

    //================================================================
    // Bloco de DEBUG: Rastreamento do sinal RegWrite
    //================================================================

endmodule