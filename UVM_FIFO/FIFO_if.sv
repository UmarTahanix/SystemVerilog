import fifo_shared_pkg::*;

interface FIFO_if #(parameter FIFO_WIDTH=16, FIFO_DEPTH=8) (input bit clk);
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow, underflow,
          full, empty, almostfull, almostempty;
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(FIFO_DEPTH):0] count;

    modport DUT(input data_in, clk, rst_n, wr_en, rd_en,
                output data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);
endinterface