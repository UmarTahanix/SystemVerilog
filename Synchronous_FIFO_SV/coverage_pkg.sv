package coverage_pkg;
    import transaction_pkg::*;
    
    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;

        covergroup t_cvr_grp;
            wr_en_cvr: coverpoint F_cvg_txn.wr_en iff (F_cvg_txn.rst_n);
            rd_en_cvr: coverpoint F_cvg_txn.rd_en iff (F_cvg_txn.rst_n);

            full_prev_cvr: coverpoint F_cvg_txn.full_prev iff (F_cvg_txn.rst_n);
            almostfull_prev_cvr: coverpoint F_cvg_txn.almostfull_prev iff (F_cvg_txn.rst_n);
            empty_prev_cvr: coverpoint F_cvg_txn.empty_prev iff (F_cvg_txn.rst_n);
            almostempty_prev_cvr: coverpoint F_cvg_txn.almostempty_prev iff (F_cvg_txn.rst_n);
            overflow_cvr: coverpoint F_cvg_txn.overflow iff (F_cvg_txn.rst_n);
            underflow_cvr: coverpoint F_cvg_txn.underflow iff (F_cvg_txn.rst_n);
            wr_ack_cvr: coverpoint F_cvg_txn.wr_ack iff (F_cvg_txn.rst_n);

            cross wr_en_cvr, rd_en_cvr, full_prev_cvr;
            cross wr_en_cvr, rd_en_cvr, almostfull_prev_cvr;
            cross wr_en_cvr, rd_en_cvr, empty_prev_cvr;
            cross wr_en_cvr, rd_en_cvr, almostempty_prev_cvr;
            cross wr_en_cvr, rd_en_cvr, overflow_cvr
            {
                //As long as there is no writing attempt, then overflow being 1 is impossible
                ignore_bins not_wr_en_and_overflow = binsof(wr_en_cvr) intersect {0}
                                                     && binsof(overflow_cvr) intersect {1};
            }
            cross wr_en_cvr, rd_en_cvr, underflow_cvr
            {
                //As long as there is no reading attempt, then underflow being 1 is impossible
                ignore_bins not_rd_en_and_underflow = binsof(rd_en_cvr) intersect {0}
                                                     && binsof(underflow_cvr) intersect {1};
            }
            cross wr_en_cvr, rd_en_cvr, wr_ack_cvr
            {
                //Practically impossible to have wr_en = 0 and wr_ack = 1 simultaneously
                ignore_bins wr_en_zero_and_ack_one = binsof(wr_en_cvr) intersect {0} 
                                                     && binsof(wr_ack_cvr) intersect {1};
            }
        endgroup

        function new();
            t_cvr_grp = new();
        endfunction

        function void sample_data(input FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            t_cvr_grp.sample();
        endfunction
    endclass
endpackage