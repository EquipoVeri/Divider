timeunit 10ps; //It specifies the time unit that all the delay will take in the simulation.
timeprecision 1ps;// It specifies the resolution in the simulation.

module Divider_TB;

parameter WORD_LENGTH = 16;

bit clk = 0;
bit reset; 

logic [WORD_LENGTH-1:0] dividend = 0;
logic [WORD_LENGTH-1:0] divisor = 0;
wire [WORD_LENGTH-1:0] result;
wire [WORD_LENGTH-1:0] remainder;
wire sign;


Divider
#(
	.WORD_LENGTH(WORD_LENGTH)
)
DUV
(
	// Inputs
	.clk(clk),
	.reset(reset),
	.dividend(dividend),
	.divisor(divisor),
	// Output
	.result(result),
	.remainder(remainder),
	.sign(sign)
);


/*********************************************************/
initial // Clock generator
  begin
    forever #1 clk = !clk;
  end
/*********************************************************/
initial begin // reset generator
	#0 reset = 1;
	/*#30 reset = 0;
	#5 reset = 1;*/
end

/*********************************************************/

initial begin 
	#0 dividend = -246;
	#0 divisor = -80;
end

/*********************************************************/
endmodule
