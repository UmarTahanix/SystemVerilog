vlib work
vlog shared_pkg.sv transaction_pkg.sv coverage_pkg.sv scoreboard_pkg.sv FIFO_if.sv FIFO_top.sv FIFO.sv FIFO_tb.sv FIFO_monitor.sv +cover
vsim -voptargs=+acc work.FIFO_top -cover -sv_seed random -l sim.log
add wave *
add wave -position end sim:/FIFO_top/fifo_if/*
add wave -position end sim:/FIFO_top/DUT/count
coverage save FIFO_top.ucdb -onexit
run 0 
add wave -position end  sim:/FIFO_top/monitor/F_txn
add wave -position end  sim:/FIFO_top/monitor/F_cvr
add wave -position end  sim:/FIFO_top/monitor/F_svd
add wave -position end  sim:/shared_pkg::error_count
add wave -position end  sim:/shared_pkg::correct_count
add wave -position end  sim:/FIFO_top/monitor/F_txn.wr_en
add wave -position end  sim:/FIFO_top/monitor/F_txn.rd_en
add wave -position end  sim:/FIFO_top/monitor/F_txn.full
run -all 