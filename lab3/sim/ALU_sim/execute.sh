rm -r work
source /software/scripts/init_msim6.2g
vlib work
vsim -do simulate.tcl
