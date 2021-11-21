quit -sim
vcom -93 -work ./work ../src/regn_ld.vhd
vcom -93 -work ./work ../src/regn.vhd
vcom -93 -work ./work ../src/check_overflow_mult.vhd 
vcom -93 -work ./work ../src/check_overflow_add.vhd
vcom -93 -work ./work ../src/check_overflow_sub.vhd
vcom -93 -work ./work ../src/IIR_filter.vhd

vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker.vhd
vcom -93 -work ./work ../tb/data_sink.vhd

vlog -work ./work ../tb/tb_iir.v

vsim work.tb_iir
run 3500 ns 
quit -sim


