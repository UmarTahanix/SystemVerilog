import shared_pkg::*;
import transaction_pkg::*;
import scoreboard_pkg::*;
module FIFO_tb(FIFO_if.tb fifo_if);
    FIFO_transaction F_txn = new();
    initial begin
        error_count = 0;
        correct_count = 0;
        //Reset
        fifo_if.rst_n = 0;
        #5;
        fifo_if.rst_n = 1;
        repeat(10000) begin
            //Randomize F_txn variables
            assert(F_txn.randomize());
            //Assign the randomized inputs to fifo_in
            fifo_if.data_in <= F_txn.data_in;
            fifo_if.wr_en <= F_txn.wr_en;
            fifo_if.rd_en <= F_txn.rd_en;
            fifo_if.rst_n <= F_txn.rst_n;
            //Trigger the event @negedge fifo_if.clk
            @(negedge fifo_if.clk);
            -> driving_done;
        end

        for(int i = 0; i < 9; i++) begin
            fifo_if.wr_en <= 1;
            fifo_if.rd_en <= 0;
            fifo_if.rst_n <= 1;
            fifo_if.data_in = $urandom;
            @(negedge fifo_if.clk);
            -> driving_done;
        end

        fifo_if.wr_en <= 0; 
        fifo_if.rd_en <= 1;
        @(negedge fifo_if.clk);
        -> driving_done;

        fifo_if.wr_en <= 1; 
        fifo_if.rd_en <= 1;
        @(negedge fifo_if.clk);
        -> driving_done;

        test_finished = 1;
    end 
endmodule