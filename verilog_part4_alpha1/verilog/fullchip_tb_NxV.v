// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb_NxV;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+3;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped
//single core, col = 8, dual core, col=8*2


integer vn_file ; // file handler
integer vn_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0





integer  N_core1[col-1:0][pr-1:0];
integer  N_core2[col-1:0][pr-1:0];

integer  V[total_cycle-1:0][pr-1:0];

integer  result[total_cycle-1:0][2*col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m,l,h;





reg reset_1 = 1;
reg clk_1 = 0;
reg [pr*bw-1:0] mem_in_1; 
reg ofifo_rd_1 = 0;
wire [20:0] inst_1; 
reg vmem_rd_1 = 0;
reg vmem_wr_1 = 0; 
reg nmem_rd_1 = 0; 
reg nmem_wr_1 = 0;
reg pmem_rd_1 = 0; 
reg pmem_wr_1 = 0; 
reg execute_1 = 0;
reg load_1 = 0;
reg [3:0] vnmem_add_1 = 0;
reg [3:0] pmem_add_1 = 0;
reg div_1;
reg acc_1;
reg fifo_ext_rd_1;
reg write_back_1;

wire [5:0] clk_en_1;
reg  clk_en_array_1;
reg clk_en_ofifo_1;
reg clk_en_qmem_1;
reg clk_en_kmem_1;
reg clk_en_pmem_1;
reg clk_en_sfp_1;

assign inst_1[20] = write_back_1;
assign inst_1[19] = fifo_ext_rd_1;
assign inst_1[18] = acc_1;
assign inst_1[17] = div_1;
assign inst_1[16] = ofifo_rd_1;
assign inst_1[15:12] = vnmem_add_1;
assign inst_1[11:8]  = pmem_add_1;
assign inst_1[7] = execute_1;
assign inst_1[6] = load_1;
assign inst_1[5] = vmem_rd_1;
assign inst_1[4] = vmem_wr_1;
assign inst_1[3] = nmem_rd_1;
assign inst_1[2] = nmem_wr_1;
assign inst_1[1] = pmem_rd_1;
assign inst_1[0] = pmem_wr_1;

assign clk_en_1[0] = clk_en_array_1;
assign clk_en_1[1] = clk_en_ofifo_1;
assign clk_en_1[2] = clk_en_qmem_1;
assign clk_en_1[3] = clk_en_kmem_1;
assign clk_en_1[4] = clk_en_pmem_1;
assign clk_en_1[5] = clk_en_sfp_1;


reg reset_2 = 1;
reg clk_2 = 0;
reg [pr*bw-1:0] mem_in_2; 
reg ofifo_rd_2 = 0;
wire [20:0] inst_2; 
reg vmem_rd_2 = 0;
reg vmem_wr_2 = 0; 
reg nmem_rd_2 = 0; 
reg nmem_wr_2 = 0;
reg pmem_rd_2 = 0; 
reg pmem_wr_2 = 0; 
reg execute_2 = 0;
reg load_2 = 0;
reg [3:0] vnmem_add_2 = 0;
reg [3:0] pmem_add_2 = 0;
reg div_2;
reg acc_2;
reg fifo_ext_rd_2;
reg write_back_2;

wire [5:0] clk_en_2;
reg clk_en_array_2;
reg clk_en_ofifo_2;
reg clk_en_qmem_2;
reg clk_en_kmem_2;
reg clk_en_pmem_2;
reg clk_en_sfp_2;

assign inst_2[20] = write_back_2;
assign inst_2[19] = fifo_ext_rd_2;
assign inst_2[18] = acc_2;
assign inst_2[17] = div_2;
assign inst_2[16] = ofifo_rd_2;
assign inst_2[15:12] = vnmem_add_2;
assign inst_2[11:8]  = pmem_add_2;
assign inst_2[7] = execute_2;
assign inst_2[6] = load_2;
assign inst_2[5] = vmem_rd_2;
assign inst_2[4] = vmem_wr_2;
assign inst_2[3] = nmem_rd_2;
assign inst_2[2] = nmem_wr_2;
assign inst_2[1] = pmem_rd_2;
assign inst_2[0] = pmem_wr_2;

assign clk_en_2[0] = clk_en_array_2;
assign clk_en_2[1] = clk_en_ofifo_2;
assign clk_en_2[2] = clk_en_qmem_2;
assign clk_en_2[3] = clk_en_kmem_2;
assign clk_en_2[4] = clk_en_pmem_2;
assign clk_en_2[5] = clk_en_sfp_2;



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
      .clk_en_1(clk_en_1),
      .reset_2(reset_2),
      .clk_2(clk_2), 
      .mem_in_2(mem_in_2), 
      .out_2(out_2),
      .inst_2(inst_2),
      .clk_en_2(clk_en_2)

);


