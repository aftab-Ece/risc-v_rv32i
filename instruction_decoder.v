module instruction_decoder (
    input [6:0] opcode,funct7,
    input [2:0] funct3,
    output reg alu_in_sel,reg_write_en,mem_en,mem_rd_or_wr_bar,reg_write_sel,is_branch,is_jump,sign_ext_sel_20bit,
    output reg [1:0] sign_ext_sel_12bit,
    output reg [3:0] alu_control
);

 always @(*)begin
       reg_write_en=1'b0;
        alu_in_sel=1'b0;
        mem_en=1'b0;
        mem_rd_or_wr_bar=1'b0;
        sign_ext_sel_12bit=2'b0;
        reg_write_sel=1'b0;
        is_branch=1'b0;
        alu_control=4'b0000;
        is_jump=1'b0;
        sign_ext_sel_20bit=1'b0;
        case (opcode)
        7'b0110011:begin // r-type
        // all r-type instructions have same control signals except alu_control
        reg_write_en=1'b1;
        alu_in_sel=1'b0;
        mem_en=1'b0;
        mem_rd_or_wr_bar=1'b0;
        sign_ext_sel_12bit=2'b0;
        reg_write_sel=1'b0;
            case(funct7)
            7'b0000000:begin
                case(funct3)
                3'b000:begin
                    // add
                    alu_control=4'b0010; // add
                end
                3'b001:begin
                    // sll
                    alu_control=4'b1000; //sll control signal in alu
                end
                3'b010:begin
                    //slt
                    alu_control=4'b0101; //slt control signal in alu
                end
                3'b011:begin
                    //sltu
                    alu_control=4'b0100; //sltu control signal in alu
                end
                3'b100:begin
                    //xor
                    alu_control=4'b0111; //xor control signal in alu
                end
                3'b101:begin
                    //srl
                    alu_control=4'b1001; //srl control signal in alu
                end
                3'b110:begin
                    //or
                    alu_control=4'b0001; //or control signal in alu
                end
                3'b111:begin
                    //and
                    alu_control=4'b0000; //and control signal in alu
                end
            endcase
            end
            7'b0100000:begin
                case(funct3)
                3'b000:begin
                    //sub
                    alu_control=4'b0011; // subtract control signal in alu
                end
                3'b101:
                begin
                    //sra
                    alu_control=4'b1010; //sra control signal in alu
                end
        endcase
            end
        endcase
        end
        7'b0000011:begin // load instructions (i-type)
        reg_write_en=1'b1;
        alu_in_sel=1'b1; // immediate
        mem_en=1'b1;
        mem_rd_or_wr_bar=1'b1; // read
        sign_ext_sel_12bit=2'b0; // i-type
        reg_write_sel=1'b1; // write back from memory
        alu_control=4'b0010; // add for effective address calculation
        end
        7'b0010011:begin // immediate arithmetic instructions (i-type)
        reg_write_en=1'b1; // load the result into register
        alu_in_sel=1'b1; // sign extended immediate select
        mem_en=1'b0; // memory operations not required
        mem_rd_or_wr_bar=1'b0; // memory operations not required as simple arithmetic
        sign_ext_sel_12bit=2'b00;// i-type
        reg_write_sel=1'b0;
        case(funct3)
        3'b000:begin // addi
            alu_control=4'b0010;
        end
        3'b001:begin //slli
            alu_control=4'b1000;
        end
        3'b010:begin //slti
            alu_control=4'b0101;
        end
        3'b011:begin //sltiu
           alu_control=4'b0100;
        end
        3'b100:begin //xori
          alu_control=4'b0111;
        end
        3'b101:begin // srli and srai
        case(funct7)
        7'b0000000: alu_control=4'b1001; // srli
        7'b0100000: alu_control=4'b1010; //srai
        endcase
        end
        3'b110:begin //ori
           alu_control=4'b0001;
        end
        3'b111:begin //andi
           alu_control=4'b0000;
        end
        endcase
        end

        7'b1100111: begin // jump instruction (i-type encoding jalr)
        reg_write_en=1'b1;
        alu_in_sel=1'b1; // immediate
        mem_en=1'b0;
        mem_rd_or_wr_bar=1'b0; 
        sign_ext_sel_12bit=2'b00; // I-type
        reg_write_sel=1'b0; // no write back 
        alu_control=4'b0010; // add for effective address calculation
        is_jump=1'b1;
        end

        7'b1101111:begin// jump instruction( UJ type encoding jal)
        reg_write_en=1'b1;
        alu_in_sel=1'b1; // immediate
        mem_en=1'b0;
        mem_rd_or_wr_bar=1'b0; 
        sign_ext_sel_12bit=2'b00; // uj_type
        sign_ext_sel_20bit=1'b1;
        reg_write_sel=1'b0; // no write back 
        alu_control=4'b0010; // add for effective address calculation
        is_jump=1'b1;
        end

        7'b0100011:begin // s-type
        reg_write_en=1'b0;
        alu_in_sel=1'b1; // immediate
        mem_en=1'b1;
        mem_rd_or_wr_bar=1'b0; // write
        sign_ext_sel_12bit=2'b01; // s-type
        reg_write_sel=1'b0; // no write back 
        alu_control=4'b0010; // add for effective address calculation
        end

        7'b1100011:begin // SB type instructions for branch
        reg_write_en=1'b0;
        alu_in_sel=1'b0; // rs2 is selected for alu 
        mem_en=1'b0;
        mem_rd_or_wr_bar=1'b0; //no write
        sign_ext_sel_12bit=2'b10; // SB-type
        reg_write_sel=1'b0; // no write back
        is_branch=1'b1;
        case(funct3)
        3'b000,3'b001: alu_control= 4'b0010;
        3'b100,3'b101: alu_control= 4'b0101;
        3'b110,3'b111: alu_control= 4'b0100;
        endcase 
        end


        endcase
    end

endmodule