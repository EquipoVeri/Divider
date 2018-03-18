module Sign
(
	input enable,
	input multiplicand,
	input multiplier,
	output sign
);

bit sign_bit;

always_comb begin
	if(enable) begin
		case ({multiplicand, multiplier})
			2'b00:
				//if(enable==1'b1)
					sign_bit <= 1'b0;
			2'b01:
				//if(enable==1'b1)
					sign_bit <= 1'b1;
			2'b10:
				//if(enable==1'b1)
					sign_bit <= 1'b1;
			2'b11:
				//if(enable==1'b1)
					sign_bit <= 1'b0;
			default:
				sign_bit <= 1'b0;
		endcase
	end
	else 
		sign_bit <= 1'b0;
end

assign sign = sign_bit;

endmodule
