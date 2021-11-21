quit -sim
vcom -93 -work ./work ../src/check_overflow_mult.vhd
vcom -93 -work ./work ../src/tb_mult_signed.vhd

vsim work.tb_mult_signed
add wave *
run 80 ns 


