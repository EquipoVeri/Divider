module Divider
#(
	parameter WORD_LENGTH = 16
)
(
	// Input Ports
	input clk,
	input reset,
//	input start,
	input [WORD_LENGTH-1:0] dividend,
	input [WORD_LENGTH-1:0] divisor,
	
	// Output Ports
	output [WORD_LENGTH-1:0] result,
	output [WORD_LENGTH-1:0] remainder

//	output ready,
	
//	output sign
);

wire flag0_w;
wire [WORD_LENGTH-1:0] A_w;
wire [WORD_LENGTH-1:0] Ashift_w;
wire [WORD_LENGTH-1:0] Qshift_w;
wire [WORD_LENGTH-1:0] Q_w;
wire [WORD_LENGTH-1:0] QRestored_w;
wire [WORD_LENGTH-1:0] Aadder_w;
wire [WORD_LENGTH-1:0] ARestored_w;
wire [WORD_LENGTH-1:0] result_w;
wire [WORD_LENGTH-1:0] remainder_w;

bit s_bit;
bit addersel_bit;
bit SequalA_bit;
bit enable_w;

bit Azero_bit;
bit Qzero_bit;
bit ANotZero_bit;
bit QNotZero_bit;

assign Ashift_w = A_w << 1;
assign Qshift_w = Q_w << 1;

assign s_bit = Ashift_w[WORD_LENGTH-1];
assign addersel_bit = s_bit ^ divisor[WORD_LENGTH-1];
assign SequalA_bit = s_bit ^ Aadder_w[WORD_LENGTH-1];

assign Azero_bit = (Aadder_w == 0) ? 1'b1 : 1'b0;
assign Qzero_bit = (Qshift_w == 0) ? 1'b1 : 1'b0;
assign ANotZero_bit = (Aadder_w != 0) ? 1'b1 : 1'b0;
assign QNotZero_bit = (Qshift_w != 0) ? 1'b1 : 1'b0;

assign result = result_w;
assign remainder = remainder_w;

CounterWithFunction counter
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.flag0(flag0_w),
	.flag32(enable_w) 
);


Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
MuxA_init
(
	.Selector(flag0_w),
	.MUX_Data0(ARestored_w),
	.MUX_Data1(dividend),
	.MUX_Output(A_w)
);

Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
MuxQ_init
(
	.Selector(flag0_w),
	.MUX_Data0(QRestored_w),
	.MUX_Data1(divisor),
	.MUX_Output(Q_w)
);

Adder
#(
	.WORD_LENGTH(WORD_LENGTH)
)
adder_div
(
	.selector(addersel_bit),
	.Data1(Ashift_w),
	.Data2(Qshift_w),
	.result(Aadder_w)
);

Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
Mux_restoreA
(
	.Selector(SequalA_bit & (ANotZero_bit | QNotZero_bit)),
	.MUX_Data0(Aadder_w),
	.MUX_Data1(Ashift_w),
	.MUX_Output(ARestored_w)
);

Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
Mux_Q
(
	.Selector(~SequalA_bit & (Azero_bit & Qzero_bit)),
	.MUX_Data0(Qshift_w),
	.MUX_Data1(Qshift_w & 1'b1),
	.MUX_Output(QRestored_w)
);

Register
#(
	.Word_Length(WORD_LENGTH)
)
reg_Q
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(enable_w),
	.Data_Input(QRestored_w),
	.Data_Output(result_w)
);

Register
#(
	.Word_Length(WORD_LENGTH)
)
reg_A
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(enable_w),
	.Data_Input(ARestored_w),
	.Data_Output(remainder_w)
);

endmodule
