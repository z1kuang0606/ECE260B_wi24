// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+3;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped
//single core, col = 8, dual core, col=8*2


integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0





integer  K_core1[col-1:0][pr-1:0];
integer  K_core2[col-1:0][pr-1:0];

integer  Q[total_cycle-1:0][pr-1:0];

integer  result[total_cycle-1:0][2*col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m,l,h;





reg reset_1 = 1;
reg clk_1 = 0;
reg [pr*bw-1:0] mem_in_1; 
reg ofifo_rd_1 = 0;
wire [20:0] inst_1; 
reg qmem_rd_1 = 0;
reg qmem_wr_1 = 0; 
reg kmem_rd_1 = 0; 
reg kmem_wr_1 = 0;
reg pmem_rd_1 = 0; 
reg pmem_wr_1 = 0; 
reg execute_1 = 0;
reg load_1 = 0;
reg [3:0] qkmem_add_1 = 0;
reg [3:0] pmem_add_1 = 0;
reg div_1;
reg acc_1;
reg fifo_ext_rd_1;
reg write_back_1;

assign inst_1[20] = write_back_1;
assign inst_1[19] = fifo_ext_rd_1;
assign inst_1[18] = acc_1;
assign inst_1[17] = div_1;
assign inst_1[16] = ofifo_rd_1;
assign inst_1[15:12] = qkmem_add_1;
assign inst_1[11:8]  = pmem_add_1;
assign inst_1[7] = execute_1;
assign inst_1[6] = load_1;
assign inst_1[5] = qmem_rd_1;
assign inst_1[4] = qmem_wr_1;
assign inst_1[3] = kmem_rd_1;
assign inst_1[2] = kmem_wr_1;
assign inst_1[1] = pmem_rd_1;
assign inst_1[0] = pmem_wr_1;


reg reset_2 = 1;
reg clk_2 = 0;
reg [pr*bw-1:0] mem_in_2; 
reg ofifo_rd_2 = 0;
wire [20:0] inst_2; 
reg qmem_rd_2 = 0;
reg qmem_wr_2 = 0; 
reg kmem_rd_2 = 0; 
reg kmem_wr_2 = 0;
reg pmem_rd_2 = 0; 
reg pmem_wr_2 = 0; 
reg execute_2 = 0;
reg load_2 = 0;
reg [3:0] qkmem_add_2 = 0;
reg [3:0] pmem_add_2 = 0;
reg div_2;
reg acc_2;
reg fifo_ext_rd_2;
reg write_back_2;

assign inst_2[20] = write_back_2;
assign inst_2[19] = fifo_ext_rd_2;
assign inst_2[18] = acc_2;
assign inst_2[17] = div_2;
assign inst_2[16] = ofifo_rd_2;
assign inst_2[15:12] = qkmem_add_2;
assign inst_2[11:8]  = pmem_add_2;
assign inst_2[7] = execute_2;
assign inst_2[6] = load_2;
assign inst_2[5] = qmem_rd_2;
assign inst_2[4] = qmem_wr_2;
assign inst_2[3] = kmem_rd_2;
assign inst_2[2] = kmem_wr_2;
assign inst_2[1] = pmem_rd_2;
assign inst_2[0] = pmem_wr_2;




reg [bw_psum-1:0] temp5b; //length of a dot product. Should be 2*bw+3
reg [bw_psum+4-1:0] temp_sum; //should be bw_psum+3-1 for single core version; sum of col (2*bw+3)-bit length words
reg [bw_psum+3-1:0] temp_sum_core1;//sum of 8 19bits words
reg [bw_psum+3-1:0] temp_sum_core2;

reg [bw_psum-1:0] temp_sum_used; //sum of 16 dot products with scaling

reg [bw_psum*col*2-1:0] temp16b; //concatenate of col (2*bw+3)-bit length words

reg [bw_psum*col*2-1:0] temp16b_abs;//concatenate of col (2*bw+3)-bit length words

reg [bw_psum-1:0] abs; //length of a dot product. Should be 2*bw+3

reg [bw_psum-1:0] abs_norm0;
reg [bw_psum-1:0] abs_norm1;
reg [bw_psum-1:0] abs_norm2;
reg [bw_psum-1:0] abs_norm3;
reg [bw_psum-1:0] abs_norm4;
reg [bw_psum-1:0] abs_norm5;
reg [bw_psum-1:0] abs_norm6;
reg [bw_psum-1:0] abs_norm7;
reg [bw_psum-1:0] abs_norm8;
reg [bw_psum-1:0] abs_norm9;
reg [bw_psum-1:0] abs_norm10;
reg [bw_psum-1:0] abs_norm11;
reg [bw_psum-1:0] abs_norm12;
reg [bw_psum-1:0] abs_norm13;
reg [bw_psum-1:0] abs_norm14;
reg [bw_psum-1:0] abs_norm15;

reg [bw_psum*col*2-1:0] temp16b_abs_norm;//concatenate of col (2*bw+3)-bit length words

wire [bw_psum*col-1:0] out_1;
wire [bw_psum*col-1:0] out_2;//output of one core



fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset_1(reset_1),
      .clk_1(clk_1), 
      .mem_in_1(mem_in_1), 
      .out_1(out_1),
      .inst_1(inst_1),
      .reset_2(reset_2),
      .clk_2(clk_2), 
      .mem_in_2(mem_in_2), 
      .out_2(out_2),
      .inst_2(inst_2)

);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);

  ///// K data txt reading /////
