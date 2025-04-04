// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, mem_in, inst, reset, out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+3;
parameter pr = 8; //8 elements in one vector

input  clk; 
input  [pr*bw-1:0] mem_in; 
input  [16:0] inst; 
input  reset;
output [bw_psum*col-1:0] out;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
      .reset(reset), 
      .clk(clk), 
      .out(out),
      .mem_in(mem_in), 
      //.sum_in(23'b0),
      .inst(inst)
);


endmodule
