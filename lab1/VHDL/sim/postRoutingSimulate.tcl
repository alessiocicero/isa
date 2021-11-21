quit -sim
#vcom -93 -work ./work ../src/regn_ld.vhd
#vcom -93 -work ./work ../src/regn.vhd
#vcom -93 -work ./work ../src/check_overflow_mult.vhd 
#vcom -93 -work ./work ../src/check_overflow_add.vhd
#vcom -93 -work ./work ../src/check_overflow_sub.vhd
vlog -work ./work ../../innovus/IIR_filter.v

vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker.vhd
vcom -93 -work ./work ../tb/data_sink.vhd

vlog -work ./work ../tb/tb_iir.v

vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_iir
#vsim work.tb_iir
add wave *
add wave sim:/tb_iir/UUT/*
run 3500 ns 
