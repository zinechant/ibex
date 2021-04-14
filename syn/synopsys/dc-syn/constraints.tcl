# This constraint sets the target clock period for the chip in
# nanoseconds. Note that the first parameter is the name of the clock
# signal in your verlog design. If you called it something different than
# clk you will need to change this. You should set this constraint
# carefully. If the period is unrealistically small then the tools will
# spend forever trying to meet timing and ultimately fail. If the period
# is too large the tools will have no trouble but you will get a very
# conservative implementation.
create_clock -name ibex_clk -period ${CLOCK_PERIOD} {clk_i}

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. INVX1 is a small inverter and is
# reasonable if another block of on-chip logic is driving your inputs.
set_load -pin_load 0.004 [all_outputs]

set_driving_cell -lib_cell INVX1_LVT [all_inputs]


set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] instr_req_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] instr_addr_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] data_req_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] data_we_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] data_be_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] data_addr_o
set_output_delay -clock ibex_clk [expr (1.0 - (70.0 / 100.0)) * $CLOCK_PERIOD] data_wdata_o
set_output_delay -clock ibex_clk [expr (1.0 - (80.0 / 100.0)) * $CLOCK_PERIOD] core_sleep_o

set_input_delay  -clock ibex_clk  [expr (0.0  / 100.0) * $CLOCK_PERIOD] test_en_i     
set_input_delay  -clock ibex_clk  [expr (0.0  / 100.0) * $CLOCK_PERIOD] hart_id_i     
set_input_delay  -clock ibex_clk  [expr (0.0  / 100.0) * $CLOCK_PERIOD] boot_addr_i   
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] instr_gnt_i   
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] instr_rvalid_i
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] instr_rdata_i 
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] instr_err_i   
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] data_gnt_i    
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] data_rvalid_i 
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] data_rdata_i  
set_input_delay  -clock ibex_clk  [expr (30.0 / 100.0) * $CLOCK_PERIOD] data_err_i    
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] irq_software_i
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] irq_timer_i   
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] irq_external_i
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] irq_fast_i    
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] irq_nm_i      
set_input_delay  -clock ibex_clk  [expr (10.0 / 100.0) * $CLOCK_PERIOD] debug_req_i   
set_input_delay  -clock ibex_clk  [expr (0.0  / 100.0) * $CLOCK_PERIOD] fetch_enable_i