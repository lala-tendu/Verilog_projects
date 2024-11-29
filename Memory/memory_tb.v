`include "memory.v"
module memory_tb;
		parameter ADDR_WIDTH = 9;
		parameter WIDTH = 16;
		parameter DEPTH = 512;
		reg clk_i,rst_i;
		reg [ADDR_WIDTH-1:0]addr_i;
		reg [WIDTH-1:0]wdata_i;
		reg wr_rd_i,valid_i;
		wire ready_o;
		wire [WIDTH-1:0]rdata_o;
		integer i;
	memory dut(.*);
	initial begin
	clk_i = 0;
	forever #5 clk_i =~clk_i;
	end
	task rst_logic();
	begin @(posedge clk_i);
			valid_i =0;
			wr_rd_i =0;
			addr_i =0;
			wdata_i =0;
	end
	endtask
	initial begin
	rst_i = 1;
	rst_logic(); //reset all input signals to zero
	repeat (2) @(posedge clk_i);
	rst_i = 0;
	end
	initial begin
	#100;
	$finish;
	end
endmodule

