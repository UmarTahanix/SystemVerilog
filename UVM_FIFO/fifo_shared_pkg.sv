package fifo_shared_pkg;
    bit test_finished;
    int error_count, correct_count;
    event driving_done; //For tb and monitor 

    parameter FIFO_WIDTH = 16, 
              FIFO_DEPTH = 8;
endpackage