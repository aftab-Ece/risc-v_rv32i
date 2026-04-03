module load_unit #(
    parameter data_width=32
)(  
    input [data_width-1:0] mem_data,
    input [2:0] funct3,
    input [1:0] addr_lsb,
    input mem_rd_or_wr_bar,
    output reg [data_width-1:0] lsu_out
);
reg [7:0] byte_sel;
reg [15:0] halfword_sel;

    always @(*)begin
        if(mem_rd_or_wr_bar)begin// for aligning loads based on lower 2 bits of addresses and funct3
    case (funct3)
    3'b000,3'b100: begin//lb // lbu
        case (addr_lsb)
            2'b00: byte_sel = mem_data[7:0]; 
            2'b01: byte_sel = mem_data[15:8];
            2'b10: byte_sel = mem_data[23:16];
            2'b11: byte_sel = mem_data[31:24];
        endcase

        lsu_out = funct3[2] ? {24'b0,byte_sel} : // unsigned
                            {{24{byte_sel[7]}},byte_sel};// signed
    end
    3'b001,3'b101: begin//lh // lhu
    case (addr_lsb)
        2'b00: halfword_sel = mem_data[15:0];
        2'b10: halfword_sel = mem_data[31:16];
    endcase
    lsu_out = funct3[2] ? {16'b0,halfword_sel} : // unsigned
                        {{16{halfword_sel[15]}},halfword_sel};// signed
    end
    3'b010: 
        lsu_out = mem_data;//lw
    default: begin
        lsu_out = mem_data;
    end
     endcase
    end
    end
    
endmodule