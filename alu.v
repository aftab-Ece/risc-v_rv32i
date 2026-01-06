module alu#(
    parameter width = 32
)(
    input [width-1:0] a,
    input [width-1:0] b,
    input [3:0] alu_control,
    output reg [width-1:0] result,
    output zero
);

reg a_sign;
always @(*) begin
    case (alu_control)
        4'b0000: result = a & b; // AND
        4'b0001: result = a | b; // OR
        4'b0010: result = a + b; // ADD
        4'b0011: result = a - b; // SUB
        4'b0100: result = (a < b) ? 1 : 0; // SLTu
        4'b0101: begin //slt
        if(a[width-1]==b[width-1])
            result = (a < b) ? 1 : 0;
        else if(a[width-1]==1'b1 && b[width-1]==1'b0)
            result = 1;
        else
            result = 0;
        end
        4'b0110: result = ~(a | b); // NOR
        4'b0111: result = a ^ b; // XOR
        4'b1000: result = a << b[4:0]; // SLL
        4'b1001: result = a >> b[4:0]; // SRL
        4'b1010: result = $signed(a) >>> b[4:0]; // SRA
        default: result = {width{1'b0}}; // Default case
    endcase
end
assign zero = (result == 0) ? 1'b1 : 1'b0;
endmodule