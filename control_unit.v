module control_unit #(
    parameter width=0
)(
    input [6:0] opcode,funct7,
    input [2:0] funct3,
    input clk,reset,
    output reg alu_sel,reg_write,mem_en,mem_rd_or_wr,reg_sel,pc_write
);
parameter fetch=3'b000,
          decode=3'b001,
          execute=3'b010,
          mem=3'b011,
          write_back=3'b100;
          reg [2:0]state;

    always @(posedge clk) begin
        if(reset)begin
            
        end
        else begin
            
        end
    end
endmodule 