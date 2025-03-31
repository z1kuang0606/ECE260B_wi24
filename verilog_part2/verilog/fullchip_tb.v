// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+3;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  K[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m,l,h;





reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in; 
reg ofifo_rd = 0;
wire [20:0] inst; 
reg qmem_rd = 0;
//reg qmem_CEN = 1;
reg qmem_wr = 0; 
//reg qmem_WEN = 0;
reg kmem_rd = 0; 
//reg kmem_CEN = 1;
reg kmem_wr = 0;
//reg kmem_WEN = 0;
reg pmem_rd = 0; 
//reg pmem_CEN = 1;
reg pmem_wr = 0; 
//reg qmem_WEN = 0;
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;
reg div;
reg acc;
reg fifo_ext_rd;
reg write_back;

assign inst[20] = write_back;
assign inst[19] = fifo_ext_rd;
assign inst[18] = acc;
assign inst[17] = div;
assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;



reg [bw_psum-1:0] temp5b;
reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b;

reg [bw_psum*col-1:0] temp16b_abs;

reg [bw_psum-1:0] abs;

reg [bw_psum-1:0] abs_norm0;
reg [bw_psum-1:0] abs_norm1;
reg [bw_psum-1:0] abs_norm2;
reg [bw_psum-1:0] abs_norm3;
reg [bw_psum-1:0] abs_norm4;
reg [bw_psum-1:0] abs_norm5;
reg [bw_psum-1:0] abs_norm6;
reg [bw_psum-1:0] abs_norm7;

reg [bw_psum*col-1:0] temp16b_abs_norm;

wire [bw_psum*col-1:0] out;



fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk(clk), 
      .mem_in(mem_in), 
      .out(out),
      .inst(inst)
);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);




  ///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////



///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; 
    //kmem_CEN = 0;
    //kmem_WEN =0;//write
    if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = K[q][0];
    mem_in[2*bw-1:1*bw] = K[q][1];
    mem_in[3*bw-1:2*bw] = K[q][2];
    mem_in[4*bw-1:3*bw] = K[q][3];
    mem_in[5*bw-1:4*bw] = K[q][4];
    mem_in[6*bw-1:5*bw] = K[q][5];
    mem_in[7*bw-1:6*bw] = K[q][6];
    mem_in[8*bw-1:7*bw] = K[q][7];
   /* mem_in[9*bw-1:8*bw] = K[q][8];
    mem_in[10*bw-1:9*bw] = K[q][9];
    mem_in[11*bw-1:10*bw] = K[q][10];
    mem_in[12*bw-1:11*bw] = K[q][11];
    mem_in[13*bw-1:12*bw] = K[q][12];
    mem_in[14*bw-1:13*bw] = K[q][13];
    mem_in[15*bw-1:14*bw] = K[q][14];
    mem_in[16*bw-1:15*bw] = K[q][15];*/

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  qkmem_add = 0;
  #0.5 clk = 1'b1;  
////////////////////////////////////

for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1; 
    /*begin
	kmem_CEN = 0;
        kmem_WEN = 1; //read
    end*/
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd = 0; 
  //kmem_CEN = 1;
  //kmem_WEN = 0;

  qkmem_add = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end



///// Q data txt reading /////


//// To get rid of first 3 lines in data file ////
  qk_file = $fopen("qdata.txt", "r");
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (h=0; h<3; h=h+1) begin


$display("##### Q data txt reading #####");
  #0.5 clk = 1'b0;
   write_back = 0;
  
   temp_sum=23'b0;
   temp16b_abs=0;
   acc=0;
   div=0;
  #0.5 clk = 1'b1;


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end












/////////////// Estimated result printing /////////////////


