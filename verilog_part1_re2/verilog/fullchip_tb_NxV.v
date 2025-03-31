// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb_NxV;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+3;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer vn_file ; // file handler
integer vn_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  N[col-1:0][pr-1:0];
integer  V[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m,l,h;





reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in; 
reg ofifo_rd = 0;
wire [20:0] inst; 
reg vmem_rd = 0;
//reg vmem_CEN = 1;
reg vmem_wr = 0; 
//reg vmem_WEN = 0;
reg nmem_rd = 0; 
//reg nmem_CEN = 1;
reg nmem_wr = 0;
//reg nmem_WEN = 0;
reg pmem_rd = 0; 
//reg pmem_CEN = 1;
reg pmem_wr = 0; 
//reg vmem_WEN = 0;
reg execute = 0;
reg load = 0;
reg [3:0] vnmem_add = 0;
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
assign inst[15:12] = vnmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = vmem_rd;
assign inst[4] = vmem_wr;
assign inst[3] = nmem_rd;
assign inst[2] = nmem_wr;
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

  $dumpfile("fullchip_tb_NxV.vcd");
  $dumpvars(0,fullchip_tb_NxV);




  ///// K data txt reading /////

$display("##### N data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;
  reset = 0;
  #0.5 clk = 1'b1;

  vn_file = $fopen("norm.txt", "r");

  //// To get rid of first 4 lines in data file ////
  /*vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);*/




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          vn_scan_file = $fscanf(vn_file, "%d\n", captured_data);
          N[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////



///// Nmem writing  /////

$display("##### Nmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    nmem_wr = 1; 
    //nmem_CEN = 0;
    //nmem_WEN =0;//write
    if (q>0) vnmem_add = vnmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = N[q][0];
    mem_in[2*bw-1:1*bw] = N[q][1];
    mem_in[3*bw-1:2*bw] = N[q][2];
    mem_in[4*bw-1:3*bw] = N[q][3];
    mem_in[5*bw-1:4*bw] = N[q][4];
    mem_in[6*bw-1:5*bw] = N[q][5];
    mem_in[7*bw-1:6*bw] = N[q][6];
    mem_in[8*bw-1:7*bw] = N[q][7];
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
  nmem_wr = 0;  
  //nmem_CEN = 1;
  //nmem_WEN = 0;

  vnmem_add = 0;
  #0.5 clk = 1'b1;  
////////////////////////////////////

for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  N data loading  /////
$display("##### N data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) nmem_rd = 1; 
    /*begin
	nmem_CEN = 0;
        nmem_WEN = 1; //read
    end*/
    if (q>1) begin
       vnmem_add = vnmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  nmem_rd = 0; 
  //nmem_CEN = 1;
  //nmem_WEN = 0;

  vnmem_add = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end



///// V data txt reading /////


  vn_file = $fopen("vdata.txt", "r");
  /*vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);
  vn_scan_file = $fscanf(vn_file, "%s\n", captured_data);*/


  for (h=0; h<3; h=h+1) begin

$display("\n\n\n\n\n##### start batch %2d #####",h);
$display("##### V data txt reading #####");
  #0.5 clk = 1'b0;
   write_back = 0;
  
   temp_sum=23'b0;
   temp16b_abs=0;
   acc=0;
   div=0;
  #0.5 clk = 1'b1;


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          vn_scan_file = $fscanf(vn_file, "%d\n", captured_data);
          V[q][j] = captured_data;
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
            result[t][q] = result[t][q] + V[k][t] * N[q][k];
         end

         temp5b = result[t][q];//raw dot product data
	 //abs = (temp5b[bw_psum-1])?(~temp5b[bw_psum-1 : bw_psum*0] + 1) : temp5b[bw_psum*1-1 : 0];
	 //temp_sum = temp_sum + abs;
         //temp16b = {temp16b[139:0], temp5b};
	 temp16b = {temp16b[132:0], temp5b}; //concatenated 8 dot products
	 //temp16b_abs = {temp16b_abs[132:0], abs};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %40h", t+total_cycle*(h), temp16b);

         
 end

//////////////////////////////////////////////






///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    vmem_wr = 1;  
    //vmem_CEN = 0;
    //vmem_WEN = 0;//write

    if (q>0) vnmem_add = vnmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = V[0][q];
    mem_in[2*bw-1:1*bw] = V[1][q];
    mem_in[3*bw-1:2*bw] = V[2][q];
    mem_in[4*bw-1:3*bw] = V[3][q];
    mem_in[5*bw-1:4*bw] = V[4][q];
    mem_in[6*bw-1:5*bw] = V[5][q];
    mem_in[7*bw-1:6*bw] = V[6][q];
    mem_in[8*bw-1:7*bw] = V[7][q];
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
  vmem_wr = 0; 
  //vmem_CEN = 1;
  //vmem_WEN = 0;

  vnmem_add = 0;
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
    vmem_rd = 1;
    //vmem_CEN = 0;
    //vmem_WEN = 1;//read
    if (q>0) begin
       vnmem_add = vnmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  vmem_rd = 0; 
  //vmem_CEN = 1;
  //vmem_WEN = 0;

  vnmem_add = 0; execute = 0;
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

end  
    #10 $finish;


end

endmodule

