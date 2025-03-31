// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_1, mem_in_1, inst_1 , reset_1, out_1, clk_2, mem_in_2, inst_2, reset_2,out_2);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+3;
parameter pr = 8; //8 elements in one vector

input  clk_1; 
input  [pr*bw-1:0] mem_in_1; 
input  [20:0] inst_1; 
input  reset_1;
output [bw_psum*col-1:0] out_1;

input  clk_2;
input  [pr*bw-1:0] mem_in_2; 
input  [20:0] inst_2; 
input  reset_2;
output [bw_psum*col-1:0] out_2;

wire   [bw_psum+3-1:0] sum_out_1;
wire   [bw_psum+3-1:0] sum_out_2;

wire   [bw_psum+3-1:0] sum_in_1;
wire   [bw_psum+3-1:0] sum_in_2;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_1 (
      .reset(reset_1), 
      .clk(clk_1), 
      .out(out_1),
      .mem_in(mem_in_1), 
      .sum_in(sum_in_1),
      .inst(inst_1),
      .sum_out(sum_out_1)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_2 (
      .reset(reset_2), 
      .clk(clk_2), 
      .out(out_2),
      .mem_in(mem_in_2), 
      .sum_in(sum_in_2),
      .inst(inst_2),
      .sum_out(sum_out_2)
);

fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_2to1(
      .rd_clk(clk_1),
      .rd_rst(reset_1),
      .rd(inst_1[17]), //div signal of core 1
      .out(sum_in_1),
      .wr_clk(clk_2),
      .wr_rst(reset_2),
      .wr(inst_2[19]),//fifo_ext_read signal of core 2
      .in(sum_out_2)
      
);

fifo_depth8_asy #(.bw(bw_psum+3), .simd(1)) asy_fifo_1to2(
      .rd_clk(clk_2),
      .rd_rst(reset_2),
      .rd(inst_2[17]), //div signal of core 2
      .out(sum_in_2),
      .wr_clk(clk_1),
      .wr_rst(reset_1),
      .wr(inst_1[19]),//fifo_ext_read signal of core 1
      .in(sum_out_1)
      
);




endmodule
