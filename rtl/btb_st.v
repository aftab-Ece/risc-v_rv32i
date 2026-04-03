module btb_st #(
    parameter tag_width=25,
    parameter pc_width=32,
    parameter btb_depth=32,
    parameter btb_addr_width=5
) (
    input clk,valid,update,rst,
    input [pc_width-1:0] pred_pc,
    input [tag_width-1:0] tag_in,
    input [btb_addr_width-1:0] index_in
    output wire [pc_width-1:0] pred_pc_out,
    output wire valid_out
);
    reg [tag_width+pc_width-1:0] btb_array [btb_depth-1:0];// {tag,pc}
    reg valid_array [btb_depth-1:0];
    integer i;
    always @(posedge clk ) begin
        if(rst) begin
            for(i=0; i<btb_depth; i=i+1) begin
                btb_array[i] <= 0;
                valid_array[i] <= 1'b0;
            end
        end else if(update) begin
            btb_array[index_in] <= {tag_in,pred_pc};
            valid_array[index_in] <= 1'b1;
        end

    end
endmodule