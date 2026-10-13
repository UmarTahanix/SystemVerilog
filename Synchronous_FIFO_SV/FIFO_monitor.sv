import shared_pkg::*;
import transaction_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
module FIFO_monitor(FIFO_if.monitor fifo_if);
    FIFO_transaction F_txn = new();
    FIFO_coverage F_cvr = new();
    FIFO_scoreboard #(.FIFO_WIDTH(fifo_if.FIFO_WIDTH), .FIFO_DEPTH(fifo_if.FIFO_DEPTH)) F_svd = new();

    initial begin
        $monitor("--> Time: %t, data_in = %0h, rst_n = %0b, wr_en = %0b, rd_en = %0b, \ndata_out = %0h, wr_ack = %0b, overflow = %0b, \nunderflow = %0b, \nfull = %0b, empty = %0b, almostfull = %0b, almostempty = %0b, \nfull_prev = %0b, empty_prev = %0b, almostfull_prev = %0b, almostempty_prev = %0b",
                     $time, fifo_if.data_in, fifo_if.rst_n, fifo_if.wr_en, fifo_if.rd_en,
                     fifo_if.data_out, fifo_if.wr_ack, fifo_if.overflow, fifo_if.underflow, fifo_if.full, 
                     fifo_if.empty, fifo_if.almostfull, fifo_if.almostempty,
                     F_txn.full_prev, F_txn.empty_prev, F_txn.almostfull_prev, F_txn.almostempty_prev);
        
        forever begin
            @(driving_done);
            //Comparing with the previous states of the flags
            F_txn.full_prev = F_txn.full;
            F_txn.empty_prev = F_txn.empty;
            F_txn.almostfull_prev = F_txn.almostfull;
            F_txn.almostempty_prev = F_txn.almostempty;

            F_txn.data_in = fifo_if.data_in;
            F_txn.rst_n = fifo_if.rst_n;
            F_txn.wr_en = fifo_if.wr_en;
            F_txn.rd_en = fifo_if.rd_en;

            F_txn.data_out = fifo_if.data_out;
            F_txn.wr_ack = fifo_if.wr_ack;
            F_txn.overflow = fifo_if.overflow;
            F_txn.underflow = fifo_if.underflow;
            F_txn.full = fifo_if.full;
            F_txn.empty = fifo_if.empty;
            F_txn.almostfull = fifo_if.almostfull;
            F_txn.almostempty = fifo_if.almostempty;
            $display("-->[SAMPLED] Time: %0t, data_in = %0h, rst_n = %0b, wr_en = %0b, rd_en = %0b, \ndata_out = %0h, wr_ack = %0b, overflow = %0b, \nunderflow = %0b, \nfull = %0b, empty = %0b, almostfull = %0b, almostempty = %0b, full_prev = %0b, empty_prev = %0b, almostfull_prev = %0b, almostempty_prev = %0b",
                     $time, F_txn.data_in, F_txn.rst_n, F_txn.wr_en, F_txn.rd_en,
                     F_txn.data_out, F_txn.wr_ack, F_txn.overflow, F_txn.underflow, F_txn.full, 
                     F_txn.empty, F_txn.almostfull, F_txn.almostempty,
                     F_txn.full_prev, F_txn.empty_prev, F_txn.almostfull_prev, F_txn.almostempty_prev);
            fork
                F_cvr.sample_data(F_txn);
                F_svd.check_data(F_txn);
            join

            if (test_finished) begin
                $display("Error count = %0d, correct count = %0d", error_count, correct_count);
                $stop;
            end
        end
    end
endmodule