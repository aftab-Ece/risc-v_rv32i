//=============================================================\\
// File Name: reg_file.v                                        \\
// Purpose: Register File Module for RISC-V Processor            \\
// description: This module implements a register file with 32    \\
// registers, each 32 bits wide. It supports reading from two      \\
// registers and writing to one register on the rising edge of the  \\
// writes to register 0 are ignored as it is hardwired to 0.         \\
// writes are clocked , while reads are combinational.                \\
//=====================================================================\\




module regfile#(
    parameter reg_width = 32,
    parameter addr_width = 5,
    parameter depth = 32
)(
    input clk, // clock signal
    input [addr_width-1:0] rs1_addr, rs2_addr,rd_addr,
    input [reg_width-1:0] rd_data,
    input reg_write,
    output wire [reg_width-1:0] rs1_data,rs2_data
);
    reg [reg_width-1:0] reg_array [0:depth-1];
    integer i;
    initial begin
        for (i = 0; i < depth; i = i + 1) begin
            reg_array[i] = 0;
        end
    end
    assign rs1_data = reg_array[rs1_addr];
    assign rs2_data = reg_array[rs2_addr];
    always @(posedge clk) begin
        if (reg_write && rd_addr != 0) begin
            reg_array[rd_addr] <= rd_data;
        end
    end
endmodule