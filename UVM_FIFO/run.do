vdel -all
vlib work
vlog -f src_files.list +cover -covercells -l compile.log
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all
add wave /top/fifo_if/*
coverage save top.ucdb -onexit
run -all
coverage report -code bcesf -details -output code_cov_report.txt
coverage report -cvg -details -output func_cov_report.txt
coverage report -assert -details -output assertion_report.txt