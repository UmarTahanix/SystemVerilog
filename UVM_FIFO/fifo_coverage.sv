package fifo_coverage_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)

        uvm_analysis_export #(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;

        FIFO_seq_item seq_item;

        //FIFO's previous state where the request actually met
        bit full_prev  = 0;
        bit empty_prev = 1;
        bit almostfull_prev = 0;
        bit almostempty_prev = 0;

        covergroup t_cvr_grp;
            wr_en_cvr: coverpoint seq_item.wr_en iff (seq_item.rst_n);
            rd_en_cvr: coverpoint seq_item.rd_en iff (seq_item.rst_n);

            full_prev_cvr: coverpoint full_prev iff (seq_item.rst_n);
            almostfull_prev_cvr: coverpoint almostfull_prev iff (seq_item.rst_n);
            empty_prev_cvr: coverpoint empty_prev iff (seq_item.rst_n);
            almostempty_prev_cvr: coverpoint almostempty_prev iff (seq_item.rst_n);
            overflow_cvr: coverpoint seq_item.overflow iff (seq_item.rst_n);
            underflow_cvr: coverpoint seq_item.underflow iff (seq_item.rst_n);
            wr_ack_cvr: coverpoint seq_item.wr_ack iff (seq_item.rst_n);

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

        function new(string name = "FIFO_coverage", uvm_component parent);
            super.new(name, parent);
            t_cvr_grp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item);
                t_cvr_grp.sample();

                //For the next cycle
                full_prev = seq_item.full;
                empty_prev = seq_item.empty;
                almostfull_prev = seq_item.almostfull;
                almostempty_prev = seq_item.almostempty;
            end
        endtask
    endclass
endpackage