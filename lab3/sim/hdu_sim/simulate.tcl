quit -sim
vcom -93 -work ./work ../../src/c-constants.vhd
#load Datapath related files


vcom -93 -work ./work ../../src/a-DataPath/a.b-DEC/hazard_detection_unit.vhd

#load testbench
#RAM Written in System Verilog, delete if you don't like
vlog -work ./work ../../tb/tb_hdu/tb_hdu.v

vsim work.tb_hdu
add wave sim:/tb_hdu/DUT/*
add wave *
run 100 ns 


