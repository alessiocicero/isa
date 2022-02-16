rm -r work
rm riscv_syn.vcd
source /software/scripts/init_msim6.2g
vlib work
vsim -do simulate_post_syn_abs.tcl
