###############################################################################
## Project: XOR_PUF_Top_With_Pads  (Top-level including IO pads)
## Tool   : Cadence Genus Synthesis
## Author : IdeaLab
## Purpose: Synthesize Arbiter PUF design with IO pads and std cells
###############################################################################

###############################################################################
## 1. Global Variables and Directories
###############################################################################
set DESIGN XOR_PUF_Top_With_Pads
set GEN_EFF medium
set MAP_OPT_EFF high
set DATE [clock format [clock seconds] -format "%b%d-%T"]

set _OUTPUTS_PATH output_files
set _REPORTS_PATH report_files
set _LOG_PATH logs_${DATE}

###############################################################################
## 2. Library Setup (Std Cells + IO Pads)
###############################################################################
# Standard cell library
set STD_LIB "/home/c2s09/Documents/cadence/SCL_dir/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib"

# IO pad libraries (min and max corners)
set IO_LIB_MAX "/home/c2s09/Documents/cadence/SCL_dir/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_max.lib"
set IO_LIB_MIN "/home/c2s09/Documents/cadence/SCL_dir/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_min.lib"

# Load libraries
set_db / .library [list $STD_LIB $IO_LIB_MAX $IO_LIB_MIN]
read_libs -max_libs [list $STD_LIB $IO_LIB_MAX $IO_LIB_MIN]

# Optional settings
set_db / .information_level 7
set_db auto_ungroup none
set_db lp_power_analysis_effort high

###############################################################################
## 3. HDL Source Files and Search Paths
###############################################################################
set RTL_PATH "/home/c2s09/arbiter/new_io"
set FILE_LIST [list "$RTL_PATH/puf.v"]

set_db / .init_hdl_search_path [list . $RTL_PATH]
read_hdl $FILE_LIST

###############################################################################
## 4. Elaborate and Check Design
###############################################################################
elaborate $DESIGN
check_design -unresolved
time_info Elaboration

###############################################################################
## 5. Timing Constraints
###############################################################################
set SDC_FILE "$RTL_PATH/puf_time.sdc"
if {![file exists $SDC_FILE]} {
    puts "ERROR: SDC file not found: $SDC_FILE"
    exit 1
}
read_sdc $SDC_FILE
report_timing -lint -verbose

###############################################################################
## 6. Directory Preparation
###############################################################################
if {![file exists ${_OUTPUTS_PATH}]} {file mkdir ${_OUTPUTS_PATH}}
if {![file exists ${_REPORTS_PATH}]} {file mkdir ${_REPORTS_PATH}}

###############################################################################
## 7. Synthesis Flow
###############################################################################
# === GENERIC STAGE ===
set_db / .syn_generic_effort $GEN_EFF
syn_generic
time_info GENERIC
write_snapshot -outdir ${_REPORTS_PATH} -tag generic
report_dp > ${_REPORTS_PATH}/generic/${DESIGN}_datapath.rpt
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_generic.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_generic.sdc

# === MAPPING STAGE ===
set_db / .syn_map_effort $MAP_OPT_EFF
syn_map
time_info MAPPED
write_snapshot -outdir ${_REPORTS_PATH} -tag map
report_dp > ${_REPORTS_PATH}/map/${DESIGN}_datapath.rpt
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_map.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_map.sdc

# === OPTIMIZATION STAGE ===
set_db / .syn_opt_effort $MAP_OPT_EFF
syn_opt
write_snapshot -outdir ${_REPORTS_PATH} -tag syn_opt
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_opt.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_opt.sdc

# === SDF GENERATION ===
write_sdf -version 2.1 -recrem split -setuphold merge_when_paired -edges check_edge \
    > ${_OUTPUTS_PATH}/${DESIGN}.sdf

###############################################################################
## 8. Reports and Summary
###############################################################################
report_area > ${_REPORTS_PATH}/${DESIGN}_area.rpt
report_timing > ${_REPORTS_PATH}/${DESIGN}_timing.rpt
report_power > ${_REPORTS_PATH}/${DESIGN}_power.rpt

puts "====================================================="
puts "✅ SYNTHESIS COMPLETED SUCCESSFULLY"
puts "Top Module : $DESIGN"
puts "Libraries  : Std + IO Pads"
puts "Date/Time  : $DATE"
puts "====================================================="
time_info FINAL

