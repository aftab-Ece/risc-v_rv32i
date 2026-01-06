module pipo_reg #(
    parameter width=32
              pc_reset_address=32'b0 // default reset address can be overriden to any value
)(
    input [width-1:0] in,
    input clk,en,rst,
    output wire [width-1:0] out
);
reg [width-1:0] out_reg;
assign out = out_reg;
always @(posedge clk)begin
    if(rst) out_reg <= pc_reset_address;
    else if(en) out_reg <= in;

    else out_reg <= out_reg;
end
endmodule