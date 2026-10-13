package fifo_write_only_seq_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_write_only_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_write_only_seq)

        FIFO_seq_item seq_item;

        function new(string name = "FIFO_write_only_seq");
            super.new(name);
        endfunction

        task body;
            repeat (1000) begin
                seq_item = FIFO_seq_item::type_id::create("seq_item");

                start_item(seq_item);

                assert(seq_item.randomize() with { rst_n == 1; wr_en == 1; rd_en == 0; });

                finish_item(seq_item);
            end
        endtask
    endclass
endpackage