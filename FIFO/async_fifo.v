//RTL code for Asynchronous fifo
module async_fifo(wr_clk_i,rd_clk_i,rst_i,wr_en_i,rd_en_i,wdata_i,rdata_o,full_o,empty_o,wr_error_o,rd_error_o);
		parameter DEPTH = 16;
		parameter WIDTH = 8;
		parameter PTR_WIDTH = $clog2(DEPTH);
		input wr_clk_i,rd_clk_i,rst_i;
		input wr_en_i,rd_en_i;
		input [WIDTH-1:0]wdata_i;
		output reg[WIDTH-1:0]rdata_o;
		output reg full_o,empty_o;
		output reg rd_error_o,wr_error_o;
		integer i;

//internal registers
	reg [PTR_WIDTH-1:0]wr_ptr,rd_ptr;
	reg wr_tgl_f,rd_tgl_f;
	reg [PTR_WIDTH-1:0]wr_ptr_rd_clk_i,rd_ptr_wr_clk_i;
	reg wr_tgl_f_rd_clk_i,rd_tgl_f_wr_clk_i;

//memory
	reg [WIDTH-1:0]mem[DEPTH-1:0];

//writing data process
	always@(posedge wr_clk_i)begin
	if(rst_i==1)begin
	//make all reg signals to 0
		full_o = 0;
		empty_o = 1; //before doing anything fifo is empty
		rd_error_o = 0;
		wr_error_o = 0;
		rdata_o = 0;
		wr_ptr = 0;
		rd_ptr = 0;
		wr_tgl_f = 0;
		rd_tgl_f = 0;
		for(i=0;i<DEPTH;i=i+1)mem[i]=0;
	end 
	else begin
	wr_error_o = 0;
	rd_error_o = 0;
	if(wr_en_i == 1)begin //write operation
		if(full_o == 1)begin
			wr_error_o = 1;
		end
		else begin
			if(wr_ptr == DEPTH-1)begin
				wr_ptr =0; //write pointer to 0
				wr_tgl_f = ~wr_tgl_f;
			end
			else begin
					mem[wr_ptr] = wdata_i;
					wr_ptr = wr_ptr+1;
				end
			end
		end
	end
end
always@(posedge rd_clk_i)begin
		if(!rst_i)begin
			rd_error_o=0;
				if(rd_en_i == 1)begin //read operation
					if(empty_o == 1)begin
						rd_error_o = 1;
					end
					else begin
						if(rd_ptr == DEPTH-1)begin
							rd_ptr = 0; //rd_ptr to 0
							rd_tgl_f = ~rd_tgl_f;
						end
						else begin
							rdata_o = mem[rd_ptr];
							rd_ptr = rd_ptr+1;
						end
					end
				end
			end
		end
	
//write synchronization
always@(posedge wr_clk_i)begin
	rd_ptr_wr_clk_i<=rd_ptr;
	rd_tgl_f_wr_clk_i<=rd_tgl_f;
end
//read synchronization
always@(posedge rd_clk_i)begin
	wr_ptr_rd_clk_i<=wr_ptr;
	wr_tgl_f_rd_clk_i<=wr_tgl_f;
end
//full and empty
always@(*)begin
			full_o =0; empty_o =0;
			if(wr_ptr == rd_ptr_wr_clk_i && wr_tgl_f != rd_tgl_f_wr_clk_i)full_o =1;
			if(wr_ptr_rd_clk_i == rd_ptr && wr_tgl_f_rd_clk_i == rd_tgl_f)empty_o =1;
end

endmodule
