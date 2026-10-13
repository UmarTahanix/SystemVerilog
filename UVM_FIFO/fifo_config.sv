package fifo_config_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_config extends uvm_object;
        `uvm_object_utils(FIFO_config)

        virtual FIFO_if #(.FIFO_WIDTH(FIFO_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) fifo_vif;

        function new(string name = "FIFO_config");
            super.new(name);
        endfunction
    endclass
endpackage