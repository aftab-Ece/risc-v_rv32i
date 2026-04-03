module mux #(
    parameter width = 32)(
    input [width-1:0] a, // First input for the multiplexer
    input [width-1:0] b, // Second input for the multiplexer
    input sel, // Select signal to choose between in1 and in2
    output wire [width-1:0] out // Output of the multiplexer
);

    assign out = sel ? b : a; // Output is in2 if select is high, otherwise in1

endmodule
