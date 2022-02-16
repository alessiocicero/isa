quit -sim

#load riscv
vlog -work ./work ../netlist_abs/RISCV_lite.v

#load testbench
vlog -work ./work ../src/d-mem/d.a-ram.sv
vlog -work ./work ../tb/tb_riscv_lite.sv

vsim "+firmware=code_abs.hex" "+data=data_abs.hex" -L /software/dk/nangate45/verilog/msim6.2g work.tb_riscv_lite


radix hex
add wave *
add wave sim:/tb_riscv_lite/CLK_i
add wave sim:/tb_riscv_lite/RST_n_i
add wave sim:/tb_riscv_lite/iram/mem
add wave sim:/tb_riscv_lite/dram/mem
add wave sim:/tb_riscv_lite/UUT/*
#add wave sim:/tb_riscv_lite/UUT/dp/decode/reg_file/reg_block
#add wave sim:/tb_riscv_lite/UUT/cu/*
#add wave sim:/tb_riscv_lite/UUT/dp/*
#add wave sim:/tb_riscv_lite/UUT/dp/execute/*

run 2000 ns 


