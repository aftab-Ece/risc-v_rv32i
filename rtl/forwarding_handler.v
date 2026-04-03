module forwarding_handler # (
    parameter width = 32,
    parameter reg_addr_width = 5
)(
    input [reg_addr_width-1:0] rd_addr_mem,rs1_addr_ex,rs2_addr_ex,rd_addr_wb,
    input reg_write_en_mem,reg_write_en_wb,
    output reg [1:0] forward_in1,forward_in2
);
    localparam forward_none = 2'b00,
                forward_from_mem = 2'b01,
                forward_from_wb = 2'b10;
    always @(*) begin
        // default values
        forward_in1 = forward_none;
        forward_in2 = forward_none;
        // forwarding for rs1
        if(reg_write_en_mem & (rd_addr_mem != 0) & (rd_addr_mem == rs1_addr_ex))begin
            forward_in1 = forward_from_mem;
        end
        else if(reg_write_en_wb & (rd_addr_wb != 0) & ~(reg_write_en_mem & (rd_addr_mem != 0) & (rd_addr_mem == rs1_addr_ex)) & (rd_addr_wb == rs1_addr_ex) )begin
            forward_in1 = forward_from_wb;
        end
        else begin
            forward_in1 = forward_none;
        end
        // forwarding for rs2
        if(reg_write_en_mem & (rd_addr_mem != 0) & (rd_addr_mem == rs2_addr_ex))begin
            forward_in2 = forward_from_mem;
        end
        else if(reg_write_en_wb & (rd_addr_wb != 0) & ~(reg_write_en_mem & (rd_addr_mem != 0) & (rd_addr_mem == rs2_addr_ex)) & (rd_addr_wb == rs2_addr_ex) )begin
            forward_in2 = forward_from_wb;
        end
        else begin
            forward_in2 = forward_none;
        end
    end
endmodule
    
