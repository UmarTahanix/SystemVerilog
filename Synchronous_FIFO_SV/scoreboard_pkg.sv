package scoreboard_pkg;
    import transaction_pkg::*;
    import shared_pkg::*;
    
    class FIFO_scoreboard #(int FIFO_WIDTH=16, int FIFO_DEPTH=8);
        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];

        logic [max_fifo_addr-1:0] wr_ptr_ref, rd_ptr_ref;
        logic [max_fifo_addr:0] count_ref;
        bit [FIFO_WIDTH-1:0] data_out_ref;
        bit full_ref, almostfull_ref, empty_ref, almostempty_ref, overflow_ref, underflow_ref, wr_ack_ref;
        logic do_read_ref, do_write_ref;

        function new(); //As if it is reset-asserted once instantiated
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

        function void check_data(input FIFO_transaction F_txn);
            reference_model(F_txn);
            
            if(data_out_ref !== F_txn.data_out) begin
                error_count++;
                $display("Time: %0t, Error: Data_out mismatch, expected data_out = %0h, actual data_out = %0h",$time, data_out_ref, F_txn.data_out);
            end
            else
                correct_count++;

            if(full_ref !== F_txn.full) begin
                error_count++;
                $display("Time: %0t, Error: Full mismatch, expected full = %0b, actual full = %0b",$time, full_ref, F_txn.full);
            end
            else
                correct_count++;

            if(empty_ref !== F_txn.empty) begin
                error_count++;
                $display("Time: %0t, Error: Empty mismatch, expected empty = %0b, actual empty = %0b",$time, empty_ref, F_txn.empty);
            end
            else
                correct_count++;

            if(almostfull_ref !== F_txn.almostfull) begin
                error_count++;
                $display("Time: %0t, Error: Almost_Full mismatch, expected almostfull = %0b, actual almostfull = %0b",$time, almostfull_ref, F_txn.almostfull);
            end
            else
                correct_count++;
            
            if(almostempty_ref !== F_txn.almostempty) begin
                error_count++;
                $display("Time: %0t, Error: Almost_Empty mismatch, expected almostempty = %0b, actual almostempty = %0b",$time, almostempty_ref, F_txn.almostempty);
            end
            else
                correct_count++;
            
            if(overflow_ref !== F_txn.overflow) begin
                error_count++;
                $display("Time: %0t, Error: Overflow mismatch, expected overflow = %0b, actual overflow = %0b",$time, overflow_ref, F_txn.overflow);
            end
            else
                correct_count++;
            
            if(underflow_ref !== F_txn.underflow) begin
                error_count++;
                $display("Time: %0t, Error: Underflow mismatch, expected underflow = %0b, actual underflow = %0b",$time, underflow_ref, F_txn.underflow);
            end
            else
                correct_count++;

            if(wr_ack_ref !== F_txn.wr_ack) begin
                error_count++;
                $display("Time: %0t, Error: Write_ack mismatch, expected wr_ack = %0b, actual wr_ack = %0b",$time, wr_ack_ref, F_txn.wr_ack);
            end
            else
                correct_count++;
        endfunction
    
        function void reference_model(input FIFO_transaction F_txn);
            //Asynchronous reset
            if(!F_txn.rst_n) begin
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
            if(F_txn.wr_en && F_txn.rd_en) begin
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
            
            else if(F_txn.wr_en && !F_txn.rd_en) begin
                    if(full_ref) begin
                        do_write_ref = 0;
                        overflow_ref = 1;
                    end
                    else
                        do_write_ref = 1;
            end
            
            else if(!F_txn.wr_en && F_txn.rd_en) begin
                if(empty_ref) begin
                        do_read_ref = 0;
                        underflow_ref = 1;
                    end
                    else
                        do_read_ref = 1;
            end

            //Writing process
            if (do_write_ref) begin
                mem_ref[wr_ptr_ref] = F_txn.data_in;
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
        endfunction
    endclass
endpackage