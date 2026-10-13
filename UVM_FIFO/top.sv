import fifo_test_pkg::*;
import fifo_shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
module top;
    bit clk = 1;

    initial begin
        forever
            #1 clk = ~clk;
    end 

    FIFO_if fifo_if(clk);
    FIFO DUT(fifo_if);

    bind FIFO FIFO_sva FIFO_sva_inst (
        .clk          (fifo_if.clk),
        .rst_n        (fifo_if.rst_n),
        .data_in      (fifo_if.data_in),
        .wr_en        (fifo_if.wr_en),
        .rd_en        (fifo_if.rd_en),
        .data_out     (fifo_if.data_out),
        .full         (fifo_if.full),
        .empty        (fifo_if.empty),
        .almostfull   (fifo_if.almostfull),
        .almostempty  (fifo_if.almostempty),
        .overflow     (fifo_if.overflow),
        .underflow    (fifo_if.underflow),
        .wr_ack       (fifo_if.wr_ack),
        .wr_ptr       (wr_ptr),
        .rd_ptr       (rd_ptr),
        .count        (count)
    );

    initial begin
        uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", fifo_if);
        run_test("FIFO_test");
    end
endmodule