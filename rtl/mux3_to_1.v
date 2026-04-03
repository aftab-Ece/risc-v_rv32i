module mux3_to_1 #(
    parameter width = 32)(
    input [width-1:0] a, // First input for the multiplexer
    input [width-1:0] b, // Second input for the multiplexer
    input [width-1:0] c, // third input for the multiplexer
    input [1:0] sel, // Select signal to choose between in1 and in2
    output reg [width-1:0] out // Output of the multiplexer
);

always @(*)begin
    case(sel)
    2'b00: out=a;
    2'b01: out=b;
    2'b10: out=c;
    default: out=0;
    endcase
end

endmodule
