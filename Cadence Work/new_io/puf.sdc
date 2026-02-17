############### SDC CONSTRAINTS ############
##### PARAMETERS #####
set_units -time 1.0ns;
set_units -capacitance 1.0pF;

#### Clock / Trigger Parameters ####
set TRIGGER_CLOCK_PERIOD 20
set TRIGGER_CLOCK_NAME trigger_clk
set TRIGGER_SKEW_setup [expr $TRIGGER_CLOCK_PERIOD * 0.025]
set TRIGGER_SKEW_hold  [expr $TRIGGER_CLOCK_PERIOD * 0.025]
set TRIGGER_MINRISE [expr $TRIGGER_CLOCK_PERIOD * 0.125]
set TRIGGER_MAXRISE [expr $TRIGGER_CLOCK_PERIOD * 0.2]
set TRIGGER_MINFALL [expr $TRIGGER_CLOCK_PERIOD * 0.125]
set TRIGGER_MAXFALL [expr $TRIGGER_CLOCK_PERIOD * 0.2]

set MIN_PORT 1
set MAX_PORT 2.5

####### CLOCK CONSTRAINTS #########
# create a real clock on the external trigger pad (period in ns)
create_clock -name "$TRIGGER_CLOCK_NAME" -period $TRIGGER_CLOCK_PERIOD \
    -waveform {0 [expr $TRIGGER_CLOCK_PERIOD/2]} [get_ports i_trigger_pad]

## Virtual Clock (for input delay reference)
create_clock -name trigger_vir_clk -period $TRIGGER_CLOCK_PERIOD

# Clock source latency (source-edge insertion delays) -- set both late and early with min/max
set_clock_latency -source -max 1.25 -late  [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_latency -source -min 0.75 -late  [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_latency -source -max 1.25 -early [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_latency -source -min 0.75 -early [get_clocks $TRIGGER_CLOCK_NAME]

# Clock transition (rise/fall time windows)
set_clock_transition -rise -min $TRIGGER_MINRISE [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_transition -rise -max $TRIGGER_MAXRISE [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_transition -fall -min $TRIGGER_MINFALL [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_transition -fall -max $TRIGGER_MAXFALL [get_clocks $TRIGGER_CLOCK_NAME]

####### INPUT TRANSITION CONSTRAINTS ########
set_input_transition -max $MAX_PORT [get_ports i_trigger_pad]
set_input_transition -min $MIN_PORT [get_ports i_trigger_pad]

# For the vector challenge inputs (all bits)
set_input_transition -max $MAX_PORT [get_ports i_challenge_pad[*]]
set_input_transition -min $MIN_PORT [get_ports i_challenge_pad[*]]

####### CLOCK UNCERTAINTY ########
set_clock_uncertainty -setup $TRIGGER_SKEW_setup [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_uncertainty -hold  $TRIGGER_SKEW_hold  [get_clocks $TRIGGER_CLOCK_NAME]

####### INPUT DELAY ########
# Use the virtual clock as the timing reference for input delays
# -add_delay means these delays are external I/O delays to be added to timing path
set_input_delay -add_delay -clock trigger_vir_clk -max 5 [get_ports i_trigger_pad]
set_input_delay -add_delay -clock trigger_vir_clk -min 2 [get_ports i_trigger_pad]
set_input_delay -add_delay -clock trigger_vir_clk -max 5 [get_ports i_challenge_pad[*]]
set_input_delay -add_delay -clock trigger_vir_clk -min 2 [get_ports i_challenge_pad[*]]

####### OUTPUT DELAY ########
# Output pad delay relative to virtual clock
set_output_delay -clock trigger_vir_clk -max 5 [get_ports o_response_pad] -add_delay
set_output_delay -clock trigger_vir_clk -min 2 [get_ports o_response_pad] -add_delay

####### LOAD SPECIFICATIONS ########
set_load 5 [get_ports o_response_pad]

####### FALSE PATHS ###########
# Trigger is asynchronous (external pulse), so exclude from register timing analysis if desired.
# This depends on your design intent — here we mark paths originating at the external trigger pad as false to registers.
set_false_path -from [get_ports i_trigger_pad] -to [all_registers]

####### GROUP PATHS #########
group_path -name I2O -from [all_inputs] -to [all_outputs]
group_path -name I2R -from [all_inputs] -to [all_registers]
group_path -name R2O -from [all_registers] -to [all_outputs]
group_path -name R2R -from [all_registers] -to [all_registers]

####### PHYSICAL PAD MAPPING #########
# NOTE: many place & route flows expect set_io to map logical port -> PACKAGE PIN name.
# If your flow uses pad-cell names here (pc3d01 / pc3o05) that matches your flow, keep as-is.
# If the tool expects actual package pins, replace 'pc3d01'/'pc3o05' with the package pin names.
# Trigger input
set_io i_trigger_pad pc3d01
# Challenge inputs (vector)
set_io i_challenge_pad[0] pc3d01
set_io i_challenge_pad[1] pc3d01
set_io i_challenge_pad[2] pc3d01
set_io i_challenge_pad[3] pc3d01
set_io i_challenge_pad[4] pc3d01
set_io i_challenge_pad[5] pc3d01
set_io i_challenge_pad[6] pc3d01
set_io i_challenge_pad[7] pc3d01
# Response output
set_io o_response_pad pc3o05

############### END OF FILE ##############

