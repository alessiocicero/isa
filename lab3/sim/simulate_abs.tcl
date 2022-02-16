quit -sim
vcom -93 -work ./work ../src_abs/c-constants.vhd
#load Datapath related files
vcom -93 -work ./work ../src/a-DataPath/a.a-FETCH/regn_ld.vhd
vcom -93 -work ./work ../src/a-DataPath/a.a-FETCH.vhd

vcom -93 -work ./work ../src/a-DataPath/a.b-DEC/RegisterFile.vhd
vcom -93 -work ./work ../src_abs/Decode_Logic.vhd
vcom -93 -work ./work ../src/a-DataPath/a.b-DEC/HDU.vhd
vcom -93 -work ./work ../src/a-DataPath/a.b-DEC.vhd

vcom -93 -work ./work ../src/a-DataPath/a.c-EXE/mux2to1.vhd
vcom -93 -work ./work ../src/a-DataPath/a.c-EXE/muxnbit_2to1.vhd
vcom -93 -work ./work ../src/a-DataPath/a.c-EXE/muxnbit_4to1.vhd
vcom -93 -work ./work ../src/a-DataPath/a.c-EXE/forwarding_unit.vhd
vcom -93 -work ./work ../src/a-DataPath/a.c-EXE/barrel_shifter.vhd
vcom -93 -work ./work ../src_abs/absolute_value.vhd
vcom -93 -work ./work ../src_abs/ALU.vhd
vcom -93 -work ./work ../src/a-DataPath/a.c-EXE.vhd

vcom -93 -work ./work ../src/a-DataPath/a.d-MEM.vhd

vcom -93 -work ./work ../src/a-DataPath/a.e-WB.vhd


#load main files
vcom -93 -work ./work ../src/a-DataPath.vhd
vcom -93 -work ./work ../src_abs/b-ControlUnit.vhd
vcom -93 -work ./work ../src/RISCV_lite.vhd

#load testbench
vlog -work ./work ../src/d-mem/d.a-ram.sv
vlog -work ./work ../tb/tb_riscv_lite.sv

vsim -novopt work.tb_riscv_lite "+firmware=code_abs.hex" "+data=data_abs.hex" "+verbose" "+vcd"
radix hex
add wave *
add wave sim:/tb_riscv_lite/CLK_i
add wave sim:/tb_riscv_lite/RST_n_i
add wave sim:/tb_riscv_lite/iram/mem
add wave sim:/tb_riscv_lite/dram/mem
add wave sim:/tb_riscv_lite/UUT/dp/decode/reg_file/reg_block
add wave sim:/tb_riscv_lite/UUT/cu/*
add wave sim:/tb_riscv_lite/UUT/dp/*
add wave sim:/tb_riscv_lite/UUT/dp/execute/*

run 2000 ns 


