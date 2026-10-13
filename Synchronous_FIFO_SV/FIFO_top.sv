module FIFO_top;
    bit clk = 1;

    always #10 clk = ~clk;

    FIFO_if fifo_if(clk);

    FIFO DUT(fifo_if);
    FIFO_tb tb(fifo_if);
    FIFO_monitor monitor(fifo_if);
/*
    localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);

    logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
    logic [max_fifo_addr:0] count;
*/
    sequence rstseq;
	    (DUT.count === 0) && (fifo_if.wr_ack === 0) && (DUT.wr_ptr === 0) && (DUT.rd_ptr === 0);
    endsequence
    //Asynchronous reset
    property rstprop;
	    @(posedge fifo_if.clk) !fifo_if.rst_n |-> rstseq;
    endproperty
    rst_assert: assert property(rstprop) else $display("Time: %0t, wr_ack = %0b, count = %0d, wr_ptr = %0b, rd_ptr = %0b", 
                                                    $time, fifo_if.wr_ack, DUT.count, DUT.wr_ptr, DUT.rd_ptr);
    rst_cover: cover property(rstprop);
endmodule