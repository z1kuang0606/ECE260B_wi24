// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp_row (clk, acc, div, fifo_ext_rd, sum_in, sum_out, sfp_in, sfp_out);

  parameter col = 8;
  parameter bw = 8;
  parameter bw_psum = 2*bw+4;

  input  clk, div, acc, fifo_ext_rd;
  input  [bw_psum+3-1:0] sum_in; //sum of 8 words, each is 19 bits
  input  [col*bw_psum-1:0] sfp_in;//concatenatation of 8 19 bits words
  wire  [col*bw_psum-1:0] abs;//concatenation of 8 19 bits words (take absolute value)
  reg    div_q;
  output [col*bw_psum-1:0] sfp_out;//concatenation of 8 19 bits words (normolized)
  output [bw_psum+3-1:0] sum_out;//sum of 8 words, each is 19 bits
  wire [bw_psum+3-1:0] sum_this_core;//sum of 8 words, each is 19 bits
  wire signed [bw_psum-1:0] sum_2core;//sum of 2 (22-7)=15 bits words
  wire signed [bw_psum-1:0] sfp_in_sign0;//dot product
  wire signed [bw_psum-1:0] sfp_in_sign1;
  wire signed [bw_psum-1:0] sfp_in_sign2;
  wire signed [bw_psum-1:0] sfp_in_sign3;
  wire signed [bw_psum-1:0] sfp_in_sign4;
  wire signed [bw_psum-1:0] sfp_in_sign5;
  wire signed [bw_psum-1:0] sfp_in_sign6;
  wire signed [bw_psum-1:0] sfp_in_sign7;


  reg signed [bw_psum-1:0] sfp_out_sign0;
  reg signed [bw_psum-1:0] sfp_out_sign1;
  reg signed [bw_psum-1:0] sfp_out_sign2;
  reg signed [bw_psum-1:0] sfp_out_sign3;
  reg signed [bw_psum-1:0] sfp_out_sign4;
  reg signed [bw_psum-1:0] sfp_out_sign5;
  reg signed [bw_psum-1:0] sfp_out_sign6;
  reg signed [bw_psum-1:0] sfp_out_sign7;

  reg [bw_psum+3-1:0] sum_q;//sum of 8 words, each is 19 bits
  reg fifo_wr;

  /*assign sfp_in_sign0 =  sfp_in[bw_psum*1-1 : bw_psum*0]; //take each element of the input vector q1(row vector) multiples K(transposed)
  assign sfp_in_sign1 =  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign sfp_in_sign2 =  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign sfp_in_sign3 =  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign sfp_in_sign4 =  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign sfp_in_sign5 =  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign sfp_in_sign6 =  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign sfp_in_sign7 =  sfp_in[bw_psum*8-1 : bw_psum*7];*/
  
  assign sfp_in_sign0 =  abs[bw_psum*1-1 : bw_psum*0]; //take the absolute value of each element of the input vector q1(row vector) multiples K(transposed)
  assign sfp_in_sign1 =  abs[bw_psum*2-1 : bw_psum*1];
  assign sfp_in_sign2 =  abs[bw_psum*3-1 : bw_psum*2];
  assign sfp_in_sign3 =  abs[bw_psum*4-1 : bw_psum*3];
  assign sfp_in_sign4 =  abs[bw_psum*5-1 : bw_psum*4];
  assign sfp_in_sign5 =  abs[bw_psum*6-1 : bw_psum*5];
  assign sfp_in_sign6 =  abs[bw_psum*7-1 : bw_psum*6];
  assign sfp_in_sign7 =  abs[bw_psum*8-1 : bw_psum*7];

  assign sfp_out[bw_psum*1-1 : bw_psum*0] = sfp_out_sign0;
  assign sfp_out[bw_psum*2-1 : bw_psum*1] = sfp_out_sign1;
  assign sfp_out[bw_psum*3-1 : bw_psum*2] = sfp_out_sign2;
  assign sfp_out[bw_psum*4-1 : bw_psum*3] = sfp_out_sign3;
  assign sfp_out[bw_psum*5-1 : bw_psum*4] = sfp_out_sign4;
  assign sfp_out[bw_psum*6-1 : bw_psum*5] = sfp_out_sign5;
  assign sfp_out[bw_psum*7-1 : bw_psum*6] = sfp_out_sign6;
  assign sfp_out[bw_psum*8-1 : bw_psum*7] = sfp_out_sign7;


  assign sum_2core = sum_this_core[bw_psum+3-1:7] + sum_in[bw_psum+3-1:7];//divide the denominator by 64

  assign abs[bw_psum*1-1 : bw_psum*0] = (sfp_in[bw_psum*1-1]) ?  (~sfp_in[bw_psum*1-1 : bw_psum*0] + 1)  :  sfp_in[bw_psum*1-1 : bw_psum*0];//take the absolute value of each element in the input vector.
  assign abs[bw_psum*2-1 : bw_psum*1] = (sfp_in[bw_psum*2-1]) ?  (~sfp_in[bw_psum*2-1 : bw_psum*1] + 1)  :  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign abs[bw_psum*3-1 : bw_psum*2] = (sfp_in[bw_psum*3-1]) ?  (~sfp_in[bw_psum*3-1 : bw_psum*2] + 1)  :  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign abs[bw_psum*4-1 : bw_psum*3] = (sfp_in[bw_psum*4-1]) ?  (~sfp_in[bw_psum*4-1 : bw_psum*3] + 1)  :  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign abs[bw_psum*5-1 : bw_psum*4] = (sfp_in[bw_psum*5-1]) ?  (~sfp_in[bw_psum*5-1 : bw_psum*4] + 1)  :  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign abs[bw_psum*6-1 : bw_psum*5] = (sfp_in[bw_psum*6-1]) ?  (~sfp_in[bw_psum*6-1 : bw_psum*5] + 1)  :  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign abs[bw_psum*7-1 : bw_psum*6] = (sfp_in[bw_psum*7-1]) ?  (~sfp_in[bw_psum*7-1 : bw_psum*6] + 1)  :  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign abs[bw_psum*8-1 : bw_psum*7] = (sfp_in[bw_psum*8-1]) ?  (~sfp_in[bw_psum*8-1 : bw_psum*7] + 1)  :  sfp_in[bw_psum*8-1 : bw_psum*7];

  fifo_depth16 #(.bw(bw_psum+3)) fifo_inst_int (
     .rd_clk(clk), 
     .wr_clk(clk), 
     .in(sum_q),
     .out(sum_this_core), 
     .rd(div), 
     .wr(fifo_wr), 
     .reset(reset)
  );

  fifo_depth16 #(.bw(bw_psum+3)) fifo_inst_ext (
     .rd_clk(clk), 
     .wr_clk(clk), 
     .in(sum_q),
     .out(sum_out), 
     .rd(fifo_ext_rd), 
     .wr(fifo_wr), 
     .reset(reset)
  );

  always @ (posedge clk) begin
    if (reset) begin
      fifo_wr <= 0;
    end
    else begin
       div_q <= div ;
       if (acc) begin
      
         sum_q <= 
           {4'b0, abs[bw_psum*1-1 : bw_psum*0]} +
           {4'b0, abs[bw_psum*2-1 : bw_psum*1]} +
           {4'b0, abs[bw_psum*3-1 : bw_psum*2]} +
           {4'b0, abs[bw_psum*4-1 : bw_psum*3]} +
           {4'b0, abs[bw_psum*5-1 : bw_psum*4]} +
           {4'b0, abs[bw_psum*6-1 : bw_psum*5]} +
           {4'b0, abs[bw_psum*7-1 : bw_psum*6]} +
           {4'b0, abs[bw_psum*8-1 : bw_psum*7]} ;
         fifo_wr <= 1;
       end
       else begin
         fifo_wr <= 0;
   
         if (div) begin
           sfp_out_sign0 <= sfp_in_sign0 / sum_2core;
           sfp_out_sign1 <= sfp_in_sign1 / sum_2core;
           sfp_out_sign2 <= sfp_in_sign2 / sum_2core;
           sfp_out_sign3 <= sfp_in_sign3 / sum_2core;
           sfp_out_sign4 <= sfp_in_sign4 / sum_2core;
           sfp_out_sign5 <= sfp_in_sign5 / sum_2core;
           sfp_out_sign6 <= sfp_in_sign6 / sum_2core;
           sfp_out_sign7 <= sfp_in_sign7 / sum_2core;



         end
       end
   end
 end


endmodule

