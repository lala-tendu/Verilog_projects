`include"sync_fifo.v"
module tb;
		parameter DEPTH = 16;
		parameter WIDTH = 8;
		parameter PTR_WIDTH = $clog2(DEPTH);
		reg clk_i,rst_i;
		reg wr_en_i,rd_en_i;
		reg [WIDTH-1:0]wdata_i;
		wire [WIDTH-1:0]rdata_o;
		wire full_o,empty_o;
		wire rd_error_o,wr_error_o;
		integer i;
		

	sync_fifo#(.WIDTH(WIDTH),.DEPTH(DEPTH),.PTR_WIDTH(PTR_WIDTH)) dut(clk_i,rst_i,wr_en_i,rd_en_i,wdata_i,rdata_o,full_o,empty_o,wr_error_o,rd_error_o);


//clk generation
initial begin
	clk_i =0;
	forever #5 clk_i =~clk_i;
end
//rst generation
initial begin
	rst_i = 1;
	wr_en_i =0;
	rd_en_i =0;
	wdata_i =0;
	repeat(2)@(posedge clk_i);
	rst_i =0;
	write_logic();
	read_logic();
	#10;
	$finish;
end
task write_logic(); //write logic
begin
	for(i=0;i<DEPTH;i=i+1)begin
	@(posedge clk_i)
	wr_en_i=1;
	wdata_i=$random;
end
	@(posedge clk_i);
	wr_en_i=0;
	wdata_i=0;
end
endtask
task read_logic(); //read logic
begin
	for(i=0;i<DEPTH;i=i+1)begin
		@(posedge clk_i)
		rd_en_i=1;
	end
	@(posedge clk_i);
		rd_en_i=0;
	end
endtask


endmodule
