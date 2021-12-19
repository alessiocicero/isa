quit -sim
vcom -93 -work ./work ../src/pipelined/flipflop.vhd
vcom -93 -work ./work ../src/multiplier/regn.vhd
vcom -93 -work ./work ../src/common/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../src/common/fpround_fpround.vhd
vcom -93 -work ./work ../src/common/packfp_packfp.vhd
vcom -93 -work ./work ../src/common/unpackfp_unpackfp.vhd
vcom -93 -work ./work ../src/multiplier/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../src/multiplier/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../src/multiplier/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../src/multiplier/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../src/multiplier/fpmul_single_cycle.vhd
vcom -93 -work ./work ../src/pipelined/fpmul_pipeline.vhd

vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker.vhd
vcom -93 -work ./work ../tb/data_sink.vhd

vlog -work ./work ../tb/tb_fpmul.v

vsim work.tb_fpmul
add wave *
add wave sim:/tb_fpmul/UUT/*
run 200 ns 