$display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     temp_sum = 23'b0;
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
         end

         temp5b = result[t][q];//raw dot product data
	 abs = (temp5b[bw_psum-1])?(~temp5b[bw_psum-1 : bw_psum*0] + 1) : temp5b[bw_psum*1-1 : 0];
	 temp_sum = temp_sum + abs;
         //temp16b = {temp16b[139:0], temp5b};
	 temp16b = {temp16b[132:0], temp5b}; //concatenated 8 dot products
	 temp16b_abs = {temp16b_abs[132:0], abs};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %40h", t+total_cycle*(h), temp16b);

     $display("prd absolute summation @cycle%2d: %h", t+total_cycle*h, temp_sum);

     /*for (l=0; l<col; l=l+1) begin : label1
	   abs_norm = temp16b_abs[bw_psum*(col-l)-1:bw_psum*(col-l-1)] / temp_sum;
	   temp16b_abs_norm = {temp16b_abs_norm[132:0], abs_norm};
     end*/

    if (temp_sum[bw_psum+3:7] == 16'b0) begin
      temp_sum[7] = 1'b1;
    end

     abs_norm0 = temp16b_abs[bw_psum*(col-0)-1:bw_psum*(col-1)] / temp_sum[bw_psum+3:7];
     abs_norm1 = temp16b_abs[bw_psum*(col-1)-1:bw_psum*(col-2)] / temp_sum[bw_psum+3:7];
     abs_norm2 = temp16b_abs[bw_psum*(col-2)-1:bw_psum*(col-3)] / temp_sum[bw_psum+3:7];
     abs_norm3 = temp16b_abs[bw_psum*(col-3)-1:bw_psum*(col-4)] / temp_sum[bw_psum+3:7];
     abs_norm4 = temp16b_abs[bw_psum*(col-4)-1:bw_psum*(col-5)] / temp_sum[bw_psum+3:7];
     abs_norm5 = temp16b_abs[bw_psum*(col-5)-1:bw_psum*(col-6)] / temp_sum[bw_psum+3:7];
     abs_norm6 = temp16b_abs[bw_psum*(col-6)-1:bw_psum*(col-7)] / temp_sum[bw_psum+3:7];
     abs_norm7 = temp16b_abs[bw_psum*(col-7)-1:bw_psum*(col-8)] / temp_sum[bw_psum+3:7];

     temp16b_abs_norm = {abs_norm0,abs_norm1,abs_norm2,abs_norm3,abs_norm4,abs_norm5,abs_norm6,abs_norm7};
     $display("prd normolizatoin result @cycle%2d: %40h", t+total_cycle*h, temp16b_abs_norm);

 end

//////////////////////////////////////////////






///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  
    //qmem_CEN = 0;
    //qmem_WEN = 0;//write

    if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = Q[q][0];
    mem_in[2*bw-1:1*bw] = Q[q][1];
    mem_in[3*bw-1:2*bw] = Q[q][2];
    mem_in[4*bw-1:3*bw] = Q[q][3];
    mem_in[5*bw-1:4*bw] = Q[q][4];
    mem_in[6*bw-1:5*bw] = Q[q][5];
    mem_in[7*bw-1:6*bw] = Q[q][6];
    mem_in[8*bw-1:7*bw] = Q[q][7];
    /*mem_in[9*bw-1:8*bw] = Q[q][8];
    mem_in[10*bw-1:9*bw] = Q[q][9];
    mem_in[11*bw-1:10*bw] = Q[q][10];
    mem_in[12*bw-1:11*bw] = Q[q][11];
    mem_in[13*bw-1:12*bw] = Q[q][12];
    mem_in[14*bw-1:13*bw] = Q[q][13];
    mem_in[15*bw-1:14*bw] = Q[q][14];
    mem_in[16*bw-1:15*bw] = Q[q][15];*/

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////





///////



  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end









///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;
    //qmem_CEN = 0;
    //qmem_WEN = 1;//read
    if (q>0) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd = 0; 
  //qmem_CEN = 1;
  //qmem_WEN = 0;

  qkmem_add = 0; execute = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 
    //pmem_CEN = 0;
    //pmem_WEN = 0;//write
    if (q>0) begin
       pmem_add = pmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_wr = 0; 
  //pmem_CEN = 1;
  //pmem_WEN = 0;
  
  pmem_add = 0; ofifo_rd = 0;
  #0.5 clk = 1'b1;  

///////////////////////////////////////////
//read pmem to verify the output in simulation
$display("##### start output #####");

for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    
    pmem_rd = 1; 
    //pmem_CEN = 0;
    //pmem_WEN = 0;//write
    if (q>0) begin
       pmem_add = pmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_rd = 0; 
  //pmem_CEN = 1;
  //pmem_WEN = 0;
  
  pmem_add = 0;
  #0.5 clk = 1'b1;  
   
  #0.5 clk = 1'b0; 
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0; 
  #0.5 clk = 1'b1; 

///////////////////////////////////////////
//start normolization
//stage 1: store all summation into fifo
$display("##### start normolization stage 1 #####");
for (q=0; q<total_cycle; q=q+1) begin
   #0.5 clk = 1'b0;
   pmem_rd = 1;
   if (q>0) begin
       pmem_add = pmem_add + 1;
       acc = 1;
   end

   #0.5 clk = 1'b1;
   
end

  #0.5 clk = 1'b0;
  pmem_rd = 0;
  pmem_add = 0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  acc = 0;
  #0.5 clk = 1'b1;

///////////////////////////////////////////
//start normolization stage 2
//stage 2: read fifo and divide
$display("##### start normolization stage 2 #####");
  #0.5 clk = 1'b0; 
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0; 
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;
  write_back = 1;
  #0.5 clk = 1'b1;

  for (l=0; l<total_cycle;l=l+1) begin
    #0.5 clk = 1'b0;
    if (l>0) begin
      pmem_add = pmem_add + 1;
    end
    pmem_wr = 1'b0;
    pmem_rd = 1'b1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    pmem_rd = 1'b0;
    //div = 1'b1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;//multicycle = 3

    #0.5 clk = 1'b0;
    div = 1'b1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    div = 1'b0;
    pmem_wr = 1'b1;
    #0.5 clk = 1'b1;


  end
  
  /*#0.5 clk = 1'b0;
  write_back = 1;
  pmem_rd = 1;
  //div = 1;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  pmem_rd = 0;
  //div = 0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  div = 1;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  div = 0;
  pmem_wr = 1;
  #0.5 clk = 1'b1;

  for (l=1;l<total_cycle;l=l+1) begin
    #0.5 clk = 1'b0;
    pmem_wr = 1'b0;
    pmem_add = pmem_add+1;
    pmem_rd = 1'b1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    pmem_rd = 1'b0;
    div = 1'b1; //can be moved later to implement multicycle
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    pmem_wr = 1'b1;
    div = 1'b0;
    #0.5 clk = 1'b1;
  end
*/
  
  #0.5 clk = 1'b0;
  pmem_add = 0;
  pmem_wr = 1'b0;
  write_back = 1'b0;
  #0.5 clk = 1'b1;

  end

  #10 $finish;


end

endmodule




