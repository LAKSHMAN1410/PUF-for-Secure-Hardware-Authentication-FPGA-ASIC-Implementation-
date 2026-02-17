############### SDC CONSTRAINTS FOR SYNCHRONOUS PUF ############
##### TIME & CAPACITANCE UNITS #####
set_units -time 1ns
set_units -capacitance 1pF

#### CLOCK PARAMETERS ####
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

#### CLOCK CONSTRAINTS ####
# Real clock from external trigger pad
create_clock -name $TRIGGER_CLOCK_NAME -period $TRIGGER_CLOCK_PERIOD \
    -waveform {0 [expr $TRIGGER_CLOCK_PERIOD/2]} [get_ports i_trigger_pad]

# Virtual clock for input delays
create_clock -name trigger_vir_clk -period $TRIGGER_CLOCK_PERIOD

# Clock transitions
set_clock_transition -rise -min $TRIGGER_MINRISE -max $TRIGGER_MAXRISE [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_transition -fall -min $TRIGGER_MINFALL -max $TRIGGER_MAXFALL [get_clocks $TRIGGER_CLOCK_NAME]

# Clock uncertainty
set_clock_uncertainty -setup $TRIGGER_SKEW_setup [get_clocks $TRIGGER_CLOCK_NAME]
set_clock_uncertainty -hold $TRIGGER_SKEW_hold [get_clocks $TRIGGER_CLOCK_NAME]

#### INPUT TRANSITION CONSTRAINTS ####
set_input_transition -min $MIN_PORT -max $MAX_PORT [get_ports i_trigger_pad]
set_input_transition -min $MIN_PORT -max $MAX_PORT [get_ports i_challenge_pad[*]]

#### INPUT DELAYS ####
set_input_delay -add_delay -clock trigger_vir_clk -max 5 [get_ports i_trigger_pad]
set_input_delay -add_delay -clock trigger_vir_clk -min 2 [get_ports i_trigger_pad]
set_input_delay -add_delay -clock trigger_vir_clk -max 5 [get_ports i_challenge_pad[*]]
set_input_delay -add_delay -clock trigger_vir_clk -min 2 [get_ports i_challenge_pad[*]]

#### OUTPUT DELAYS ####
set_output_delay -clock trigger_vir_clk -max 5 -add_delay [get_ports o_response_pad]
set_output_delay -clock trigger_vir_clk -min 2 -add_delay [get_ports o_response_pad]

#### LOAD ####
set_load 5 [get_ports o_response_pad]

#### FALSE PATHS ####
# Trigger and challenge are asynchronous inputs to PUF chain
set_false_path -from [get_ports i_trigger_pad] -to [all_registers]
set_false_path -from [get_ports i_challenge_pad[*]] -to [all_registers]

#### PATH GROUPING ####
group_path -name I2O -from [all_inputs] -to [all_outputs]
group_path -name I2R -from [all_inputs] -to [all_registers]
group_path -name R2O -from [all_registers] -to [all_outputs]
group_path -name R2R -from [all_registers] -to [all_registers]

#### PHYSICAL PAD MAPPING ####
set_io i_trigger_pad pc3d01
set_io i_challenge_pad[0] pc3d01
set_io i_challenge_pad[1] pc3d01
set_io i_challenge_pad[2] pc3d01
set_io i_challenge_pad[3] pc3d01
set_io i_challenge_pad[4] pc3d01
set_io i_challenge_pad[5] pc3d01
set_io i_challenge_pad[6] pc3d01
set_io i_challenge_pad[7] pc3d01
set_io o_response_pad pc3o05

############### END OF FILE ##############

