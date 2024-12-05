//test bench for asynchronous fifo for different testcases
`include"async_fifo.v"
module tb;
		parameter DEPTH = 16;
		parameter WIDTH = 8;
		parameter PTR_WIDTH = $clog2(DEPTH);
		parameter NUM_READS=16;
		parameter NUM_WRITES=16;
		parameter WR_CLK_TP=3;
		parameter RD_CLK_TP=8;
		reg wr_clk_i,rd_clk_i,rst_i;
		reg wr_en_i,rd_en_i;
		reg [WIDTH-1:0]wdata_i;
		wire [WIDTH-1:0]rdata_o;
		wire full_o,empty_o;
		wire rd_error_o,wr_error_o;
		integer i,j,k;
		reg [30*8:1]testcase;
		integer wr_delay,rd_delay;

	async_fifo#(.WIDTH(WIDTH),.DEPTH(DEPTH),.PTR_WIDTH(PTR_WIDTH)) dut(wr_clk_i,rd_clk_i,rst_i,wr_en_i,rd_en_i,wdata_i,rdata_o,full_o,empty_o,wr_error_o,rd_error_o);


//clk generation
initial begin
	wr_clk_i =0;
	forever #(WR_CLK_TP/2.0) wr_clk_i =~wr_clk_i;
end
initial begin
	rd_clk_i =0;
	forever #(RD_CLK_TP/2.0) rd_clk_i =~rd_clk_i;
end
//rst generation
initial begin
	rst_i = 1;
	wr_en_i =0;
	rd_en_i =0;
	wdata_i =0;
	repeat(2)@(posedge wr_clk_i);
	rst_i =0;
	$value$plusargs("testcase=%s",testcase);
	case(testcase)
		"TEST_FULL":begin
			write_logic(DEPTH);
		end
		"TEST_EMPTY":begin
			write_logic(DEPTH);
			read_logic(DEPTH);
		end
		"TEST_WR_ERROR":begin
			write_logic(DEPTH+1);
		end
		"TEST_RD_ERROR":begin
			write_logic(DEPTH);
			read_logic(DEPTH+1);
		end
		"TEST_CONCURRENT_WR_RD":begin
			fork
				begin
					for(j=0;j<NUM_WRITES;j=j+1)begin
						write_logic(j);
						wr_delay=$urandom_range(1,10);
						#wr_delay;
					end
				end
				begin
					for(k=0;k<NUM_READS;k=k+1)begin
						read_logic(k);
						rd_delay=$urandom_range(1,10);
						#rd_delay;
					end
				end
			join
		end

		endcase

	#100;
	$finish;
end
task write_logic(input integer num_writes); //write logic
begin
	for(i=0;i<num_writes;i=i+1)begin
	@(posedge wr_clk_i)
	wr_en_i=1;
	wdata_i=$random;
end
	@(posedge wr_clk_i);
	wr_en_i=0;
	wdata_i=0;
end
endtask
task read_logic(input integer num_reads); //read logic
begin
	for(i=0;i<num_reads;i=i+1)begin
		@(posedge rd_clk_i)
		rd_en_i=1;
	end
	@(posedge rd_clk_i);
		rd_en_i=0;
	end
endtask


endmodule
