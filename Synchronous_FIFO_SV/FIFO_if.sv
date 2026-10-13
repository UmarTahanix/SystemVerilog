interface FIFO_if #(parameter FIFO_WIDTH=16, FIFO_DEPTH=8) (input bit clk);
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow, underflow,
          full, empty, almostfull, almostempty;

    modport DUT(input data_in, clk, rst_n, wr_en, rd_en,
                output data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);

    modport tb(output data_in, rst_n, wr_en, rd_en,
                input data_out, clk, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);

    modport monitor(input data_in, clk, rst_n, wr_en, rd_en,
                    data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);
endinterface