//core 1
$display("#####core 1 K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;   
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;   
  end
  reset_1 = 0;

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  /*qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);*/




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K_core1[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////


///// K data txt reading /////
//core 2
$display("#####core 2 K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;    
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;   
  end
  reset_2 = 0;

  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  /*qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);*/




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K_core2[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////


/////Kmem writing for core 1 and core 2  /////

$display("#####  Kmem writing for core 1 and core 2#####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk_1 = 1'b0; clk_2 = 1'b0; 
    kmem_wr_1 = 1; kmem_wr_2 = 1;
    //kmem_CEN = 0;
    //kmem_WEN =0;//write
    if (q>0) begin qkmem_add_1 = qkmem_add_1 + 1; qkmem_add_2 = qkmem_add_2 + 1; end
    
    mem_in_1[1*bw-1:0*bw] = K_core1[q][0];
    mem_in_1[2*bw-1:1*bw] = K_core1[q][1];
    mem_in_1[3*bw-1:2*bw] = K_core1[q][2];
    mem_in_1[4*bw-1:3*bw] = K_core1[q][3];
    mem_in_1[5*bw-1:4*bw] = K_core1[q][4];
    mem_in_1[6*bw-1:5*bw] = K_core1[q][5];
    mem_in_1[7*bw-1:6*bw] = K_core1[q][6];
    mem_in_1[8*bw-1:7*bw] = K_core1[q][7];


    mem_in_2[1*bw-1:0*bw] = K_core2[q][0];
    mem_in_2[2*bw-1:1*bw] = K_core2[q][1];
    mem_in_2[3*bw-1:2*bw] = K_core2[q][2];
    mem_in_2[4*bw-1:3*bw] = K_core2[q][3];
    mem_in_2[5*bw-1:4*bw] = K_core2[q][4];
    mem_in_2[6*bw-1:5*bw] = K_core2[q][5];
    mem_in_2[7*bw-1:6*bw] = K_core2[q][6];
    mem_in_2[8*bw-1:7*bw] = K_core2[q][7];
   /* mem_in[9*bw-1:8*bw] = K[q][8];
    mem_in[10*bw-1:9*bw] = K[q][9];
    mem_in[11*bw-1:10*bw] = K[q][10];
    mem_in[12*bw-1:11*bw] = K[q][11];
    mem_in[13*bw-1:12*bw] = K[q][12];
    mem_in[14*bw-1:13*bw] = K[q][13];
    mem_in[15*bw-1:14*bw] = K[q][14];
    mem_in[16*bw-1:15*bw] = K[q][15];*/

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  kmem_wr_1 = 0;  kmem_wr_2 = 0;
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  qkmem_add_1 = 0;  qkmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
///////////////////////////////////////////

/////  K data loading for core 1 and core 2 /////
$display("##### K data loading to processor for core 1 and core 2 #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    load_1 = 1; load_2 = 1;
    if (q==1) begin kmem_rd_1 = 1; kmem_rd_2 = 1; end
    /*begin
	kmem_CEN = 0;
        kmem_WEN = 1; //read
    end*/
    if (q>1) begin
       qkmem_add_1 = qkmem_add_1 + 1;  qkmem_add_2 = qkmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  kmem_rd_1 = 0; kmem_rd_2 = 0;
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  qkmem_add_1 = 0;  qkmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  load_1 = 0;  load_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

///////////////////////////////////////////

for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0;   clk_2 = 1'b0;
    #0.5 clk_1 = 1'b1;   clk_2 = 1'b1;
 end




  
///// Q data txt reading /////
qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  /*qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);*/

  for (h=0;h<3;h=h+1) begin


$display("\n\n\n\n\n\n##### start batch %2d, cycle %2d to %2d #####",h, h*8,h*8+7);


$display("##### Q data txt reading for batch %2d #####",h);
   #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  write_back_1 = 0;
   write_back_2 = 0;
   temp_sum=23'b0;
  temp_sum_core1=22'b0;
  temp_sum_core2=22'b0;
  temp_sum_used=19'b0;
  temp16b_abs=0;
  acc_1=0;
  div_1=0;
  acc_2=0;
  div_2=0;
  fifo_ext_rd_1 = 0;
  fifo_ext_rd_2 = 0;
#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;  
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b0; 
  end











/////////////// Estimated result printing /////////////////


$display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col*2; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     temp_sum_core1 = 22'b0;
     temp_sum_core2 = 22'b0;
     for (q=0; q<col*2; q=q+1) begin
	if (q<col) begin
         for (k=0; k<pr; k=k+1) begin //core 1 computation
            result[t][q] = result[t][q] + Q[t][k] * K_core1[q][k];
         end

         temp5b = result[t][q];//raw dot product data
	 abs = (temp5b[bw_psum-1])?(~temp5b[bw_psum-1 : bw_psum*0] + 1) : temp5b[bw_psum*1-1 : 0]; //abs of single dot product
	 temp_sum_core1 = temp_sum_core1 + abs;
         //temp16b = {temp16b[139:0], temp5b};
	 temp16b = {temp16b[284:0], temp5b}; //concatenated 16 dot products
	 temp16b_abs = {temp16b_abs[284:0], abs};
        end
	else begin //core 2 computation
	  for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K_core2[q-col][k];
          end

         temp5b = result[t][q];//raw dot product data
	 abs = (temp5b[bw_psum-1])?(~temp5b[bw_psum-1 : bw_psum*0] + 1) : temp5b[bw_psum*1-1 : 0];
	 temp_sum_core2 = temp_sum_core2 + abs;
         //temp16b = {temp16b[139:0], temp5b};
	 temp16b = {temp16b[284:0], temp5b}; //concatenated 16 dot products
	 temp16b_abs = {temp16b_abs[284:0], abs};
	end
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     temp_sum = temp_sum_core1 + temp_sum_core2; //sum of 16 dot products without scaling
     $display("prd @cycle%2d: %40h", t+total_cycle*h, temp16b); //concatenation of 16 dot products

     $display("prd absolute summation without scaling @cycle%2d: %h", t+total_cycle*h, temp_sum); //sum of 16 dot product (absolute value)

     /*for (l=0; l<col; l=l+1) begin : label1
	   abs_norm = temp16b_abs[bw_psum*(col-l)-1:bw_psum*(col-l-1)] / temp_sum;
	   temp16b_abs_norm = {temp16b_abs_norm[132:0], abs_norm};
     end*/
     temp_sum_used = temp_sum_core1[bw_psum+3-1:7]+temp_sum_core2[bw_psum+3-1:7]; 
     $display("prd absolute summation with scaling @cycle%2d: %h", t+total_cycle*h, temp_sum_used); //sum of 16 dot product (absolute value)
     

     //normolized result at this Q cycle.
     abs_norm0 = temp16b_abs[bw_psum*((2*col)-0)-1:bw_psum*((2*col)-1)] / temp_sum_used;
     abs_norm1 = temp16b_abs[bw_psum*((2*col)-1)-1:bw_psum*((2*col)-2)] / temp_sum_used;
     abs_norm2 = temp16b_abs[bw_psum*((2*col)-2)-1:bw_psum*((2*col)-3)] / temp_sum_used;
     abs_norm3 = temp16b_abs[bw_psum*((2*col)-3)-1:bw_psum*((2*col)-4)] / temp_sum_used;
     abs_norm4 = temp16b_abs[bw_psum*((2*col)-4)-1:bw_psum*((2*col)-5)] / temp_sum_used;
     abs_norm5 = temp16b_abs[bw_psum*((2*col)-5)-1:bw_psum*((2*col)-6)] / temp_sum_used;
     abs_norm6 = temp16b_abs[bw_psum*((2*col)-6)-1:bw_psum*((2*col)-7)] / temp_sum_used;
     abs_norm7 = temp16b_abs[bw_psum*((2*col)-7)-1:bw_psum*((2*col)-8)] / temp_sum_used;
     abs_norm8 = temp16b_abs[bw_psum*((2*col)-8)-1:bw_psum*((2*col)-9)] / temp_sum_used;
     abs_norm9 = temp16b_abs[bw_psum*((2*col)-9)-1:bw_psum*((2*col)-10)] / temp_sum_used;
     abs_norm10 = temp16b_abs[bw_psum*((2*col)-10)-1:bw_psum*((2*col)-11)] / temp_sum_used;
     abs_norm11 = temp16b_abs[bw_psum*((2*col)-11)-1:bw_psum*((2*col)-12)] / temp_sum_used;
     abs_norm12 = temp16b_abs[bw_psum*((2*col)-12)-1:bw_psum*((2*col)-13)] / temp_sum_used;
     abs_norm13 = temp16b_abs[bw_psum*((2*col)-13)-1:bw_psum*((2*col)-14)] / temp_sum_used;
     abs_norm14 = temp16b_abs[bw_psum*((2*col)-14)-1:bw_psum*((2*col)-15)] / temp_sum_used;
     abs_norm15 = temp16b_abs[bw_psum*((2*col)-15)-1:bw_psum*((2*col)-16)] / temp_sum_used;

     temp16b_abs_norm = {abs_norm0,abs_norm1,abs_norm2,abs_norm3,abs_norm4,abs_norm5,abs_norm6,abs_norm7,abs_norm8,abs_norm9,abs_norm10,abs_norm11,abs_norm12,abs_norm13,abs_norm14,abs_norm15};
     $display("prd normolizatoin result @cycle%2d: %40h", t+total_cycle*h, temp16b_abs_norm);

 end

//////////////////////////////////////////////






///// Qmem writing for core 1 and core 2 /////

$display("##### Qmem writing for core 1 and core 2 #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0; 
    qmem_wr_1 = 1;  qmem_wr_2 = 1;
    //qmem_CEN = 0;
    //qmem_WEN = 0;//write

    if (q>0) begin qkmem_add_1 = qkmem_add_1 + 1; qkmem_add_2 = qkmem_add_2 + 1; end
    
    mem_in_1[1*bw-1:0*bw] = Q[q][0];
    mem_in_1[2*bw-1:1*bw] = Q[q][1];
    mem_in_1[3*bw-1:2*bw] = Q[q][2];
    mem_in_1[4*bw-1:3*bw] = Q[q][3];
    mem_in_1[5*bw-1:4*bw] = Q[q][4];
    mem_in_1[6*bw-1:5*bw] = Q[q][5];
    mem_in_1[7*bw-1:6*bw] = Q[q][6];
    mem_in_1[8*bw-1:7*bw] = Q[q][7];

    mem_in_2[1*bw-1:0*bw] = Q[q][0];
    mem_in_2[2*bw-1:1*bw] = Q[q][1];
    mem_in_2[3*bw-1:2*bw] = Q[q][2];
    mem_in_2[4*bw-1:3*bw] = Q[q][3];
    mem_in_2[5*bw-1:4*bw] = Q[q][4];
    mem_in_2[6*bw-1:5*bw] = Q[q][5];
    mem_in_2[7*bw-1:6*bw] = Q[q][6];
    mem_in_2[8*bw-1:7*bw] = Q[q][7];
    /*mem_in[9*bw-1:8*bw] = Q[q][8];
    mem_in[10*bw-1:9*bw] = Q[q][9];
    mem_in[11*bw-1:10*bw] = Q[q][10];
    mem_in[12*bw-1:11*bw] = Q[q][11];
    mem_in[13*bw-1:12*bw] = Q[q][12];
    mem_in[14*bw-1:13*bw] = Q[q][13];
    mem_in[15*bw-1:14*bw] = Q[q][14];
    mem_in[16*bw-1:15*bw] = Q[q][15];*/

    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

  end


  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  qmem_wr_1 = 0; qmem_wr_2 = 0;
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  qkmem_add_1 = 0;  qkmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
///////////////////////////////////////////








  for (q=0; q<2; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end






 for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0;   clk_2 = 1'b0;
    #0.5 clk_1 = 1'b1;   clk_2 = 1'b1;
 end





///// execution in parallel /////
$display("##### execute in parallel #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    execute_1 = 1; execute_2 = 1;
    qmem_rd_1 = 1; qmem_rd_2 = 1;
    //qmem_CEN = 0;
    //qmem_WEN = 1;//read
    if (q>0) begin
       qkmem_add_1 = qkmem_add_1 + 1; qkmem_add_2 = qkmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  qmem_rd_1 = 0;  qmem_rd_2 = 0;
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  qkmem_add_1 = 0; execute_1 = 0;  qkmem_add_2 = 0; execute_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;  
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1; 
 end




////////////// output fifo rd and wb to psum mem for core 1 and core 2 ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    ofifo_rd_1 = 1; ofifo_rd_2 = 1;
    pmem_wr_1 = 1;  pmem_wr_2 = 1;
    //pmem_CEN = 0;
    //pmem_WEN = 0;//write
    if (q>0) begin
       pmem_add_1 = pmem_add_1 + 1;  pmem_add_2 = pmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  pmem_wr_1 = 0;  pmem_wr_2 = 0;
  //pmem_CEN = 1;
  //pmem_WEN = 0;
  
  pmem_add_1 = 0; ofifo_rd_1 = 0;  pmem_add_2 = 0; ofifo_rd_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

///////////////////////////////////////////
//read pmem of core 1 and core 2 to verify the output in simulation
$display("##### start output core 1 and core 2#####");

for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    
    pmem_rd_1 = 1; pmem_rd_2 = 1;
    //pmem_CEN = 0;
    //pmem_WEN = 0;//write
    if (q>0) begin
       pmem_add_1 = pmem_add_1 + 1; pmem_add_2 = pmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  pmem_rd_1 = 0;  pmem_rd_2 = 0;
  //pmem_CEN = 1;
  //pmem_WEN = 0;
  
  pmem_add_1 = 0;  pmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
   
  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

///////////////////////////////////////////
//start normolization
//stage 1: store all summation into fifo for core 1 and core 2
$display("##### start normolization stage 1 #####");
for (q=0; q<total_cycle; q=q+1) begin
   #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
   pmem_rd_1 = 1;  pmem_rd_2 = 1;
   if (q>0) begin
       pmem_add_1 = pmem_add_1 + 1;  pmem_add_2 = pmem_add_2 + 1;
       acc_1 = 1;  acc_2 = 1;
   end

   #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
   
end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  pmem_rd_1 = 0;  pmem_rd_2 = 0;
  pmem_add_1 = 0; pmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  acc_1 = 0;  acc_2 = 0; 
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;


///////////////////////////////////////////
//start normolization stage 2
//stage 2: core 1 and core 2 write asy fifo 
  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
   
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  $display("##### start normolization stage 2 #####");
  for (l=0; l<total_cycle;l=l+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    fifo_ext_rd_1 = 1;  fifo_ext_rd_2 = 1;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    fifo_ext_rd_1 = 0;  fifo_ext_rd_2 = 0;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

///////////////////////////////////////////
//start normolization stage 3
//stage 3: read internal and asy fifo and divide for core 1 and core 2



$display("##### start normolization stage 3 #####");
  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  write_back_1 = 1;  write_back_2 = 1;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

  for (l=0; l<total_cycle;l=l+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    if (l>0) begin
      pmem_add_1 = pmem_add_1 + 1;  pmem_add_2 = pmem_add_2 + 1;
    end
    pmem_wr_1 = 1'b0; pmem_wr_2 = 1'b0;
    pmem_rd_1 = 1'b1; pmem_rd_2 = 1'b1;
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;
 
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
    pmem_rd_1 = 1'b0; pmem_rd_2 = 1'b0;
    //div = 1'b1;
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

    #0.5 clk_1 = 1'b0; clk_2 = 1'b1;
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;//multicycle = 3

    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    div_1 = 1'b1;  div_2 = 1'b1;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    div_1 = 1'b0;  div_2 = 1'b0;
    pmem_wr_1 = 1'b1;  pmem_wr_2 = 1'b1;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;


  end 
  
    
  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  pmem_wr_1 = 1'b0;  pmem_wr_2 = 1'b0;
  pmem_add_1 = 0;  pmem_add_2 = 0;
  write_back_1 = 1'b0;  write_back_2 = 1'b0;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

  end

  #10 $finish;


end

endmodule




