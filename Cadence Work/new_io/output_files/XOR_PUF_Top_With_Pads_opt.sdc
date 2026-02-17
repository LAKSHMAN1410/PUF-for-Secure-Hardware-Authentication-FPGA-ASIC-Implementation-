# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Sun Oct 26 12:01:05 IST 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design XOR_PUF_Top_With_Pads

create_clock -name "trigger_vir_clk" -period 20.0 -waveform {0.0 10.0} 
set_load -pin_load 5.0 [get_ports o_response_pad]
set_false_path -from [get_ports i_trigger_pad] -to [list \
  [get_cells core/puf_inst/puf5/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf7/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf1/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf2/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf8/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf3/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf6/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf4/arbiter/response_bit_reg] ]
group_path -weight 1.000000 -name I2O -from [list \
  [get_ports i_trigger_pad]  \
  [get_ports {i_challenge_pad[7]}]  \
  [get_ports {i_challenge_pad[6]}]  \
  [get_ports {i_challenge_pad[5]}]  \
  [get_ports {i_challenge_pad[4]}]  \
  [get_ports {i_challenge_pad[3]}]  \
  [get_ports {i_challenge_pad[2]}]  \
  [get_ports {i_challenge_pad[1]}]  \
  [get_ports {i_challenge_pad[0]}] ] -to [get_ports o_response_pad]
group_path -weight 1.000000 -name I2R -from [list \
  [get_ports i_trigger_pad]  \
  [get_ports {i_challenge_pad[7]}]  \
  [get_ports {i_challenge_pad[6]}]  \
  [get_ports {i_challenge_pad[5]}]  \
  [get_ports {i_challenge_pad[4]}]  \
  [get_ports {i_challenge_pad[3]}]  \
  [get_ports {i_challenge_pad[2]}]  \
  [get_ports {i_challenge_pad[1]}]  \
  [get_ports {i_challenge_pad[0]}] ] -to [list \
  [get_cells core/puf_inst/puf5/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf7/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf1/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf2/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf8/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf3/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf6/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf4/arbiter/response_bit_reg] ]
group_path -weight 1.000000 -name R2O -from [list \
  [get_cells core/puf_inst/puf5/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf7/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf1/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf2/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf8/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf3/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf6/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf4/arbiter/response_bit_reg] ] -to [get_ports o_response_pad]
group_path -weight 1.000000 -name R2R -from [list \
  [get_cells core/puf_inst/puf5/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf7/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf1/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf2/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf8/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf3/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf6/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf4/arbiter/response_bit_reg] ] -to [list \
  [get_cells core/puf_inst/puf5/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf7/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf1/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf2/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf8/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf3/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf6/arbiter/response_bit_reg]  \
  [get_cells core/puf_inst/puf4/arbiter/response_bit_reg] ]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports i_trigger_pad]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports i_trigger_pad]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[7]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[6]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[5]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[4]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[3]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[2]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[1]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports {i_challenge_pad[0]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[7]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[6]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[5]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[4]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[3]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[2]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[1]}]
set_input_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports {i_challenge_pad[0]}]
set_output_delay -clock [get_clocks trigger_vir_clk] -add_delay -max 5.0 [get_ports o_response_pad]
set_output_delay -clock [get_clocks trigger_vir_clk] -add_delay -min 2.0 [get_ports o_response_pad]
set_input_transition -min 1.0 [get_ports i_trigger_pad]
set_input_transition -max 2.5 [get_ports i_trigger_pad]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[7]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[7]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[6]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[6]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[5]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[5]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[4]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[4]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[3]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[3]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[2]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[2]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[1]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[1]}]
set_input_transition -min 1.0 [get_ports {i_challenge_pad[0]}]
set_input_transition -max 2.5 [get_ports {i_challenge_pad[0]}]
set_wire_load_mode "enclosed"
set_dont_use true [get_lib_cells tsl18fs120_scl_ss/slbhb2]
set_dont_use true [get_lib_cells tsl18fs120_scl_ss/slbhb1]
set_dont_use true [get_lib_cells tsl18fs120_scl_ss/slbhb4]
