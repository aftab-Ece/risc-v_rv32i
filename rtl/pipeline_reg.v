module pipeline_reg #(
    parameter width=32,
              reset=32'b0 
)(
    input [width-1:0] in,
    input clk,en,rst,flush,
    output wire [width-1:0] out
);
reg [width-1:0] out_reg;
assign out = out_reg;
always @(posedge clk)begin
    if(rst || flush) out_reg <= reset;
    else if(en) out_reg <= in;

    else out_reg <= out_reg;
end
endmodule