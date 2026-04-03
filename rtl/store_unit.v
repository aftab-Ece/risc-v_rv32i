module store_unit #(
    parameter data_width=32
)(  
    input [2:0] funct3,
    input [1:0] addr_lsb,
    input mem_rd_or_wr_bar,
    input [data_width-1:0] data_in,
    output reg [data_width-1:0] mem_shifted_store_data,
    output reg [3:0] we
);
reg [7:0] byte_sel;
reg [15:0] halfword_sel;

always @(*)begin
    // default values
    we = 4'b0000;
    byte_sel = 8'b0;
    halfword_sel = 16'b0;
    mem_shifted_store_data=32'b0;
    if (!mem_rd_or_wr_bar)begin// for aligning stores based on lower 2 bits of addresses and funct3
    case (funct3)
    3'b000: begin//sb
    case (addr_lsb)
        2'b00:begin  we = 4'b0001; mem_shifted_store_data = data_in<<0; end
        2'b01:begin  we = 4'b0010; mem_shifted_store_data= data_in<<8; end
        2'b10:begin  we = 4'b0100;mem_shifted_store_data= data_in<<16; end
        2'b11:begin  we = 4'b1000;mem_shifted_store_data= data_in<<24 ;end
        default:begin  we = 4'b0000;mem_shifted_store_data= data_in<<0 ;end 
    endcase
    end
    3'b001: begin//sh
    case (addr_lsb)
        2'b00:begin  we =4'b0011; mem_shifted_store_data= data_in<<0 ;end
        2'b10:begin  we =4'b1100; mem_shifted_store_data= data_in<<16 ;end
        default: we = 4'b0000;
    endcase
    end
    3'b010: begin//sw
        we = 4'b1111;
        mem_shifted_store_data= data_in<<0;
    end
    endcase
    end
end
endmodule