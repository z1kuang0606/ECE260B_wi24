module fifo_depth8_asy (rd_clk, rd_rst, rd, out, wr_clk, wr_rst, wr, in, o_full, o_empty);
   parameter bw = 4;
   parameter simd = 1;

   input rd_clk;
   input rd_rst;
   input rd;
   output [simd*bw-1:0] out;
   input wr_clk;
   input wr_rst;
   input wr;
   input  [simd*bw-1:0] in;

   output o_full;
   output o_empty;

   reg full, empty;

   reg [3:0] rd_ptr = 4'b0000;
   reg [3:0] wr_ptr = 4'b0000;

  reg [simd*bw-1:0] q0;
  reg [simd*bw-1:0] q1;
  reg [simd*bw-1:0] q2;
  reg [simd*bw-1:0] q3;
  reg [simd*bw-1:0] q4;
  reg [simd*bw-1:0] q5;
  reg [simd*bw-1:0] q6;
  reg [simd*bw-1:0] q7;
  /*reg [simd*bw-1:0] q8;
  reg [simd*bw-1:0] q9;
  reg [simd*bw-1:0] q10;
  reg [simd*bw-1:0] q11;
  reg [simd*bw-1:0] q12;
  reg [simd*bw-1:0] q13;
  reg [simd*bw-1:0] q14;
  reg [simd*bw-1:0] q15;*/

  wire [3:0] rd_ptr_gray = 4'b0000; //gray code of read and write pointer
  wire [3:0] wr_ptr_gray = 4'b0000;

  
  reg [3:0] rd_ptr_gray_d,rd_ptr_gray_dd; //synchronized pointer
  reg [3:0] wr_ptr_gray_d,wr_ptr_gray_dd;

  assign rd_ptr_gray = rd_ptr ^ (rd_ptr>>>1);
  assign wr_ptr_gray = wr_ptr ^ (wr_ptr>>>1); //generate gray coded read and write pointer

  assign o_full = full;
  assign o_empty = empty;


  always @(posedge wr_clk) begin //fifo is full
    if (wr_rst)
      full <= 0;
    else if((rd_ptr_gray_dd[3]!=wr_ptr_gray[3]) && (rd_ptr_gray_dd[2]!=wr_ptr_gray[2]) && (rd_ptr_gray_dd[1:0]==wr_ptr_gray[1:0]))
      full <= 1;
    else
      full <= 0;
  end

  always @(posedge rd_clk) begin//fifo is empty
    if (rd_rst)
      empty <= 0;
    else if (rd_ptr_gray[3:0] == wr_ptr_gray_dd[3:0])
      empty <= 1;
    else 
      empty <= 0;
  end

  always @ (posedge rd_clk) begin
   if (rd_rst) begin
      wr_ptr_gray_d <= 4'b0000;
      wr_ptr_gray_dd<= 4'b0000;
   end
   else begin
      wr_ptr_gray_d <= wr_ptr_gray;
      wr_ptr_gray_dd<= wr_ptr_gray_d; //synchronize write pointer to read clock 
   end
 end

 always @ (posedge wr_clk) begin
   if (wr_rst) begin
      rd_ptr_gray_d <= 4'b0000;
      rd_ptr_gray_dd<= 4'b0000;
   end
   else begin
      rd_ptr_gray_d <= rd_ptr_gray;
      rd_ptr_gray_dd<= rd_ptr_gray_d; //synchronize read pointer to write clock 
   end
 end




  always @ (posedge rd_clk) begin
   if (rd_rst) begin
      rd_ptr <= 4'b0000;
   end
   else if ((rd == 1) && (empty == 0)) begin
      rd_ptr <= rd_ptr + 1;
   end
 end

  fifo_mux_8_1 #(.bw(bw), .simd(simd)) fifo_mux_8_1a (.in0(q0), .in1(q1), .in2(q2), .in3(q3), .in4(q4), .in5(q5), .in6(q6), .in7(q7),
                                  .sel(rd_ptr[2:0]), .out(out));

  always @ (posedge wr_clk) begin
   if (wr_rst) begin
      wr_ptr <= 4'b0000;
   end
   else begin 
      if ((wr == 1) && (full == 0)) begin
        wr_ptr <= wr_ptr + 1;
      end

      if (wr == 1) begin
        case (wr_ptr[2:0])
         3'b000   :    q0  <= in ;
         3'b001   :    q1  <= in ;
         3'b010   :    q2  <= in ;
         3'b011   :    q3  <= in ;
         3'b100   :    q4  <= in ;
         3'b101   :    q5  <= in ;
         3'b110   :    q6  <= in ;
         3'b111   :    q7  <= in ;
         
        endcase
      end
   end
  end
endmodule
