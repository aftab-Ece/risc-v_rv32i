module tb;
   reg clk,rst,debug_en;
  processor cpu(
    .clk(clk),
    .reset(rst),
    .debug_en(1'b0),
    .debug_regfile_data(),
    .regfile_debug_addr()
  );
  
   

    initial begin
        clk=1'b0;
        forever #5 clk=~clk;
    end
    initial begin
       #2 rst=1;
       #10 rst=0;
    #3000;
        $finish;
    end
    // Clock generation
    
    initial begin
         $dumpfile("tb.vcd");
         $dumpvars(0, tb);
   
    end
endmodule