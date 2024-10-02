module vending_machine(
	input logic             rst_i,
	input logic 			clk_i,
	input logic 			nickle_i, dime_i, quarter_i,
	
	output logic [2:0] 	    change_o,
	output logic 			soda_o
);

typedef enum {S0, S5, S10, S15} state;

state present, next;

always_ff @(posedge clk_i) begin
	if (!rst_i) present <= S0; 
	else present <= next;
end

always_comb begin
	
	next = present; 
	
	case (present) 
		S0: case ({nickle_i, dime_i, quarter_i})
			3'b001:     next <= S0;
			3'b010: 	next <= S10;
			3'b100: 	next <= S5;
			default: next <= S0;
		endcase
		
		S5:case ({nickle_i, dime_i, quarter_i})
			3'b001: 	next <= S0;
			3'b010: 	next <= S15;
			3'b100: 	next <= S10;
			default: next <= S5;
		endcase
			
		S10:case ({nickle_i, dime_i, quarter_i})
			3'b001:     next <= S0;
			3'b010: 	next <= S0;
			3'b100: 	next <= S15;
			default: next <= S10;
		endcase		

		S15:case ({nickle_i, dime_i, quarter_i})
			3'b001: 	next <= S0;
			3'b010: 	next <= S0;
			3'b100: 	next <= S0;
			default: next <= S15;
		endcase			
	endcase
end
//////////////////////////// mealy machine ////////////////////////////////////
always_ff @ (posedge clk_i) begin
soda_o =    ((present == S0) && ({nickle_i, dime_i, quarter_i}) == 3'b001) | 
			((present == S5) && ({nickle_i, dime_i, quarter_i}) == 3'b001) |
			((present == S10) && ({nickle_i, dime_i, quarter_i}) == 3'b001) |
			((present == S10) && ({nickle_i, dime_i, quarter_i}) == 3'b010) |
			((present == S15) && ({nickle_i, dime_i, quarter_i}) == 3'b001) |
			((present == S15) && ({nickle_i, dime_i, quarter_i}) == 3'b010) |
			((present == S15) && ({nickle_i, dime_i, quarter_i}) == 3'b100);

	
	case (present)
		S0: case({nickle_i, dime_i, quarter_i})
				3'b001:     change_o = 3'b001; // change = 5
				default: change_o = 3'b000;
			 endcase	
			 
		S5: case({nickle_i, dime_i, quarter_i})
				3'b001:     change_o = 3'b010; // change = 10
				default: change_o = 3'b000;	
			 endcase
			 
		S10: case({nickle_i, dime_i, quarter_i})
				3'b001:	    change_o = 3'b011; // change = 15
				3'b010:	    change_o = 3'b000; // change = 0
				default: change_o = 3'b000;
			  endcase
			  
		S15: case({nickle_i, dime_i, quarter_i})
				3'b001:	   change_o = 3'b100; // change = 20
				3'b010:	   change_o = 3'b001; // change = 5
				3'b100:	   change_o = 3'b000; // change = 0
				default: change_o = 3'b000;	
			  endcase
	endcase
end

endmodule

`timescale 1ps/1ps			
module test_bench();
 	
	logic 		rst_i;
	logic 		clk_i;
	logic 		nickle_i, dime_i, quarter_i;
	
	logic [2:0] change_o;
	logic 		soda_o;
	
	vending_machine dut1(.*);
	
	integer i;

initial begin
	clk_i = 0;
	forever #10 clk_i = ~clk_i;
end

initial begin
	rst_i = 0;
	#50 rst_i = 1;
end

initial begin
	{nickle_i, dime_i, quarter_i} = 3'b000;
	#100 	stimulate(3'b011);
	#60 	stimulate(3'b101);
	#60 	stimulate(3'b001);
	#60 	{nickle_i, dime_i, quarter_i} = 3'b100;
	#120 	{nickle_i, dime_i, quarter_i} = 3'b010;
	#120 	{nickle_i, dime_i, quarter_i} = 3'b001;				
end

task stimulate (input logic [2:0] a );
	nickle_i = a[2];
	#15 begin nickle_i = 0; dime_i = a[1]; end
	#20 begin dime_i = 0; quarter_i = a[0]; end
	#20 begin quarter_i = 0; end
	#5;
endtask	
	
endmodule


	

			
			
			
			
			