module datapath #(
    parameter width=32,
              instr_mem_addr_width=9,
              instr_mem_depth=512,
                regfile_depth=32,
                data_width=32,
                data_mem_depth=512,
                data_mem_addr_width=9

    )(
        input clk,reset,alu_in_sel,pc_write,mem_enable,mem_rd_wr_bar,reg_write,reg_write_sel,
              imm_sel,// for immediate selection(I-type or S-type)
        
        input debug_pc, // for debugging purpose
        input [4:0] regfile_debug_addr, // for debugging purpose
        output [width-1:0] debug_regfile_data, // for debugging purpose

        output [6:0] opcode, // opcode for control unit
        output [2:0] funct3, // funct3 for control unit
        output [6:0] funct7  // funct7 for control unit
    );
    // internal signals 
    wire [width-1:0] pc_next,pc_curr,instr,rs1_data,rs2_data,alu_in2,alu_result,
                     mem_data,sign_ext_imm,alu_in1, regfile_data;
    wire [4:0] rs1_addr,rs2_addr,rd_addr;
    wire [3:0] alu_control;
    wire [11:0] imm_12_i_type,imm_12_s_type,imm_12;
    wire alu_zero_flag;
    assign opcode = instr[6:0]; // opcode for control unit
    assign funct3 = instr[14:12]; // funct3 for control unit
    assign funct7 = instr[31:25]; // funct7 for control unit
    assign rs1_addr = debug_pc ? regfile_debug_addr :  instr[19:15];
       // rs1 address(if debug_pc is high, use debug address this way we can read any register
       // value by external register address) 

    assign rs2_addr = instr[24:20]; // register source 2 address
    assign rd_addr = instr[11:7]; // register destination address 
    assign alu_in1= rs1_data; // ALU input 1 is always from rs1_data
    assign debug_regfile_data = rs1_data ; // for debugging purpose
    // immediate extraction
    assign imm_12_i_type = instr[31:20];
    assign imm_12_s_type = {instr[31:25],instr[11:7]};
    assign imm_12 = instr_type ? imm_12_s_type : imm_12_i_type;
    assign alu_in2 = alu_in_sel ? sign_ext_imm : rs2_data;
    assign regfile_data = reg_write_sel ? mem_data : alu_result;
    // pc register
    pipo_reg #(width) PC (
        .clk(clk),
        .reset(reset),
        .en(pc_write),
        .in(pc_next),
        .out(pc_curr)
    );
    //instruction memory
    instr_mem #(
        .addr_width(instr_mem_addr_width),
        .data_width(data_width),
        .depth(instr_mem_depth)
    ) IM (
        .clk(clk),
        .addr(pc_curr[9:0]), 
        .data_out(instr)
    );
    //register file
    regfile #(
        .reg_width(width),
        .addr_width(5),
        .depth(regfile_depth)
    ) RF (
        .clk(clk),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(regfile_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    // sign extension unit
    sign_extender #(
        .input_width(12),
    ) sign_extender_module (
        .in(imm_12),
        .out(sign_ext_imm)
    );
    // ALU
    alu #(
        .width(width)
    ) ALU(
        .a(alu_in1),
        .b(alu_in2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero_flag)
    );
    // lsu
    load_store_unit #(
        data_width=width
    ) lsu( 
        .mem_data(mem_data)
        .funct3(funct3),
        .addr_lsb(alu_result[1:0]),
        .mem_rd_or_wr_bar(mem_rd_wr_bar),
        .we(we),
        .lsu_out(lsu_out)
    );
    // data memory
    data_mem #(
        .addr_width(data_mem_addr_width),
        .data_width(data_width),
        .depth(data_mem_depth)
    ) DM (
        .clk(clk),
        .addr(alu_result[9:2]), // word aligned addressing
        .enable(mem_enable),
        .rd(~mem_rd_or_wr_bar),
        // going to handle it later // write enable is active when mem_enable is high and mem_rd_or_wr_bar is low
        .we(we),
        .data_in(rs2_data),
        .data_out(mem_data)
    );


endmodule