quit -sim
vcom -93 -work ./work ../src/check_overflow_add.vhd
vcom -93 -work ./work ../src/tb_check_overflow_add.vhd

vsim work.tb_check_overflow_add
add wave *
run 90 ns 


