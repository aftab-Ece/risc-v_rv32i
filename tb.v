module tb;
    reg [31:0] a, b;
    reg [3:0] alu_control;
    wire [31:0] out;
    wire zero;

    alu #( .width(32) ) uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(out),
        .zero(zero)
    );
    initial begin
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0000; //AND
        #10;
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0001; //OR
        #10;
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0010; //ADD
        #10;
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0011; //SUB
        #10;
        a=32'h00000003; b=32'h0000000F; alu_control=4'b0100; //SLT
        #10;
        a=32'hFFFFFFFF; b=32'h0000000F; alu_control=4'b0101; //SLT
        #10;
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0110; //NOR
        #10;
        a=32'h0000000F; b=32'h00000003; alu_control=4'b0111; //XOR
        #10;
        a=32'h0000000F; b=32'h00000002; alu_control=4'b1000; //SLL
        #10;
        a=32'h0000000F; b=32'h00000002; alu_control=4'b1001; //SRL
        #10;
        a=32'hFFFFFFF0; b=32'h00000002; alu_control=4'b1010; //SRA
        #10;
        a=32'h80000000; b=32'h00000001; alu_control=4'b0010; //ADD overflow test
        #10;
        a=32'h7FFFFFFF; b=32'h00000001; alu_control=4'b0010; //ADD overflow test
        #10;
        a=32'h80000000; b=32'hFFFFFFFF; alu_control=4'b0011; //SUB overflow test
        #10;
        a=32'h7FFFFFFF; b=32'hFFFFFFFF; alu_control=4'b0011; //SUB overflow test
        #10;
        a=32'h00000000; b=32'h00000000; alu_control=4'b0011; //ZERO test
        #10;
        a=32'h00000005; b=32'h00000003; alu_control=4'b0101; //SLT test
        #10;
        a=32'hFFFFFFFC; b=32'h00000003; alu_control=4'b0101; //SLT test
        #20;
        $finish;
    end
    // Clock generation
    always begin
        #5;
        $monitor("Time=%0d : a=%h, b=%h, alu_control=%b => result=%h, zero=%b", $time, a, b, alu_control, out, zero);
   
    end
    initial begin
         $dumpfile("tb.vcd");
         $dumpvars(0, tb);
   
    end
endmodule