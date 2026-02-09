module data_mem #(
    parameter
    addr_width = 9,
    data_width = 32,
    depth = 512
)(
    input [addr_width-1:0] addr,
    input clk,rd,enable,
    input [3:0] we,
    input [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out
);
    reg [data_width-1:0] mem [0:depth-1];
    reg [addr_width-1:0] addr_reg;
        integer fd,i;

    initial begin
        fd = $fopen("data_mem_write.log", "w");
        if (fd == 0) begin
            $display("ERROR: Could not open data_mem_write.log");
            $finish;
        end
    end
    always @(posedge clk) begin
        if(enable)begin
        addr_reg<=addr;
        if(!rd)begin
        if (we[0]) mem[addr][7:0] <= data_in[7:0];
        if (we[1]) mem[addr][15:8] <= data_in[15:8];
        if (we[2]) mem[addr][23:16] <= data_in[23:16];
        if (we[3]) mem[addr][31:24] <= data_in[31:24]; 
        
         $fwrite(fd,
                "TIME=%0t | ADDR=0x%h | DATA=0x%h | we:0x%b |net data :0x%h | data_in:0x%h \n",
                $time, addr, data_in[7:0],we,mem[addr],data_in
            );
        end
        if(rd)
        data_out <= mem[addr_reg];
        end
    end
endmodule
