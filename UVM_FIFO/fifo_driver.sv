package fifo_driver_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_driver extends uvm_driver #(FIFO_seq_item);
        `uvm_component_utils(FIFO_driver)

        virtual FIFO_if fifo_vif;
        FIFO_seq_item seq_item;

        function new(string name = "FIFO_driver", uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            seq_item = FIFO_seq_item::type_id::create("seq_item");
            forever begin
                seq_item_port.get_next_item(seq_item);

                fifo_vif.data_in <= seq_item.data_in;
                fifo_vif.wr_en <= seq_item.wr_en;
                fifo_vif.rd_en <= seq_item.rd_en;
                fifo_vif.rst_n <= seq_item.rst_n;
                @(negedge fifo_vif.clk);
                seq_item_port.item_done();

                `uvm_info("run_phase", seq_item.convert2string_stimulus(), UVM_HIGH);
            end
        endtask
    endclass
endpackage