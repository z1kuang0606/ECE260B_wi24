// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_1, mem_in_1, inst_1 , reset_1, out_1, clk_en_1, clk_2, mem_in_2, inst_2, reset_2, out_2, clk_en_2,
                 clk_3, mem_in_3, inst_3 , reset_3, out_3, clk_en_3, clk_4, mem_in_4, inst_4, reset_4, out_4, clk_en_4);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+3;
parameter pr = 8; //8 elements in one vector

input  clk_1; 
input  [pr*bw-1:0] mem_in_1; 
input  [22:0] inst_1; 
input  reset_1;
output [bw_psum*col-1:0] out_1;
input  [5:0] clk_en_1;

input  clk_2;
input  [pr*bw-1:0] mem_in_2; 
input  [22:0] inst_2; 
input  reset_2;
output [bw_psum*col-1:0] out_2;
input  [5:0] clk_en_2;

input  clk_3; 
input  [pr*bw-1:0] mem_in_3; 
input  [22:0] inst_3; 
input  reset_3;
output [bw_psum*col-1:0] out_3;
input  [5:0] clk_en_3;

input  clk_4;
input  [pr*bw-1:0] mem_in_4; 
input  [22:0] inst_4; 
input  reset_4;
output [bw_psum*col-1:0] out_4;
input  [5:0] clk_en_4;

wire   [bw_psum+3-1:0] sum_out_1;
wire   [bw_psum-1:0] sum_2core_out_1;
wire   [bw_psum+3-1:0] sum_in_1;
wire   [bw_psum-1:0] sum_2core_in_1;

wire   [bw_psum+3-1:0] sum_out_2;
wire   [bw_psum-1:0] sum_2core_out_2;
wire   [bw_psum+3-1:0] sum_in_2;
wire   [bw_psum-1:0] sum_2core_in_2;

wire   [bw_psum+3-1:0] sum_out_3;
wire   [bw_psum-1:0] sum_2core_out_3;
wire   [bw_psum+3-1:0] sum_in_3;
wire   [bw_psum-1:0] sum_2core_in_3;

wire   [bw_psum+3-1:0] sum_out_4;
wire   [bw_psum-1:0] sum_2core_out_4;
wire   [bw_psum+3-1:0] sum_in_4;
wire   [bw_psum-1:0] sum_2core_in_4;






core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_1 (
      .reset(reset_1), 
      .clk(clk_1), 
      .out(out_1),
      .mem_in(mem_in_1), 
      .sum_in(sum_in_1),
      .sum_2core_in(sum_2core_in_1),
      .inst(inst_1),
      .sum_out(sum_out_1),
      .sum_2core_out(sum_2core_out_1),
      .clk_en(clk_en_1)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_2 (
      .reset(reset_2), 
      .clk(clk_2), 
      .out(out_2),
      .mem_in(mem_in_2), 
      .sum_in(sum_in_2),
      .sum_2core_in(sum_2core_in_2),
      .inst(inst_2),
      .sum_out(sum_out_2),
      .sum_2core_out(sum_2core_out_2),
      .clk_en(clk_en_2)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_3 (
      .reset(reset_3), 
      .clk(clk_3), 
      .out(out_3),
      .mem_in(mem_in_3), 
      .sum_in(sum_in_3),
      .sum_2core_in(sum_2core_in_3),
      .inst(inst_3),
      .sum_out(sum_out_3),
      .sum_2core_out(sum_2core_out_3),
      .clk_en(clk_en_3)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_4 (
      .reset(reset_4), 
      .clk(clk_4), 
      .out(out_4),
      .mem_in(mem_in_4), 
      .sum_in(sum_in_4),
      .sum_2core_in(sum_2core_in_4),
      .inst(inst_4),
      .sum_out(sum_out_4),
      .sum_2core_out(sum_2core_out_4),
      .clk_en(clk_en_4)
);

//Level 1 asychronous fifo 
fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_2to1_L1(
      .rd_clk(clk_1),
      .rd_rst(reset_1),
      .rd(inst_1[21]), //acc_stage3 signal of core 1
      .out(sum_in_1),
      .wr_clk(clk_2),
      .wr_rst(reset_2),
      .wr(inst_2[19]),//fifo_ext_read_stage2 signal of core 2
      .in(sum_out_2)
      
);

fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_1to2_L1(
      .rd_clk(clk_2),
      .rd_rst(reset_2),
      .rd(inst_2[21]), //acc_stage3 signal of core 2
      .out(sum_in_2),
      .wr_clk(clk_1),
      .wr_rst(reset_1),
      .wr(inst_1[19]),//fifo_ext_read_stage2 signal of core 1
      .in(sum_out_1)
      
);

fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_4to3_L1(
      .rd_clk(clk_3),
      .rd_rst(reset_3),
      .rd(inst_3[21]), //acc_stage3 signal of core 3
      .out(sum_in_3),
      .wr_clk(clk_4),
      .wr_rst(reset_4),
      .wr(inst_4[19]),//fifo_ext_read_stage2 signal of core 4
      .in(sum_out_4)
      
);

fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_3to4_L1(
      .rd_clk(clk_4),
      .rd_rst(reset_4),
      .rd(inst_4[21]), //acc_stage3 signal of core 4
      .out(sum_in_4),
      .wr_clk(clk_3),
      .wr_rst(reset_3),
      .wr(inst_3[19]),//fifo_ext_read_stage2 signal of core 3
      .in(sum_out_3)
      
);
//

//Level 2 asychronous fifo
fifo_depth8_asy #(.bw(bw_psum), .simd(1)) asy_fifo_3to1_L2(
      .rd_clk(clk_1),
      .rd_rst(reset_1),
      .rd(inst_1[17]), //div signal of core 1
      .out(sum_2core_in_1),
      .wr_clk(clk_3),
      .wr_rst(reset_3),
      .wr(inst_3[22]),//fifo_ext_read_stage4 signal of core 3
      .in(sum_2core_out_3)
      
);

fifo_depth8_asy #(.bw(bw_psum), .simd(1)) asy_fifo_1to3_L2(
      .rd_clk(clk_3),
      .rd_rst(reset_3),
      .rd(inst_3[17]), //div signal of core 3
      .out(sum_2core_in_3),
      .wr_clk(clk_1),
      .wr_rst(reset_1),
      .wr(inst_1[22]),//fifo_ext_read_stage4 signal of core 1
      .in(sum_2core_out_1)
      
);

fifo_depth8_asy #(.bw(bw_psum), .simd(1)) asy_fifo_4to2_L2(
      .rd_clk(clk_2),
      .rd_rst(reset_2),
      .rd(inst_2[17]), //div signal of core 2
      .out(sum_2core_in_2),
      .wr_clk(clk_4),
      .wr_rst(reset_4),
      .wr(inst_4[22]),//fifo_ext_read_stage4 signal of core 4
      .in(sum_2core_out_4)
      
);

fifo_depth8_asy #(.bw(bw_psum), .simd(1)) asy_fifo_2to4_L2(
      .rd_clk(clk_4),
      .rd_rst(reset_4),
      .rd(inst_4[17]), //div signal of core 4
      .out(sum_2core_in_4),
      .wr_clk(clk_2),
      .wr_rst(reset_2),
      .wr(inst_2[22]),//fifo_ext_read_stage4 signal of core 2
      .in(sum_2core_out_2)
      
);

//




endmodule
