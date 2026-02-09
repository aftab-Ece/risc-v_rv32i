module processor(
    input debug_en,clk,reset,
    input [4:0] regfile_debug_addr,
    output [31:0] debug_regfile_data
);
wire [6:0] opcode, funct7;
wire [2:0] funct3;
wire alu_in_sel,reg_write_en,mem_en,mem_rd_or_wr_bar,pc_write,reg_write_sel,is_branch,is_jump,sign_ext_sel_20bit;
wire [1:0] sign_ext_sel_12bit;
wire [3:0] alu_control;
control_unit cu(
    .clk(clk),
    .reset(reset),
    .debug_en(debug_en),
    .funct3(funct3),
    .funct7(funct7),
    .opcode(opcode),
    .alu_in_sel(alu_in_sel),
    .reg_write_en(reg_write_en),
    .reg_write_sel(reg_write_sel),
    .mem_en(mem_en),
    .mem_rd_or_wr_bar(mem_rd_or_wr_bar),
    .sign_ext_sel_12bit(sign_ext_sel_12bit),
    .alu_control(alu_control),
    .pc_write(pc_write),
    .is_branch(is_branch),
    .is_jump(is_jump),
    .sign_ext_sel_20bit(sign_ext_sel_20bit)
);
datapath #(
    .width(32),
    .instr_mem_addr_width(9),
    .instr_mem_depth(512),
    .regfile_depth(32),
    .data_width(32),
    .data_mem_depth(512),
    .data_mem_addr_width(9)
) dp(
    .clk(clk),
    .reset(reset),
    .debug_en(debug_en),
    .alu_in_sel(alu_in_sel),
    .pc_write(pc_write),
    .reg_write_en(reg_write_en),
    .reg_write_sel(reg_write_sel),
    .mem_enable(mem_en),
    .mem_rd_wr_bar(mem_rd_or_wr_bar),
    .sign_ext_sel_12bit(sign_ext_sel_12bit),
    .alu_control(alu_control),
    .funct3(funct3),
    .funct7(funct7),
    .opcode(opcode),
    .regfile_debug_addr(regfile_debug_addr),
    .debug_regfile_data(debug_regfile_data),
    .is_branch(is_branch),
    .is_jump(is_jump),
    .sign_ext_sel_20bit(sign_ext_sel_20bit)
);
endmodule