initial begin 

  $dumpfile("fullchip_tb_NxV.vcd");
  $dumpvars(0,fullchip_tb_NxV);


  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  clk_en_array_1 = 0; clk_en_ofifo_1 = 0; clk_en_qmem_1 = 0; clk_en_kmem_1 = 0; clk_en_pmem_1 = 0; clk_en_sfp_1 = 0;
  clk_en_array_2 = 0; clk_en_ofifo_2 = 0; clk_en_qmem_2 = 0; clk_en_kmem_2 = 0; clk_en_pmem_2 = 0; clk_en_sfp_2 = 0;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;
  ///// N data txt reading /////
//core 1
$display("#####core 1 N data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;   
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;   
  end

  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  reset_1 = 0;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;

  vn_file = $fopen("norm_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  /*vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);*/




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          vn_scan_file = $fscanf(vn_file, "%d\n", captured_data);
          N_core1[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////


///// N data txt reading /////
//core 2
$display("#####core 2 N data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;    
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1;   
  end

  #0.5 clk_1 = 1'b0; clk_2 = 1'b0;
  reset_2 = 0;
  #0.5 clk_1 = 1'b1; clk_2 = 1'b1;


  vn_file = $fopen("norm_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  /*vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);*/




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          vn_scan_file = $fscanf(vn_file, "%d\n", captured_data);
          N_core2[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////


/////Nmem writing for core 1 and core 2  /////

#0.5 clk_1 = 1'b0; clk_2 = 1'b0;    
clk_en_kmem_1 = 1; clk_en_kmem_2 = 1; //enable kmem1 and kmem2

#0.5 clk_1 = 1'b1; clk_2 = 1'b1;

#0.5 clk_1 = 1'b0; clk_2 = 1'b0;    
#0.5 clk_1 = 1'b1; clk_2 = 1'b1;

$display("#####  Nmem writing for core 1 and core 2#####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk_1 = 1'b0; clk_2 = 1'b0; 
    nmem_wr_1 = 1; nmem_wr_2 = 1;
    //kmem_CEN = 0;
    //kmem_WEN =0;//write
    if (q>0) begin vnmem_add_1 = vnmem_add_1 + 1; vnmem_add_2 = vnmem_add_2 + 1; end
    
    mem_in_1[1*bw-1:0*bw] = N_core1[q][0];
    mem_in_1[2*bw-1:1*bw] = N_core1[q][1];
    mem_in_1[3*bw-1:2*bw] = N_core1[q][2];
    mem_in_1[4*bw-1:3*bw] = N_core1[q][3];
    mem_in_1[5*bw-1:4*bw] = N_core1[q][4];
    mem_in_1[6*bw-1:5*bw] = N_core1[q][5];
    mem_in_1[7*bw-1:6*bw] = N_core1[q][6];
    mem_in_1[8*bw-1:7*bw] = N_core1[q][7];


    mem_in_2[1*bw-1:0*bw] = N_core2[q][0];
    mem_in_2[2*bw-1:1*bw] = N_core2[q][1];
    mem_in_2[3*bw-1:2*bw] = N_core2[q][2];
    mem_in_2[4*bw-1:3*bw] = N_core2[q][3];
    mem_in_2[5*bw-1:4*bw] = N_core2[q][4];
    mem_in_2[6*bw-1:5*bw] = N_core2[q][5];
    mem_in_2[7*bw-1:6*bw] = N_core2[q][6];
    mem_in_2[8*bw-1:7*bw] = N_core2[q][7];
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
  nmem_wr_1 = 0;  nmem_wr_2 = 0;
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  vnmem_add_1 = 0;  vnmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
///////////////////////////////////////////

/////  N data loading for core 1 and core 2 /////
#0.5 clk_1 = 1'b0; clk_2 = 1'b0;   

clk_en_array_1 = 1; clk_en_array_2 = 1; //enable array 1 and array 2 for data loading.

#0.5 clk_1 = 1'b1; clk_2 = 1'b1;

#0.5 clk_1 = 1'b0; clk_2 = 1'b0;    
#0.5 clk_1 = 1'b1; clk_2 = 1'b1;

$display("##### N data loading to processor for core 1 and core 2 #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    load_1 = 1; load_2 = 1;
    if (q==1) begin nmem_rd_1 = 1; nmem_rd_2 = 1; end
    /*begin
	kmem_CEN = 0;
        kmem_WEN = 1; //read
    end*/
    if (q>1) begin
       vnmem_add_1 = vnmem_add_1 + 1;  vnmem_add_2 = vnmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  nmem_rd_1 = 0; nmem_rd_2 = 0;
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  vnmem_add_1 = 0;  vnmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  load_1 = 0;  load_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

///////////////////////////////////////////

#0.5 clk_1 = 1'b0; clk_2 = 1'b0;  

clk_en_kmem_1 = 0; clk_en_kmem_2 = 0; //disable kmem 1 and kmem2

#0.5 clk_1 = 1'b1; clk_2 = 1'b1;

for (q=0; q<10; q=q+1) begin
    #0.5 clk_1 = 1'b0;   clk_2 = 1'b0;
    #0.5 clk_1 = 1'b1;   clk_2 = 1'b1;
 end

#0.5 clk_1 = 1'b0; clk_2 = 1'b0;  

clk_en_array_1 = 0; clk_en_array_2 = 0; //disable array1 and array2

#0.5 clk_1 = 1'b1; clk_2 = 1'b1;


  
///// V data txt reading /////
vn_file = $fopen("vdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  /*vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);*/

  for (h=0;h<1;h=h+1) begin


$display("\n\n\n\n\n\n##### start batch %2d, cycle %2d to %2d #####",h, h*8,h*8+7);


$display("##### V data txt reading for batch %2d #####",h);
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

  clk_en_array_1 = 0; clk_en_ofifo_1 = 0; clk_en_qmem_1 = 0; clk_en_kmem_1 = 0; clk_en_pmem_1 = 0; clk_en_sfp_1 = 0;
  clk_en_array_2 = 0; clk_en_ofifo_2 = 0; clk_en_qmem_2 = 0; clk_en_kmem_2 = 0; clk_en_pmem_2 = 0; clk_en_sfp_2 = 0;
#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

  


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          vn_scan_file = $fscanf(vn_file, "%d\n", captured_data);
          V[q][j] = captured_data; //q:row number j:column number
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
            //result[t][q] = result[t][q] + V[t][k] * N_core1[q][k];
	    result[t][q] = result[t][q] + V[k][t] * N_core1[q][k];
         end

         temp5b = result[t][q];//raw dot product data
	 temp16b = {temp16b[284:0], temp5b}; //concatenated 16 dot products
	end
	else begin //core 2 computation
	  for (k=0; k<pr; k=k+1) begin
            //result[t][q] = result[t][q] + V[t][k] * N_core2[q-col][k];
	    result[t][q] = result[t][q] + V[k][t] * N_core2[q-col][k];
          end

         temp5b = result[t][q];//raw dot product data
	 //abs = (temp5b[bw_psum-1])?(~temp5b[bw_psum-1 : bw_psum*0] + 1) : temp5b[bw_psum*1-1 : 0];
	 //temp_sum_core2 = temp_sum_core2 + abs;
         //temp16b = {temp16b[139:0], temp5b};
	 temp16b = {temp16b[284:0], temp5b}; //concatenated 16 dot products
	 //temp16b_abs = {temp16b_abs[284:0], abs};
	end
     end

          $display("prd @cycle%2d: %h", t+total_cycle*h, temp16b); //concatenation of 16 dot products

     
     

     
 end

//////////////////////////////////////////////






///// Vmem writing for core 1 and core 2 /////

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;

clk_en_qmem_1 = 1; clk_en_qmem_2 = 1; //enable qmem1 and qmem2

#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;  
#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

$display("##### Vmem writing for core 1 and core 2 #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0; 
    vmem_wr_1 = 1;  vmem_wr_2 = 1;
    //qmem_CEN = 0;
    //qmem_WEN = 0;//write

    if (q>0) begin vnmem_add_1 = vnmem_add_1 + 1; vnmem_add_2 = vnmem_add_2 + 1; end
    
    //transpose V
    mem_in_1[1*bw-1:0*bw] = V[0][q];
    mem_in_1[2*bw-1:1*bw] = V[1][q];
    mem_in_1[3*bw-1:2*bw] = V[2][q];
    mem_in_1[4*bw-1:3*bw] = V[3][q];
    mem_in_1[5*bw-1:4*bw] = V[4][q];
    mem_in_1[6*bw-1:5*bw] = V[5][q];
    mem_in_1[7*bw-1:6*bw] = V[6][q];
    mem_in_1[8*bw-1:7*bw] = V[7][q];

    mem_in_2[1*bw-1:0*bw] = V[0][q];
    mem_in_2[2*bw-1:1*bw] = V[1][q];
    mem_in_2[3*bw-1:2*bw] = V[2][q];
    mem_in_2[4*bw-1:3*bw] = V[3][q];
    mem_in_2[5*bw-1:4*bw] = V[4][q];
    mem_in_2[6*bw-1:5*bw] = V[5][q];
    mem_in_2[7*bw-1:6*bw] = V[6][q];
    mem_in_2[8*bw-1:7*bw] = V[7][q];
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
  vmem_wr_1 = 0; vmem_wr_2 = 0;
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  vnmem_add_1 = 0;  vnmem_add_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
///////////////////////////////////////////








  for (q=0; q<2; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end






 




///// execution in parallel /////

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;

clk_en_array_1 = 1; clk_en_array_2 = 1; //enable array1 and array2
clk_en_ofifo_1 = 1; clk_en_ofifo_2 = 1; //enable ofifo1 and ofifo2

#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

$display("##### execute in parallel #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
    execute_1 = 1; execute_2 = 1;
    vmem_rd_1 = 1; vmem_rd_2 = 1;
    //qmem_CEN = 0;
    //qmem_WEN = 1;//read
    if (q>0) begin
       vnmem_add_1 = vnmem_add_1 + 1; vnmem_add_2 = vnmem_add_2 + 1;
    end

    #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;
  end

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
  vmem_rd_1 = 0;  vmem_rd_2 = 0;
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  vnmem_add_1 = 0; execute_1 = 0;  vnmem_add_2 = 0; execute_2 = 0;
  #0.5 clk_1 = 1'b1;  clk_2 = 1'b1;


///////////////////////////////////////////

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;

clk_en_qmem_1 = 0; clk_en_qmem_2 = 0; //disable qmem1 and qmem2

#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

 for (q=0; q<8; q=q+1) begin
    #0.5 clk_1 = 1'b0; clk_2 = 1'b0;  
    #0.5 clk_1 = 1'b1; clk_2 = 1'b1; 
 end




////////////// output fifo rd and wb to psum mem for core 1 and core 2 ///////////////////

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;

clk_en_pmem_1 = 1; clk_en_pmem_2 = 1;//enable pmem1 and pmem2

#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

#0.5 clk_1 = 1'b0;  clk_2 = 1'b0;
#0.5 clk_1 = 1'b1;  clk_2 = 1'b1;

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

  #0.5 clk_1 = 1'b0;  clk_2 = 1'b0;

clk_en_ofifo_1 = 0; clk_en_ofifo_2 = 0;//disable ofifo1 and ofifo2
clk_en_array_1 = 0; clk_en_array_2 = 0; //disable array1 and array2

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
end

  #10 $finish;


end

endmodule

