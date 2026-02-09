//=======================================================================|
//module name: control unit                                              |
//creation date: 10-01-2026                                              |
//last modification date: 10-01-2026                                     |
//functionality: this is a control for a multi cycle rv32i implementation|
// it has 2 modules inside it, a combinational instruction decoder and an|                                                            
// fsm to select the appropriate control signal based on the current state|                                                                      
// of execution cycle. wire which have a suffix "_internal" are used for  |                                                                   
// interfacing with the decoder module and subsequently the controller    |                                                                      
// selects the appropriate control signal or 0 based on current state     |                                                                   
// through a mux.                                                         |



module control_unit (
    input [6:0] opcode,funct7,
    input [2:0] funct3,
    input clk,reset,debug_en,
    output wire alu_in_sel,reg_write_en,mem_en,mem_rd_or_wr_bar,pc_write,reg_write_sel,is_branch,is_jump,sign_ext_sel_20bit,
    output wire [1:0] sign_ext_sel_12bit,
    output wire [3:0] alu_control
);
parameter fetch=3'b000,
          decode=3'b001,
          execute=3'b010,
          mem=3'b011,
          wb=3'b100;
// why added wb state ? to have a separate state for write back to avoid any hazards . as i cant merge it
// with mem state because some instruction like load need mem state for memory access and then write back
// but some instruction like arithmetic dont need mem state at all and go directly to write back from execute state
reg [2:0]curr_state;
wire in_fetch, in_decode, in_execute, in_mem, in_wb;
// these signals will be high when in respective states so that we can use them in combinational logic
// to generate control signals
wire alu_sel_internal,reg_write_sel_internal,reg_write_en_internal,mem_en_internal,is_jump_internel,
     mem_rd_or_wr_bar_internal,is_brach_internal,sign_ext_sel_20bit_internal;
wire [1:0] sign_ext_sel_12bit_internal;
wire [3:0] alu_control_internal;
assign in_fetch=(curr_state==fetch)?1'b1:1'b0;
assign in_decode=(curr_state==decode)?1'b1:1'b0;
assign in_execute=(curr_state==execute)?1'b1:1'b0;
assign in_mem=(curr_state==mem)?1'b1:1'b0;
assign in_wb=(curr_state==wb)?1'b1:1'b0;
instruction_decoder instr_dec(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .alu_in_sel(alu_sel_internal),
    .reg_write_en(reg_write_en_internal),
    .reg_write_sel(reg_write_sel_internal),
    .mem_en(mem_en_internal),
    .mem_rd_or_wr_bar(mem_rd_or_wr_bar_internal),
    .sign_ext_sel_12bit(sign_ext_sel_12bit_internal),
    .is_branch(is_branch_internal),
    .alu_control(alu_control_internal),
    .is_jump(is_jump_internal),
    .sign_ext_sel_20bit(sign_ext_sel_20bit_internal)
    
);
    assign alu_control=((in_execute|in_mem|in_wb)&(~debug_en))?alu_control_internal:4'b0000;
    assign alu_in_sel=((in_execute|in_mem|in_wb)&(~debug_en))?alu_sel_internal:1'b0;
    assign reg_write_sel=((in_wb)&(~debug_en))?reg_write_sel_internal:1'b0;
    assign reg_write_en=((in_wb)&(~debug_en))?reg_write_en_internal:1'b0;
    assign mem_en=((in_mem|in_wb)&(~debug_en))?mem_en_internal:1'b0;
    assign mem_rd_or_wr_bar=((in_mem|in_wb)&(~debug_en))?mem_rd_or_wr_bar_internal:1'b0;
    assign sign_ext_sel_12bit=((in_decode|in_execute|in_mem|in_wb)&(~debug_en))?sign_ext_sel_12bit_internal:2'b0;
    assign pc_write=(in_wb&(~debug_en))?1'b1:1'b0;
    assign is_branch=((in_execute|in_mem|in_wb)&(~debug_en))? is_branch_internal:1'b0;
    assign is_jump=((in_execute|in_mem|in_wb)&(~debug_en))? is_jump_internal:1'b0;
    assign sign_ext_sel_20bit=((in_decode|in_execute|in_mem|in_wb)&(~debug_en))?sign_ext_sel_20bit_internal:1'b0;
    always @(posedge clk) begin

        if(reset)begin
            curr_state<=fetch;
        end
        else begin
            case (curr_state)
            fetch: begin
            if(!debug_en) curr_state<=decode;
            end
            decode:
            begin
            if(!debug_en) curr_state<=execute;
            end
            execute:begin
            if(!debug_en) curr_state<=mem;
            end
            mem:begin
            if(!debug_en) curr_state<=wb;
            end
            wb:begin
            if(!debug_en) curr_state<=fetch;
            end


            endcase
        end
    end

endmodule 