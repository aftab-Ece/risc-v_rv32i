//=================================================================================||
// File Name: instr_mem.v                                                          ||
// Purpose: Instruction Memory Module for RISC-V                                   ||
// description: This module implements a simple instruction                        ||
// memory for the RISC-V processor. It supports synchronous                        ||
// read operations. The memory is initialized from a hex file.                     ||
// this is a parametrized module with address width, data width                    ||
// and depth as parameters. by default it has a total capacity of 512 bytes.       ||
// endianness: little-endian                                                       ||
//=================================================================================||




module instr_mem #(
    parameter addr_width = 9,
    parameter data_width = 32,
    parameter depth = 512
)(
    input [addr_width-1:0] addr,
    input clk,
    // input [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out
);
    reg [data_width-1:0] mem [0:depth-1];
    initial begin
        $readmemh("instr_mem.mem", mem);
    end
    always @(posedge clk) begin
        data_out <= {mem[addr]};
        
    end
endmodule