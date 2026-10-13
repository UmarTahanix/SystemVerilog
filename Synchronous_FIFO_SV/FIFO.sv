module FIFO(FIFO_if.DUT fifo_if);
 
localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);

reg [fifo_if.FIFO_WIDTH-1:0] mem [fifo_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

logic do_read, do_write;

assign do_read = (fifo_if.rd_en && !fifo_if.empty);
assign do_write = (fifo_if.wr_en && !fifo_if.full);


sequence rstseq;
	(count === 0) && (fifo_if.wr_ack === 0) && (wr_ptr === 0) && (rd_ptr === 0);
endsequence
 //Asynchronous reset
property rstprop;
	@(posedge fifo_if.clk) !fifo_if.rst_n |-> rstseq;
endproperty

rst_assert: assert property(rstprop) else $display("Time: %0t, wr_ack = %0b, count = %0d, wr_ptr = %0b, 
							rd_ptr = %0b", $time, fifo_if.wr_ack, count, wr_ptr, rd_ptr);
rst_cover: cover property(rstprop);


sequence wr_ack_seq;
	fifo_if.wr_ack;
endsequence

property wr_ack_prop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
	(fifo_if.wr_en && !fifo_if.full) |=> wr_ack_seq;
endproperty

wr_ack_assert: assert property (wr_ack_prop);
wr_ack_cover: cover property (wr_ack_prop);


sequence overflowseq;
	fifo_if.overflow;
endsequence

property overflowprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
	(fifo_if.wr_en && fifo_if.full) |=> overflowseq;
endproperty

overflow_assert: assert property (overflowprop);
overflow_cover: cover property(overflowprop);


sequence underflowseq;
	fifo_if.underflow;
endsequence

property underflowprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n)
	(fifo_if.rd_en && fifo_if.empty) |=> underflowseq;
endproperty

underflow_assert: assert property (underflowprop);
underflow_cover: cover property (underflowprop);


sequence emptyseq;
	fifo_if.empty;
endsequence

property emptyprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) 
	(count == 0) |-> emptyseq;
endproperty

empty_assert: assert property (emptyprop);
empty_cover: cover property (emptyprop);


sequence fullseq;
	fifo_if.full;
endsequence

property fullprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) 
	(count == fifo_if.FIFO_DEPTH) |-> fullseq;
endproperty

full_assert: assert property (fullprop);
full_cover: cover property (fullprop);

sequence almostemptyseq;
	fifo_if.almostempty;
endsequence

property almostemptyprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) 
	(count == 1) |-> almostemptyseq;
endproperty

almostempty_assert: assert property (almostemptyprop);
almostempty_cover: cover property (almostemptyprop);


sequence almostfullseq;
	fifo_if.almostfull;
endsequence

property almostfullprop;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) 
	(count == fifo_if.FIFO_DEPTH - 1) |-> almostfullseq;
endproperty

almostfull_assert: assert property (almostfullprop);
almostfull_cover: cover property (almostfullprop);


property wr_ptr_wraparound_prop;
	@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
	(do_write && (wr_ptr == fifo_if.FIFO_DEPTH-1)) |=> (wr_ptr == 0);
endproperty
wr_ptr_wraparound_assert: assert property (wr_ptr_wraparound_prop);
wr_ptr_wraparound_cover: cover property (wr_ptr_wraparound_prop);


property rd_ptr_wraparound_prop;
	@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
	(do_read && (rd_ptr == fifo_if.FIFO_DEPTH-1)) |=> (rd_ptr == 0);
endproperty
rd_ptr_wraparound_assert: assert property (rd_ptr_wraparound_prop);
rd_ptr_wraparound_cover: cover property (rd_ptr_wraparound_prop);


property wr_ptr_threshold_prop;
	@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n)
	(wr_ptr <= fifo_if.FIFO_DEPTH-1);
endproperty
wr_ptr_threshold_assert: assert property (wr_ptr_threshold_prop);
wr_ptr_threshold_cover: cover property (wr_ptr_threshold_prop);


property rd_ptr_threshold_prop;
	@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) 
	(rd_ptr <= fifo_if.FIFO_DEPTH-1);
endproperty
rd_ptr_threshold_assert: assert property (rd_ptr_threshold_prop);
rd_ptr_threshold_cover: cover property (rd_ptr_threshold_prop);


property count_threshold_prop;
	@(posedge fifo_if.clk) disable iff(!fifo_if.rst_n) 
	(count <= fifo_if.FIFO_DEPTH);
endproperty

count_threshold_assert: assert property (count_threshold_prop);
count_threshold_cover: cover property (count_threshold_prop);


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