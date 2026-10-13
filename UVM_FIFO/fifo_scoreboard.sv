package fifo_scoreboard_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

        uvm_analysis_export #(FIFO_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
        FIFO_seq_item seq_item;

        localparam max_fifo_addr = $clog2(FIFO_DEPTH);
        
        logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];

        logic [max_fifo_addr-1:0] wr_ptr_ref, rd_ptr_ref;
        logic [max_fifo_addr:0] count_ref;
        bit [FIFO_WIDTH-1:0] data_out_ref;
        bit full_ref, almostfull_ref, empty_ref, almostempty_ref, overflow_ref, underflow_ref, wr_ack_ref;
        logic do_read_ref, do_write_ref;

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "FIFO_scoreboard", uvm_component parent);
            super.new(name, parent);
            count_ref = 0;
            wr_ptr_ref = 0;
            rd_ptr_ref = 0;
            full_ref = 0;
            empty_ref = 1;
            almostfull_ref = 0;
            almostempty_ref = 0; 
            overflow_ref = 0;
            underflow_ref = 0;
            wr_ack_ref = 0;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item);
                ref_model(seq_item);
                if(seq_item.data_out !== data_out_ref) begin
                    `uvm_error("run_phase", $sformatf("%s\nComparison failed, Transaction received by the DUT: %0h While the reference out: %0h, full: %0b, empty: %0b, almostfull: %0b, almostempty: %0b",
                                seq_item.convert2string(), seq_item.data_out, data_out_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref))
                    error_count++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct data out: %s", seq_item.convert2string()), UVM_HIGH);
                    correct_count++;
                end

                if(full_ref !== seq_item.full) begin
                    error_count++;
                    $display("Time: %0t, Error: Full mismatch, expected full = %0b, actual full = %0b",$time, full_ref, seq_item.full);
                end
                else
                    correct_count++;

                if(empty_ref !== seq_item.empty) begin
                    error_count++;
                    $display("Time: %0t, Error: Empty mismatch, expected empty = %0b, actual empty = %0b",$time, empty_ref, seq_item.empty);
                end
                else
                    correct_count++;

                if(almostfull_ref !== seq_item.almostfull) begin
                    error_count++;
                    $display("Time: %0t, Error: Almost_Full mismatch, expected almostfull = %0b, actual almostfull = %0b",$time, almostfull_ref, seq_item.almostfull);
                end
                else
                    correct_count++;

                if(almostempty_ref !== seq_item.almostempty) begin
                    error_count++;
                    $display("Time: %0t, Error: Almost_Empty mismatch, expected almostempty = %0b, actual almostempty = %0b",$time, almostempty_ref, seq_item.almostempty);
                end
                else
                    correct_count++;

                if(overflow_ref !== seq_item.overflow) begin
                    error_count++;
                    $display("Time: %0t, Error: Overflow mismatch, expected overflow = %0b, actual overflow = %0b",$time, overflow_ref, seq_item.overflow);
                end
                else
                    correct_count++;

                if(underflow_ref !== seq_item.underflow) begin
                    error_count++;
                    $display("Time: %0t, Error: Underflow mismatch, expected underflow = %0b, actual underflow = %0b",$time, underflow_ref, seq_item.underflow);
                end
                else
                    correct_count++;

                if(wr_ack_ref !== seq_item.wr_ack) begin
                    error_count++;
                    $display("Time: %0t, Error: Write_ack mismatch, expected wr_ack = %0b, actual wr_ack = %0b",$time, wr_ack_ref, seq_item.wr_ack);
                end
                else
                    correct_count++;                
            end
        endtask

        task ref_model(FIFO_seq_item seq_item);
            if(!seq_item.rst_n) begin
                wr_ptr_ref = 0;
                rd_ptr_ref = 0;
                count_ref = 0;
                full_ref = 0; 
                empty_ref = 1;
                almostfull_ref = 0;
                almostempty_ref = 0;
                overflow_ref = 0;
                underflow_ref = 0;
                wr_ack_ref = 0;
                return;
            end

            do_read_ref = 0;
            do_write_ref = 0;
            overflow_ref = 0;
            underflow_ref = 0;
            wr_ack_ref = 0;

            //Resolving reading and writing priority, especially when enable signals for both operations are simultaneously high
            if(seq_item.wr_en && seq_item.rd_en) begin
                if(empty_ref) begin
                    do_write_ref = 1;
                    underflow_ref = 1;
                end

                else if (full_ref) begin
                    do_read_ref = 1;
                    overflow_ref = 1;
                end

                else begin 
                    do_write_ref = 1;
                    do_read_ref = 1;
                end
            end
            
            else if(seq_item.wr_en && !seq_item.rd_en) begin
                    if(full_ref) begin
                        do_write_ref = 0;
                        overflow_ref = 1;
                    end
                    else
                        do_write_ref = 1;
            end
            
            else if(!seq_item.wr_en && seq_item.rd_en) begin
                if(empty_ref) begin
                        do_read_ref = 0;
                        underflow_ref = 1;
                    end
                    else
                        do_read_ref = 1;
            end

            //Writing process
            if (do_write_ref) begin
                mem_ref[wr_ptr_ref] = seq_item.data_in;
                wr_ptr_ref = (wr_ptr_ref + 1) % FIFO_DEPTH;
                wr_ack_ref = 1;
            end

            //Reading process
            if (do_read_ref) begin
                data_out_ref = mem_ref[rd_ptr_ref];
                rd_ptr_ref = (rd_ptr_ref + 1) % FIFO_DEPTH;
            end

            //Counting process
            case({do_read_ref, do_write_ref})
                2'b01: count_ref++;
                2'b10: count_ref--;
                default: count_ref = count_ref;
            endcase

            //Flags
            full_ref = 		 (count_ref == FIFO_DEPTH)? 1 : 0;
            empty_ref =  	 (count_ref == 0)? 1 : 0;
            almostfull_ref =  (count_ref == FIFO_DEPTH-1)? 1 : 0; 
            almostempty_ref = (count_ref == 1)? 1 : 0;
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM);
        endfunction
    endclass
endpackage