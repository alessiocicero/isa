quit -sim
vcom -93 -work ./work ../../src/c-constants.vhd
#load Datapath related files


vcom -93 -work ./work ../../src_abs/ALU.vhd
vcom -93 -work ./work ../../src_abs/absolute_value.vhd
vcom -93 -work ./work ../../src/a-DataPath/a.c-EXE/barrel_shifter.vhd

#load testbench
#RAM Written in System Verilog, delete if you don't like
vlog -work ./work ../../tb/tb_ALU/tb_ALU.v

vsim work.tb_ALU
add wave sim:/tb_ALU/DUT/*
add wave *
run 100 ns 


