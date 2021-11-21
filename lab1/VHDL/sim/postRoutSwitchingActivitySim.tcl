quit -sim
vlog -work ./work ../../innovus/IIR_filter.v

vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker.vhd
vcom -93 -work ./work ../tb/data_sink.vhd

vlog -work ./work ../tb/tb_iir.v

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir/UUT=../../innovus/IIR_filter.sdf work.tb_iir
vcd file ../../vcd/iir_filter_rout.vcd
vcd add /tb_iir/UUT/*
run 3500 ns
