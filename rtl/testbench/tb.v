`timescale 1ns/1ps
module tb;
   reg clk,rst,debug_en;
   reg [4:0] regfile_debug_addr;
   wire [31:0] debug_regfile_data,pc,wb_data,alu_res,instr,pc_id,pc_ex,pc_mem,pc_wb,dm_in,dm_out;
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
    .reset(rst),
    .debug_en(debug_en),
    .regfile_debug_addr(regfile_debug_addr),
    .debug_regfile_data(debug_regfile_data),
    .debug_pc(pc)
    //.debug_pc_id(pc_id),
);
  
   

    initial begin
        clk=1'b0;
        forever #5 clk=~clk;
    end
    initial begin
       #2 rst=1;debug_en=0;
       #10 rst=0;
    #6610;
    debug_en=1;
    regfile_debug_addr=5'h0a;
    #20;
        $finish;
    end
    // Clock generation
    
    initial begin
         $dumpfile("tb.vcd");
         $dumpvars(0, tb);
   
    end
endmodule