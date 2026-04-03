module hazard_detection_unit(
    input [4:0] rd_addr_ex,rs1_addr_id,rs2_addr_id,
    input mem_en_ex,mem_rd_or_wr_bar_ex,
    output reg stall 
);
    wire is_load_ex = mem_en_ex & mem_rd_or_wr_bar_ex; // load instruction in EX stage
    always @(*) begin
        // default value
        stall = 1'b0;
        if(is_load_ex & (rd_addr_ex != 5'd0) & ((rd_addr_ex == rs1_addr_id) | (rd_addr_ex == rs2_addr_id)))begin
            stall = 1'b1;
        end
        else begin
            stall = 1'b0;
        end

        
    end
endmodule