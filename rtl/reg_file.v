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
    
    integer fd, fd2;
    initial begin
        fd = $fopen("reg.log", "w");
        fd2 = $fopen("reg_file_current_state.log", "w");
        if (fd == 0) begin
            $display("ERROR: Could not open data_mem_write.log");
            $finish;
        end
        if (fd2 == 0) begin
            $display("ERROR: Could not open reg_file_current_state.log");
            $finish;
        end
    end
    
   assign rs1_data = (rs1_addr == 0) ? 32'h0 : (reg_write && rd_addr != 0 && rd_addr == rs1_addr) ? rd_data : reg_array[rs1_addr];
   assign rs2_data = (rs2_addr == 0) ? 32'h0 : (reg_write && rd_addr != 0 && rd_addr == rs2_addr) ? rd_data : reg_array[rs2_addr];

    always @(posedge clk) begin
        if (reg_write && rd_addr != 0) begin
            reg_array[rd_addr] <= rd_data;
             $fwrite(fd,"Time:%0t | rd_data:0x%h | rd_addr:0x%h |rs1_data:0x%h | rs1_addr:0x%h |rs2_data:0x%h | rs2_addr:0x%h \n",$time,rd_data,rd_addr,rs1_data,rs1_addr,rs2_data,rs2_addr);
            $fwrite(fd2,"Time:%0t | Register File State: ",$time);
            for (integer i = 0; i < depth; i = i + 1) begin
                $fwrite(fd2,"Reg[%0d]:0x%h  \n",i,reg_array[i]);

            end
            $fwrite(fd2,"\n");
        end
    end
endmodule