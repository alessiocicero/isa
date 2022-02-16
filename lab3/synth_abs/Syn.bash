analyze -f vhdl -lib WORK ../src_abs/c-constants.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.a-FETCH/regn_ld.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.a-FETCH.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.b-DEC/RegisterFile.vhd
analyze -f vhdl -lib WORK ../src_abs/Decode_Logic.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.b-DEC/HDU.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.b-DEC.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE/mux2to1.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE/muxnbit_2to1.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE/muxnbit_4to1.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE/forwarding_unit.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE/barrel_shifter.vhd
analyze -f vhdl -lib WORK ../src_abs/ALU.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.c-EXE.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.d-MEM.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath/a.e-WB.vhd
analyze -f vhdl -lib WORK ../src/a-DataPath.vhd
analyze -f vhdl -lib WORK ../src_abs/b-ControlUnit.vhd
analyze -f vhdl -lib WORK ../src_abs/absolute_value.vhd
analyze -f vhdl -lib WORK ../src/RISCV_lite.vhd

set power_preserve_rtl_hier_names true
elaborate RISCV_lite -arch Structural -lib WORK > ./elaborate.txt
create_clock -name MY_CLK -period 3.5 clock
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clock]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
ungroup -all -flatten
compile
change_names -hierarchy -rules verilog
write_sdf ../netlist_abs/RISCV_lite.sdf
write -f verilog -hierarchy -output ../netlist_abs/RISCV_lite.v
write_sdc ../netlist_abs/RISCV_lite.sdc
report_timing > report/report_timing.txt
report_area > report/report_area.txt
report_power > report/report_power.txt
check_design > report/design_issues.txt
quit
