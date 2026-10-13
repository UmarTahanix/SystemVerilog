package fifo_test_pkg;
    import uvm_pkg::*;
    import fifo_shared_pkg::*;
    import fifo_seq_item_pkg::*;
    import fifo_sequencer_pkg::*;
    import fifo_env_pkg::*;
    import fifo_config_pkg::*;
    import fifo_reset_seq_pkg::*;
    import fifo_write_and_read_seq_pkg::*;
    import fifo_write_only_seq_pkg::*;
    import fifo_idle_seq_pkg::*;
    import fifo_read_only_seq_pkg::*;
    `include "uvm_macros.svh"
    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)

        virtual FIFO_if fifo_vif;
        FIFO_config cfg;
        FIFO_env env;
        FIFO_reset_seq rst_seq;
        FIFO_write_only_seq wr_only_seq;
        FIFO_read_only_seq rd_only_seq;
        FIFO_write_and_read_seq wr_rd_seq;
        FIFO_idle_seq idle_seq;

        function new(string name = "FIFO_test", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cfg             = FIFO_config::type_id::create("cfg");
            if(!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", cfg.fifo_vif))
              `uvm_fatal("build_phase", "Test - Unable to get the virtual interface");
            uvm_config_db #(FIFO_config)::set(this, "*", "CFG", cfg);
            
            env             = FIFO_env::type_id::create("env", this);
            
            rst_seq         = FIFO_reset_seq::type_id::create("rst_seq");
            wr_only_seq     = FIFO_write_only_seq::type_id::create("wr_only_seq");
            rd_only_seq     = FIFO_read_only_seq::type_id::create("rd_only_seq");
            wr_rd_seq       = FIFO_write_and_read_seq::type_id::create("wr_rd_seq");
            idle_seq        = FIFO_idle_seq::type_id::create("idle_seq");
            fifo_vif        = cfg.fifo_vif;
         
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);

            //reset sequence
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
            rst_seq.start(env.agt.sqr);
            `uvm_info( "run_phase", "Reset Deasserted", UVM_LOW);
            
            //write only sequence
            `uvm_info("run_phase", "Stimulus Generation for Write-only Started", UVM_LOW);
            wr_only_seq.start(env.agt.sqr);
            `uvm_info("run_ phase", "Stimulus Generation for Write-only Ended", UVM_LOW);
            
            //Idle sequence
            `uvm_info("run_phase", "Stimulus Generation for Idle Sequence Started", UVM_LOW);
            idle_seq.start(env.agt.sqr);
            `uvm_info("run_ phase", "Stimulus Generation for Idle Sequence Ended", UVM_LOW);
            
            //write-read sequence
            `uvm_info("run_phase", "Stimulus Generation for Write-Read Started", UVM_LOW);
            wr_rd_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Stimulus Generation for Write-Read Ended", UVM_LOW);
            
            //read only sequence
            `uvm_info("run_phase", "Stimulus Generation for Read-only Started", UVM_LOW);
            rd_only_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Stimulus Generation for Read-only Ended", UVM_LOW);
            
            //Idle sequence
            `uvm_info("run_phase", "Stimulus Generation for Idle Sequence Started", UVM_LOW);
            idle_seq.start(env.agt.sqr);
            `uvm_info("run_ phase", "Stimulus Generation for Idle Sequence Ended", UVM_LOW);
            
            //write-read sequence
            `uvm_info("run_phase", "Stimulus Generation for Write-Read Started", UVM_LOW);
            wr_rd_seq.start(env.agt.sqr);
            `uvm_info("run_phase", "Stimulus Generation for Write-Read Ended", UVM_LOW);
            
            phase.drop_objection(this);
        endtask: run_phase
    endclass
endpackage