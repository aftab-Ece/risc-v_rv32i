module sign_extender#(
    parameter input_width=12
)(
    input [input_width-1:0] in,
    output wire [31:0] out
);
//this sign extends a parameterized input to 32 bits
   assign out= in[input_width-1]? {{(32-input_width){1'b1}},in} : {{(32-input_width){1'b0}},in} ;
endmodule