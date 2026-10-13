import fifo_shared_pkg::*;

module FIFO(FIFO_if.DUT fifo_if);
 
localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);

reg [fifo_if.FIFO_WIDTH-1:0] mem [fifo_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

logic do_read, do_write;

assign do_read = (fifo_if.rd_en && !fifo_if.empty);
assign do_write = (fifo_if.wr_en && !fifo_if.full);

//Writing process
always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		wr_ptr <= 0;
		fifo_if.wr_ack <= 0;
		fifo_if.overflow <= 0;
	end
	else begin
		fifo_if.overflow <= 0;
		if (do_write) begin //wr_en && !full
			mem[wr_ptr] <= fifo_if.data_in;
			fifo_if.wr_ack <= 1;
			wr_ptr <= wr_ptr + 1;
		end
		else begin 
			fifo_if.wr_ack <= 0; 
			if (fifo_if.full & fifo_if.wr_en)
				fifo_if.overflow <= 1;
		end
	end
end

//Reading process
always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		rd_ptr <= 0;
		fifo_if.underflow <= 0;
	end
	else begin
		fifo_if.underflow <= 0;
		if (do_read) begin //rd_en && !empty
			fifo_if.data_out <= mem[rd_ptr];
			rd_ptr <= rd_ptr + 1;
		end
		else 
		 	if(fifo_if.empty && fifo_if.rd_en)
				fifo_if.underflow <= 1;
	end
end

//Counting process
always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		count <= 0;
	end
	else begin
		case({do_read, do_write})
			2'b01: count <= count + 1;
			2'b10: count <= count - 1;
			default: count <= count; 
			//2'b00 -> no operation , so count remains the same
			//2'b11 -> no change
		endcase
	end
end

assign fifo_if.full = 		 (count == fifo_if.FIFO_DEPTH)? 1 : 0;
assign fifo_if.empty =  	 (count == 0)? 1 : 0;
assign fifo_if.almostfull =  (count == fifo_if.FIFO_DEPTH-1)? 1 : 0; 
assign fifo_if.almostempty = (count == 1)? 1 : 0;

endmodule