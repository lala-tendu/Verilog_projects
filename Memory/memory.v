//Declare for 1KB memory with 16bits width
module memory(clk_i,rst_i,addr_i,wr_rd_i,wdata_i,rdata_o,valid_i,ready_o);
		parameter ADDR_WIDTH = 9;
		parameter WIDTH = 16;
		parameter DEPTH = 512;
		input clk_i,rst_i;
		input [ADDR_WIDTH-1:0]addr_i;
		input [WIDTH-1:0]wdata_i;
		input wr_rd_i,valid_i;
		output reg ready_o;
		output reg [WIDTH-1:0]rdata_o;
		integer i;
	
	//internal registers
		reg[WIDTH-1:0]mem[DEPTH-1:0];
		
	always @(posedge clk_i)begin
		if(rst_i)begin //reset applied
			ready_o = 0;
			rdata_o = 0;
		for(i=0;i<DEPTH;i=i+1)mem[i]=0;
		end
		else begin //reset not applied
			if(valid_i == 1)begin
			ready_o = 1;
				if (wr_rd_i == 1)begin //doing write transaction
				mem[addr_i] = wdata_i;
				end
			else begin //doing read operation
				mem[addr_i] = rdata_o;
				end
			end
				else begin
				ready_o = 0;
				end
			end
		end		
endmodule
