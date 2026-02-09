module pc_adder #(
    parameter width=32
)(
    input [width-1:0] curr_pc,offset,
    output wire [width-1:0] pc_next
);
assign pc_next=curr_pc+ offset;
endmodule