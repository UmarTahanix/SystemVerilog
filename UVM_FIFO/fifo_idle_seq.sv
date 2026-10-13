package fifo_idle_seq_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_idle_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_idle_seq)

        FIFO_seq_item seq_item;

        function new(string name = "FIFO_idle_seq");
            super.new(name);
        endfunction

        task body;
            seq_item = FIFO_seq_item::type_id::create("seq_item");

            start_item(seq_item);

            seq_item.rst_n = 1;
            seq_item.wr_en = 0;
            seq_item.rd_en = 0;

            finish_item(seq_item);
        endtask
    endclass
endpackage