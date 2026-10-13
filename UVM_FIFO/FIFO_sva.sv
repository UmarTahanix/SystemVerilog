import fifo_shared_pkg::*;

module FIFO_sva (
        input logic [FIFO_WIDTH-1:0] data_in,
        input logic wr_en, rd_en, rst_n,
        input logic [FIFO_WIDTH-1:0] data_out,
        input logic clk, full, almostfull, empty, almostempty, overflow, underflow, wr_ack,

        input logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr,
        input logic [$clog2(FIFO_DEPTH):0] count
);
    
    logic do_read, do_write;
    
    assign do_read = (rd_en && !empty);
    assign do_write = (wr_en && !full);

    always @(negedge rst_n) begin
        #1;
        rst_assert: assert ((count === 0) && (wr_ack === 0) && (wr_ptr === 0) && (rd_ptr === 0)) else $display("Time: %0t, wr_ack = %0b, count = %0d, wr_ptr = %0b, rd_ptr = %0b", 
                                                        $time, wr_ack, count, wr_ptr, rd_ptr);
        rst_cover: cover ((count === 0) && (wr_ack === 0) && (wr_ptr === 0) && (rd_ptr === 0));                                                        
    end
    /*
    sequence rstseq;
    	(count === 0) && (wr_ack === 0) && (wr_ptr === 0) && (rd_ptr === 0);
    endsequence
     //Asynchronous reset
    property rstprop;
    	@(posedge clk) !rst_n |-> rstseq;
    endproperty

    rst_assert: assert property(rstprop) else $display("Time: %0t, wr_ack = %0b, count = %0d, wr_ptr = %0b, rd_ptr = %0b", 
                                                        $time, wr_ack, count, wr_ptr, rd_ptr);
    rst_cover: cover property(rstprop);
    */

    sequence wr_ack_seq;
    	wr_ack;
    endsequence

    property wr_ack_prop;
    	@(posedge clk) disable iff (!rst_n)
    	(wr_en && !full) |=> wr_ack_seq;
    endproperty

    wr_ack_assert: assert property (wr_ack_prop);
    wr_ack_cover: cover property (wr_ack_prop);


    sequence overflowseq;
    	overflow;
    endsequence

    property overflowprop;
    	@(posedge clk) disable iff (!rst_n)
    	(wr_en && full) |=> overflowseq;
    endproperty

    overflow_assert: assert property (overflowprop);
    overflow_cover: cover property(overflowprop);


    sequence underflowseq;
    	underflow;
    endsequence

    property underflowprop;
    	@(posedge clk) disable iff (!rst_n)
    	(rd_en && empty) |=> underflowseq;
    endproperty

    underflow_assert: assert property (underflowprop);
    underflow_cover: cover property (underflowprop);


    sequence emptyseq;
    	empty;
    endsequence

    property emptyprop;
    	@(posedge clk) disable iff (!rst_n) 
    	(count === 0) |-> emptyseq;
    endproperty

    empty_assert: assert property (emptyprop);
    empty_cover: cover property (emptyprop);


    sequence fullseq;
    	full;
    endsequence

    property fullprop;
    	@(posedge clk) disable iff (!rst_n) 
    	(count === FIFO_DEPTH) |-> fullseq;
    endproperty

    full_assert: assert property (fullprop);
    full_cover: cover property (fullprop);

    sequence almostemptyseq;
    	almostempty;
    endsequence

    property almostemptyprop;
    	@(posedge clk) disable iff (!rst_n) 
    	(count === 1) |-> almostemptyseq;
    endproperty

    almostempty_assert: assert property (almostemptyprop);
    almostempty_cover: cover property (almostemptyprop);


    sequence almostfullseq;
    	almostfull;
    endsequence

    property almostfullprop;
    	@(posedge clk) disable iff (!rst_n) 
    	(count === FIFO_DEPTH - 1) |-> almostfullseq;
    endproperty

    almostfull_assert: assert property (almostfullprop);
    almostfull_cover: cover property (almostfullprop);


    property wr_ptr_wraparound_prop;
    	@(posedge clk) disable iff(!rst_n)
    	(do_write && (wr_ptr === FIFO_DEPTH-1)) |=> (wr_ptr === 0);
    endproperty
    wr_ptr_wraparound_assert: assert property (wr_ptr_wraparound_prop);
    wr_ptr_wraparound_cover: cover property (wr_ptr_wraparound_prop);


    property rd_ptr_wraparound_prop;
    	@(posedge clk) disable iff(!rst_n)
    	(do_read && (rd_ptr === FIFO_DEPTH-1)) |=> (rd_ptr === 0);
    endproperty
    rd_ptr_wraparound_assert: assert property (rd_ptr_wraparound_prop);
    rd_ptr_wraparound_cover: cover property (rd_ptr_wraparound_prop);


    property wr_ptr_threshold_prop;
    	@(posedge clk) disable iff(!rst_n)
    	(wr_ptr <= FIFO_DEPTH-1);
    endproperty
    wr_ptr_threshold_assert: assert property (wr_ptr_threshold_prop);
    wr_ptr_threshold_cover: cover property (wr_ptr_threshold_prop);


    property rd_ptr_threshold_prop;
    	@(posedge clk) disable iff(!rst_n) 
    	(rd_ptr <= FIFO_DEPTH-1);
    endproperty
    rd_ptr_threshold_assert: assert property (rd_ptr_threshold_prop);
    rd_ptr_threshold_cover: cover property (rd_ptr_threshold_prop);


    property count_threshold_prop;
    	@(posedge clk) disable iff(!rst_n) 
    	(count <= FIFO_DEPTH);
    endproperty

    count_threshold_assert: assert property (count_threshold_prop);
    count_threshold_cover: cover property (count_threshold_prop);

endmodule