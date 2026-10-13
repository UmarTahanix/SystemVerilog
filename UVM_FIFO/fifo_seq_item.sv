package fifo_seq_item_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_seq_item extends uvm_sequence_item;
        `uvm_object_utils(FIFO_seq_item)

        rand bit [FIFO_WIDTH-1:0] data_in;
        rand bit wr_en, rd_en, rst_n;

        bit [FIFO_WIDTH-1:0] data_out;
        bit full, almostfull, empty, almostempty, 
            overflow, underflow, wr_ack;

        int RD_EN_ON_DIST, WR_EN_ON_DIST;

        function new (string name = "FIFO_seq_item", int rd_en_dist = 30, wr_en_dist = 70);
            super.new(name);
            this.RD_EN_ON_DIST = rd_en_dist;
            this.WR_EN_ON_DIST = wr_en_dist;
        endfunction

        function string convert2string();
            return $sformatf({"%s rst_n = %0b, wr_en = %0b, rd_en = %0b, data_in = %0h, \n",
                             "data_out = %0h, full = %0b, almostfull = %0b, empty = %0b, \n",
                             "almostempty = %0b, overflow = %0b, underflow = %0b, wr_ack = %0b"},
                             super.convert2string(), rst_n, wr_en, rd_en, data_in, data_out, full, empty, almostfull, almostempty, overflow, underflow, wr_ack);
        endfunction

        function string convert2string_stimulus();
            return $sformatf({"rst_n = %0b, wr_en = %0b, rd_en = %0b, data_in = %0h, \n",
                             "data_out = %0h, full = %0b, almostfull = %0b, empty = %0b, \n",
                             "almostempty = %0b, overflow = %0b, underflow = %0b, wr_ack = %0b"},
                             rst_n, wr_en, rd_en, data_in, data_out, full, empty, almostfull, almostempty, overflow, underflow, wr_ack);
        endfunction

        constraint rst_n_c {
            rst_n dist {1:=90, 0:=10};
        }

        constraint wr_en_c {
            wr_en dist{
                1:=WR_EN_ON_DIST,
                0:=100-WR_EN_ON_DIST
            };
        }

        constraint rd_en_c {
            rd_en dist{
                1:=RD_EN_ON_DIST,
                0:=100-RD_EN_ON_DIST
            };
        }
    endclass
endpackage