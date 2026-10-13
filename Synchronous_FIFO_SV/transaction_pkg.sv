package transaction_pkg;
    class FIFO_transaction;
        parameter FIFO_WIDTH = 16;
        rand bit [FIFO_WIDTH-1:0] data_in;
        rand bit wr_en, rd_en, rst_n;
            
        bit [FIFO_WIDTH-1:0] data_out;
        bit clk, full, almostfull, empty, almostempty, overflow, underflow, wr_ack;

        bit full_prev, empty_prev, almostfull_prev, almostempty_prev;
        
        integer RD_EN_ON_DIST, WR_EN_ON_DIST;

        function new(integer rd_en_dist = 30, wr_en_dist = 70);
            this.RD_EN_ON_DIST = rd_en_dist;
            this.WR_EN_ON_DIST = wr_en_dist;
        endfunction

        constraint rst_n_c {
            rst_n dist{1:=90, 0:=10};
        }

        constraint wr_en_c {
            wr_en dist{1:=WR_EN_ON_DIST,
                       0:=100-WR_EN_ON_DIST};
        }

        constraint rd_en_c {
            rd_en dist{1:=RD_EN_ON_DIST,
                       0:=100-RD_EN_ON_DIST};
        }
    endclass
endpackage