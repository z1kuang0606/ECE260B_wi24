// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_8in (out, a, b, clk, reset, clk_en);

parameter bw = 8;
parameter bw_psum = 2*bw+3;
parameter pr = 8; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out; //19 bits
input  [pr*bw-1:0] a;//8 elements, each 8 bits
input  [pr*bw-1:0] b;

input  clk, reset;
input  clk_en;


wire		[2*bw-1:0]	product0	;
wire		[2*bw-1:0]	product1	;
wire		[2*bw-1:0]	product2	;
wire		[2*bw-1:0]	product3	;
wire		[2*bw-1:0]	product4	;
wire		[2*bw-1:0]	product5	;
wire		[2*bw-1:0]	product6	;
wire		[2*bw-1:0]	product7	;

//pipeline reg
reg		[2*bw-1:0]	product0_q	;
reg		[2*bw-1:0]	product1_q	;
reg		[2*bw-1:0]	product2_q	;
reg		[2*bw-1:0]	product3_q	;
reg		[2*bw-1:0]	product4_q	;
reg		[2*bw-1:0]	product5_q	;
reg		[2*bw-1:0]	product6_q	;
reg		[2*bw-1:0]	product7_q	;


genvar i;


assign	product0	=	{{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){b[bw*	1	-1]}},	b[bw*	1	-1:	bw*	0	]};
assign	product1	=	{{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){b[bw*	2	-1]}},	b[bw*	2	-1:	bw*	1	]};
assign	product2	=	{{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){b[bw*	3	-1]}},	b[bw*	3	-1:	bw*	2	]};
assign	product3	=	{{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){b[bw*	4	-1]}},	b[bw*	4	-1:	bw*	3	]};
assign	product4	=	{{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){b[bw*	5	-1]}},	b[bw*	5	-1:	bw*	4	]};
assign	product5	=	{{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){b[bw*	6	-1]}},	b[bw*	6	-1:	bw*	5	]};
assign	product6	=	{{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){b[bw*	7	-1]}},	b[bw*	7	-1:	bw*	6	]};
assign	product7	=	{{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){b[bw*	8	-1]}},	b[bw*	8	-1:	bw*	7	]};



assign out = 
                {{(3){product0_q[2*bw-1]}},product0_q	}
	+	{{(3){product1_q[2*bw-1]}},product1_q	}
	+	{{(3){product2_q[2*bw-1]}},product2_q	}
	+	{{(3){product3_q[2*bw-1]}},product3_q	}
	+	{{(3){product4_q[2*bw-1]}},product4_q	}
	+	{{(3){product5_q[2*bw-1]}},product5_q	}
	+	{{(3){product6_q[2*bw-1]}},product6_q	}
	+	{{(3){product7_q[2*bw-1]}},product7_q	};


always @(posedge clk or posedge reset) begin

	if (reset) begin
		product0_q<=0;
		product1_q<=0;
		product2_q<=0;
		product3_q<=0;
		product4_q<=0;
		product5_q<=0;
		product6_q<=0;
		product7_q<=0;
		
	end
	else begin
		if (clk_en) begin
	    product0_q<=product0;
	    product1_q<=product1;
	    product2_q<=product2;
	    product3_q<=product3;

	    product4_q<=product4;
	    product5_q<=product5;
	    product6_q<=product6;
   	    product7_q<=product7;
	end
          
	end


end



endmodule
