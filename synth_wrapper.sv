module synth_wrapper(
	input logic             KEY[0],
	input logic 	[3:0] 	SW,
	output logic 	[9:0] 	LEDR
);

vending_machine dut1 (.clk_i(KEY[0]),
 
					  .rst_i(SW[3]), 
					  
					  .nickle_i(SW[2]),
					  
					  .dime_i(SW[1]),
					  
					  .quarter_i(SW[0]),
					  
					  .change_o(LEDR[2:0]), 
					  
					  .soda_o(LEDR[4])
					  );

endmodule
