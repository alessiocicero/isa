analyze -f vhdl -lib WORK ../src/pipelined/flipflop.vhd
analyze -f vhdl -lib WORK ../src/multiplier/regn.vhd
analyze -f vhdl -lib WORK ../src/common/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../src/common/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../src/common/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../src/common/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage2_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage4_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_single_cycle.vhd
analyze -f vhdl -lib WORK ../src/pipelined/fpmul_pipeline.vhd
set power_preserve_rtl_hier_names true
#elaborate FPmul -arch pipeline -lib WORK
elaborate FPmul -arch pipeline -lib WORK > ./elaborate.txt
create_clock -name MY_CLK -period 1 CLK
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
ungroup -all -flatten
#set_implementation DW02.mult/csa [find cell *mult*]
compile
optimize_registers
report_timing > reports/pipelined/report_timing.txt
report_area > reports/pipelined/report_area.txt
