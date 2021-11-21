quit -sim
vcom -93 -work ./work ../src/check_overflow_sub.vhd
vcom -93 -work ./work ../src/tb_check_overflow_sub.vhd

vsim work.tb_check_overflow_sub
add wave *
run 90 ns 


