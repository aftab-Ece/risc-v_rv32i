module branch_handler(
    input [2:0] funct3,
    input is_zero,alu_result_lsb,is_branch,
    output wire branch_taken
);
localparam beq = 3'b000,
           bne = 3'b001,
           blt = 3'b100,
           bge = 3'b101,
           bltu = 3'b110,
           bgeu = 3'b111;
reg branch_signal;
assign branch_taken=is_branch & branch_signal;
always @(*)begin
case(funct3)
    beq: branch_signal=(is_zero==1);
    bne: branch_signal=(is_zero==0);
    blt: branch_signal=(alu_result_lsb==1);
    bge: branch_signal=(alu_result_lsb==0);
    bltu: branch_signal=(alu_result_lsb==1);
    bgeu: branch_signal=(alu_result_lsb==0);
    default:branch_signal=0;
endcase
end
endmodule