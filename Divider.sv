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
wire enable_w;
wire [(WORD_LENGTH*2)-1:0] Rem_w;
wire [(WORD_LENGTH*2)-1:0] Div_w;
wire [(WORD_LENGTH*2)-1:0] DivReg_w;
wire [WORD_LENGTH-1:0] Q_w;
wire [WORD_LENGTH-1:0] Qshift_w;
wire [WORD_LENGTH-1:0] Qreg_w;
wire [(WORD_LENGTH*2)-1:0] RemAdder_w;
wire [(WORD_LENGTH*2)-1:0] RestoredRem_w;
wire [(WORD_LENGTH*2)-1:0] RemReg_w;

wire [WORD_LENGTH-1:0] result_w;
wire [WORD_LENGTH-1:0] remainder_w;
assign result = result_w;
assign remainder = remainder_w[WORD_LENGTH-1:0];

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
MuxQuotient_init
(
	.Selector(flag0_w),
	.MUX_Data0(Qreg_w),
	.MUX_Data1(16'b0),
	.MUX_Output(Q_w)
);


Multiplexer2to1
#(
	.NBits(WORD_LENGTH*2)
)
MuxRemainder_init
(
	.Selector(flag0_w),
	.MUX_Data0(RemReg_w),
	.MUX_Data1({16'b0, dividend}),
	.MUX_Output(Rem_w)
);


Multiplexer2to1
#(
	.NBits(WORD_LENGTH*2)
)
MuxDivisior_init
(
	.Selector(flag0_w),
	.MUX_Data0(DivReg_w),
	.MUX_Data1({divisor, 16'b0}),
	.MUX_Output(Div_w)
);

Adder
#(
	.WORD_LENGTH(WORD_LENGTH*2)
)
adder_div
(
	.selector(1'b0),
	.Data1(Rem_w),
	.Data2(Div_w),
	.result(RemAdder_w)
);

Multiplexer2to1
#(
	.NBits(WORD_LENGTH*2)
)
Mux_RestoredRem
(
	.Selector(RemAdder_w[(WORD_LENGTH*2)-1]),
	.MUX_Data0(RemAdder_w),
	.MUX_Data1(Rem_w),
	.MUX_Output(RestoredRem_w)
);

Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
Mux_ShiftQ
(
	.Selector(RemAdder_w[(WORD_LENGTH*2)-1]),
	.MUX_Data0((Q_w << 1) | 1'b1),
	.MUX_Data1(Q_w << 1),
	.MUX_Output(Qshift_w)
);

Register
#(
	.Word_Length(WORD_LENGTH*2)
)
reg_Div
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.Data_Input(Div_w >> 1),
	.Data_Output(DivReg_w)
);

Register
#(
	.Word_Length(WORD_LENGTH*2)
)
reg_rem
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.Data_Input(RestoredRem_w),
	.Data_Output(RemReg_w)
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
	.enable(1'b1),
	.Data_Input(Qshift_w),
	.Data_Output(Qreg_w)
);

Register
#(
	.Word_Length(WORD_LENGTH*2)
)
reg_finalRem
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(enable_w),
	.Data_Input(RestoredRem_w),
	.Data_Output(remainder_w)
);


Register
#(
	.Word_Length(WORD_LENGTH)
)
reg_finalQ
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(enable_w),
	.Data_Input(Qshift_w),
	.Data_Output(result_w)
);


/*
Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
MuxA_init
(
	.Selector(flag0_w),
	.MUX_Data0(Areg_w),
	.MUX_Data1(16'b0),
	.MUX_Output(A_w)
);




Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
MuxshiftA1_init
(
	.Selector(flag0_w),
	.MUX_Data0(Ashift_w | 1'b1),
	.MUX_Data1(Ashift_w),
	.MUX_Output(Ashift1_w)
);


Multiplexer2to1
#(
	.NBits(WORD_LENGTH)
)
MuxQ_init
(
	.Selector(flag0_w),
	.MUX_Data0(Qreg_w),
	.MUX_Data1(dividend),
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
	.Data2(divisor),
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
	.Selector((~SequalA_bit) & (Azero_bit | Qzero_bit)),
	.MUX_Data0(Qshift_w),
	.MUX_Data1(Qshift_w | 1'b1),
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
	.enable(1'b1),
	.Data_Input(QRestored_w),
	.Data_Output(Qreg_w)
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
	.enable(1'b1),
	.Data_Input(ARestored_w),
	.Data_Output(Areg_w)
);


Register
#(
	.Word_Length(WORD_LENGTH)
)
reg_Qfinal
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
reg_Afinal
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(enable_w),
	.Data_Input(ARestored_w),
	.Data_Output(remainder_w)
);
*/
endmodule
