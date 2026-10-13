package fifo_sequencer_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_sequencer extends uvm_sequencer #(FIFO_seq_item);
        `uvm_component_utils(FIFO_sequencer)

        function new(string name = "FIFO_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass
endpackage