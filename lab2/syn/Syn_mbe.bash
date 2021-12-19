analyze -f vhdl -lib WORK ../src/mbe/ppmatrix.vhd
analyze -f vhdl -lib WORK ../src/mbe/half_adder.vhd
analyze -f vhdl -lib WORK ../src/mbe/full_adder.vhd
analyze -f vhdl -lib WORK ../src/mbe/partial_products_generator.vhd
analyze -f vhdl -lib WORK ../src/mbe/partial_products_add.vhd
analyze -f vhdl -lib WORK ../src/mbe/sign_extension.vhd
analyze -f vhdl -lib WORK ../src/mbe/daddaTree.vhd
analyze -f vhdl -lib WORK ../src/mbe/mbe.vhd
analyze -f vhdl -lib WORK ../src/multiplier/regn.vhd
analyze -f vhdl -lib WORK ../src/common/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../src/common/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../src/common/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../src/common/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../src/mbe/fpmul_stage2_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_stage4_struct.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_single_cycle.vhd
analyze -f vhdl -lib WORK ../src/multiplier/fpmul_pipeline.vhd
set power_preserve_rtl_hier_names true
#elaborate FPmul -arch pipeline -lib WORK
elaborate FPmul -arch pipeline -lib WORK > ./elaborate.txt
create_clock -name MY_CLK -period 2.8 CLK
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
ungroup -all -flatten
#set_implementation DW02.mult/csa [find cell *mult*]
compile
report_timing > report_timing.txt
report_area > report_area.txt
