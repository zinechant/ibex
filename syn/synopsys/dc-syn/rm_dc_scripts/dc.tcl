				source -echo -verbose dc_setup.tcl

				#################################################################################
				# Design Compiler Reference Methodology Script for Top-Down Flow
				# Script: dc.tcl
				# Version: D-2010.03-SP1 (May 24, 2010)
				# Copyright (C) 2007-2010 Synopsys, Inc. All rights reserved.
				#################################################################################

				#################################################################################
				# Additional Variables
				#
				# Add any additional variables needed for your flow here.
				#################################################################################

				# No additional flow variables are being recommended

				#################################################################################
				# Setup for Formality verification
				#
				# SVF should always be written to allow Formality verification
				# for advanced optimizations.
				#################################################################################

				set_svf ${RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

				#################################################################################
				# Setup SAIF Name Mapping Database
				#
				# Include an RTL SAIF for better power optimization and analysis.
				#
				# saif_map should be issued prior to RTL elaboration to create a name mapping
				# database for better annotation.
				################################################################################

				# saif_map -start

				#################################################################################
				# Read in the RTL Design
				#
				# Read in the RTL source files or read in the elaborated design (.ddc).
				# Use the -format option to specify: verilog, sverilog, or vhdl as needed.
				#################################################################################

				define_design_lib WORK -path ./WORK
				set_flatten true

				if {[regexp "vhd" ${RTL_SOURCE_FILES}] || [regexp "vhdl" ${RTL_SOURCE_FILES}]} {
					analyze -format vhdl  -define {DesignCompiler} ${RTL_SOURCE_FILES}
				} elseif {[regexp "sv" ${RTL_SOURCE_FILES}] || [regexp "SV" ${RTL_SOURCE_FILES}]} {
					analyze -format sverilog -define {DesignCompiler} ${RTL_SOURCE_FILES}
				} else	{
					analyze -format verilog -define {DesignCompiler} ${RTL_SOURCE_FILES}
				}

				elaborate ${DESIGN_NAME}

				# OR

				# You can read an elaborated design from the same release.
				# Using an elaborated design from an older release will not give the best results.

				# read_ddc ${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

				write -hierarchy -format ddc -output ${RESULTS_DIR}/${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

				# YUNSUP
				link 		   	 > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.postelab.link.rpt
				check_design > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.postelab.check.rpt

				#################################################################################
				# Apply Logical Design Constraints
				#################################################################################

				source -echo -verbose ${DCRM_CONSTRAINTS_INPUT_FILE}

				# You can enable analysis and optimization for multiple clocks per register.
				# To use this, you must constrain to remove false interactions between mutually exclusive
				# clocks.  This is needed to prevent unnecessary analysis that can result in
				# a significant runtime increase with this feature enabled.
				#
				# set_clock_groups -physically_exclusive | -logically_exclusive | -asynchronous \
				#                  -group {CLKA, CLKB} -group {CLKC, CLKD}
				#
				# set_app_var timing_enable_multiple_clocks_per_reg true

				#################################################################################
				# Apply The Operating Conditions
				#################################################################################

				# Set operating condition on top level

				# set_operating_conditions -max <max_opcond> -min <min_opcond>

				#################################################################################
				# Create Default Path Groups
				#
				# Separating these paths can help improve optimization.
				# Remove these path group settings if user path groups have already been defined.
				#################################################################################

				set ports_clock_root [filter_collection [get_attribute [get_clocks]   sources] object_class==port]
				set ports_reset_root [filter_collection [get_attribute [get_port rst] sources] object_class==port]

				group_path -name REGOUT -to [all_outputs]
				group_path -name REGIN -from [remove_from_collection [all_inputs] $ports_clock_root]
				group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]

				#################################################################################
				# Power Optimization Section
				#################################################################################

						#############################################################################
						# Clock Gating Setup
						#############################################################################

						# Default clock_gating_style suits most designs.  Change only if necessary.
						# set_clock_gating_style -positive_edge_logic {integrated} -negative_edge_logic {integrated} -control_point before ...

						# Clock gate insertion is now performed during compile_ultra -gate_clock
						# so insert_clock_gating is no longer recommended at this step.

						# The following setting can be used to enable global clock gating.
						# With global clock gating, common enables are extracted across hierarchies
						# which results in fewer redundant clock gates.

						# set compile_clock_gating_through_hierarchy true

						# For better timing optimization of enable logic, clock latency for
						# clock gating cells can be optionally specified.

						# set_clock_gate_latency -clock <clock_name> -stage <stage_num> \
						#         -fanout_latency {fanout_range1 latency_val1 fanout_range2 latency_val2 ...}

						#############################################################################
						# Apply Power Optimization Constraints
						#############################################################################

						# Include a SAIF file, if possible, for power optimization.  If a SAIF file
						# is not provided, the default toggle rate of 0.1 will be used for propagating
						# switching activity.

						# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose

						# Enable both of the following settings for total power optimization.
						# Note: set_max_total_power should no longer be used.

						# Use set_max_leakage_power only if you have multiple-Vt libraries.
						# set_max_leakage_power 0
						# set_max_dynamic_power 0

						if {[shell_is_in_topographical_mode]} {
							# Use the following command to enable power prediction using clock tree estimation.

							# set_power_prediction true -ct_references <LIB CELL LIST>
						}

				if {[shell_is_in_topographical_mode]} {

					##################################################################################
					# Apply Physical Design Constraints
					#
					# Optional: Floorplan information can be read in here if available.
					# This is highly recommended for irregular floorplans.
					#
					# Floorplan constraints can be provided from one of the following sources:
					# 	* extract_physical_constraints with a DEF file
					#	* read_floorplan with a floorplan file (written by write_floorplan)
					#	* User generated Tcl physical constraints
					#
					##################################################################################

					# Specify ignored layers for routing to improve correlation
					# Use the same ignored layers that will be used during place and route

					if { ${MIN_ROUTING_LAYER} != ""} {
						set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
					}
					if { ${MAX_ROUTING_LAYER} != ""} {
						set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
					}

					report_ignored_layers

  # If the macro names change after mapping and writing out the design due to
  # ungrouping or Verilog change_names renaming, it may be necessary to translate
  # the names to correspond to the cell names that exist before compile.

  # During DEF constraint extraction, extract_physical_constraints automatically
  # matches DEF names back to precompile names in memory using standard matching rules.
  # read_floorplan will also automatically perform this name matching.

  # Modify fuzzy_query_options if other characters are used for hierarchy separators
  # or bus names.

  # set_fuzzy_query_options -hierarchical_separators {/ _ .} \
  #                         -bus_name_notations {[] __ ()} \
  #                         -class {cell pin port net} \
  #                         -show

  ## For DEF floorplan input

  # The DEF file for DCT can be written from ICC using the following recommended options
  # icc_shell> write_def -version 5.7 -rows_tracks_gcells -macro -pins -blockages -specialnets \
  #                      -vias -region_groups -verbose -output ${DCRM_DCT_DEF_INPUT_FILE}

  if {[file exists [which ${DCRM_DCT_DEF_INPUT_FILE}]]} {
    extract_physical_constraints ${DCRM_DCT_DEF_INPUT_FILE}
  }

  # OR

  ## For floorplan file input

  # The floorplan file for DCT can be written from ICC using the following recommended options
  # Note: ICC requires the use of -placement {terminal} with -create_terminal beginning in the
  #       D-2010.03-SP1 release.
  # icc_shell> write_floorplan -placement {io hard_macro soft_macro terminal} -create_terminal \
  #                            -row -create_bound -preroute ${DCRM_DCT_FLOORPLAN_INPUT_FILE}

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]]} {
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}
  }

  # OR

  ## For Tcl file input

  # For Tcl constraints, the name matching feature must be explicitly enabled
  # and will also use the set_fuzzy_query_options setttings.  This should
  # be turned off after the constraint read in order to minimize runtime.

  if {[file exists [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]]} {
    set_app_var fuzzy_matching_enabled true
    source -echo -verbose ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}
    set_app_var fuzzy_matching_enabled false
  }


  # Use write_floorplan to save the applied floorplan.
  # Note: write_physical_constraints should no longer be used.
  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}

  # Verify that all the desired physical constraints have been applied
  # Add the -pre_route option to include pre-routes in the report
  report_physical_constraints > ${REPORTS_DIR}/${DCRM_DCT_PHYSICAL_CONSTRAINTS_REPORT}
}

#################################################################################
# Apply Additional Optimization Constraints
#################################################################################

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

#################################################################################
# Save the compile environment snapshot for the Consistency Checker utility.
#
# This utility checks for inconsistent settings between Design Compiler and
# IC Compiler which can contribute to correlation mismatches.
#
# Download this utility from SolvNet.  See the following SolvNet article for
# complete details:
#
# https://solvnet.synopsys.com/retrieve/026366.html
#
# The article is titled: "Using the Consistency Checker to Automatically Compare
# Environment Settings Between Design Compiler and IC Compiler"
#################################################################################

# Uncomment the following line to snapshot the environment for the Consistency Checker

# write_environment -consistency -output ${REPORTS_DIR}/${DCRM_CONSISTENCY_CHECK_ENV_FILE}

#################################################################################
# Compile the Design
#
# Recommended Options:
#
#     -scan
#     -gate_clock
#     -retime
#     -timing_high_effort_script
#     -congestion
#     -spg
#
# Use compile_ultra as your starting point. For test-ready compile, include
# the -scan option with the first compile and any subsequent compiles.
#
# Use -gate_clock to insert clock-gating logic during optimization.  This
# is now the recommended methodology for clock gating.
#
# Use -retime to enable adaptive retiming optimization for further timing
# benefit without any runtime or memory overhead.
#
# The -timing_high_effort_script option can be used to try and improve the
# optimization results at the tradeoff of some additional runtime.
#
# Note: The -area_high_effort_script option is not needed as it is aliased to
#       the default compile_ultra optimization.  The default compile_ultra
#       optimization is tuned to provide good area optimization.
#
# The -congestion option (topographical mode only) enables specialized optimizations that
# reduce routing related congestion during synthesis and scan compression insertion
# with DFT Compiler.  Only enable congestion optimization if required.
# This option requires a license for Design Compiler Graphical.
#
# Use the -spg option to enable Design Compiler Graphical to save physical
# guidance information and pass this information to IC Compiler.
# Physical guidance can improve area and timing correlation with IC Compiler.
# It also improves place_opt runtime in IC Compiler.
# The -spg option is not yet supported with the UPF or hierarchical flows.
# This option requires a license for Design Compiler Graphical.
#
# Note: The -num_cpus option is obsolete and should no longer be
#       used to enable multicore optimization.  It has been replaced by the
#       set_host_options command which can be found in the dc_setup.tcl script.
#
#################################################################################


if {[shell_is_in_topographical_mode]} {
# Use the "-check_only" option of "compile_ultra" to verify that your
# libraries and design are complete and that optimization will not fail
# in topographical mode.  Use the same options as will be used in compile_ultra.

# compile_ultra -gate_clock -check_only
}

link 	 	 		> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.presyn.link.rpt

set_cost_priority -delay

set_dont_use standard.sldb/DW01_addsub/rpl
#set_dont_use standard.sldb/DW01_addsub/cla
set_dont_use dw_foundation.sldb/DW01_addsub/pparch
set_dont_use dw_foundation.sldb/DW01_addsub/apparch

set_dont_use standard.sldb/DW01_add/rpl
#set_dont_use standard.sldb/DW01_add/cla
set_dont_use dw_foundation.sldb/DW01_add/pparch
set_dont_use dw_foundation.sldb/DW01_add/apparch

set_dont_use standard.sldb/DW01_inc/rpl
#set_dont_use standard.sldb/DW01_inc/cla
set_dont_use dw_foundation.sldb/DW01_inc/pparch
set_dont_use dw_foundation.sldb/DW01_inc/apparch


source -echo -verbose contraints.tcl
#source -echo -verbose constraints.tcl

#set_dont_touch ActionUnit
#set_dont_touch SBPUnit
#set_dout_touch ActivationUnit

#ungroup ActionUnit_
#ungroup ActivationUnit
#ungroup SBPUnit

#compile_ultra -gate_clock -no_autoungroup
#compile_ultra -timing_high_effort_script -no_design_rule
compile_ultra -timing_high_effort_script -gate_clock -retime

#remove_dont_touch ActionUnit
#remove_dont_touch SBPUnit
#remove_dont_touch ActivationUnit
#compile_ultra -top

check_design > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.postsyn.check.rpt


#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#    Milkyway:   Recommended binary format for IC Compiler
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#
#################################################################################

change_names -rules verilog -hierarchy


#################################################################################
# Write out Design
#################################################################################

# Write and close SVF file and make it available for immediate use
set_svf -off

write -format ddc -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}
write -f verilog -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}


#################################################################################
# Write out Design Data
#################################################################################

if {[shell_is_in_topographical_mode]} {

  # Note: write_physical_constraints should no longer be used.
  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}

  # Write parasitics data from DCT placement for static timing analysis
  write_parasitics      -output ${RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}
  write_parasitics      -output ${RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}.max
  write_parasitics -min -output ${RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}.min

  # Write SDF backannotation data from DCT placement for static timing analysis
  write_sdf ${RESULTS_DIR}/${DCRM_DCT_FINAL_SDF_OUTPUT_FILE}

  # Do not write out net RC info into SDC
  set_app_var write_sdc_output_lumped_net_capacitance false
  set_app_var write_sdc_output_net_resistance false
}

write_sdc -nosplit ${RESULTS_DIR}/${DCRM_FINAL_SDC_OUTPUT_FILE}

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
# saif_map -type ptpx -write_map ${RESULTS_DIR}/${DESIGN_NAME}.mapped.SAIF.namemap

#################################################################################
# Generate Final Reports
#################################################################################

#YUNSUP: elaborate

report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}

#report_timing -input_pins -capacitance -transition_time -nets -significant_digits 4 -nosplit -nworst 10 -max_paths 1 \
#							-from [remove_from_collection [all_inputs] $ports_reset_root $ports_clock_root] > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt

report_timing -input_pins -capacitance -transition_time -nets -significant_digits 4 -nosplit -nworst 1 -max_paths 1 \
							>> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt

report_timing -input_pins -capacitance -transition_time -nets -significant_digits 4 -nosplit -nworst 20 -max_paths 20 \
							>> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt


report_timing -input_pins -capacitance -transition_time -nets -significant_digits 4 -nosplit -nworst 20 -max_paths 20 \
							-to [all_outputs] >> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt

report_timing -attributes >> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.myattrib.rpt
create_qor_snapshot -infeasible_paths >> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.myqorcre.rpt
query_qor_snapshot -infeasible_paths >> ${REPORTS_DIR}/${DESIGN_NAME}.mapped.myqorquery.rpt
if {[shell_is_in_topographical_mode]} {
  report_area -hierarchy -physical -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
} else {
  report_area -hierarchy -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
}

if {[shell_is_in_topographical_mode]} {
  # report_congestion (topographical mode only) reports estimated routing related congestion
  # after topographical mode synthesis.
  # This command requires a license for Design Compiler Graphical.

  report_congestion -nosplit > ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_REPORT}

  # Use the following to generate and write out a congestion map from batch mode
  # This requires a GUI session to be temporarily opened and closed so a valid DISPLAY
  # must be set in your UNIX environment.

  # YUNSUP: turn off congestion map
  #if {[info exists env(DISPLAY)]} {
  #  gui_start

  #  # Create a layout window
  #  set MyLayout [gui_create_window -type LayoutWindow]

  #  # Build congestion map in case report_congestion was not previously run
  #  report_congestion -build_map

  #  # Display congestion map in layout window
  #  gui_show_map -map "Global Route Congestion" -show true

  #  # Zoom full to display complete floorplan
  #  gui_zoom -window [gui_get_current_window -view] -full

  #  # Write the congestion map out to an image file
  #  # You can specify the output image type with -format png | xpm | jpg | bmp

  #  # The following saves only the congestion map without the legends
  #  gui_write_window_image -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_OUTPUT_FILE}

  #  # The following saves the entire congestion map layout window with the legends
  #  gui_write_window_image -window ${MyLayout} -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_WINDOW_OUTPUT_FILE}

  #  gui_stop
  #} else {
  #  puts "Information: The DISPLAY environment variable is not set. Congestion map generation has been skipped."
  #}
}

# Use SAIF file for power analysis
# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose

set_switching_activity -toggle_rate 5 -period 100 -static_probability 0.5 -type inputs

report_power -nosplit -hier > ${REPORTS_DIR}/${DCRM_FINAL_POWER_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}

#YUNSUP: elaborate
report_reference -nosplit -hierarchy > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.reference.rpt
report_resources -nosplit -hierarchy > ${REPORTS_DIR}/${DESIGN_NAME}.mapped.resources.rpt

source find_regs.tcl
find_regs ${STRIP_PATH}

#################################################################################
# Write out Milkyway Design for Top-Down Flow
#
# This should be the last step in the script
#################################################################################

if {[shell_is_in_topographical_mode]} {
  # write_milkyway uses: mw_logic1_net, mw_logic0_net and mw_design_library variables from dc_setup.tcl
  write_milkyway -overwrite -output ${DCRM_FINAL_MW_CEL_NAME}
}

ungroup -all -flatten
set num_seq_cell [sizeof_collection [get_cells -hier -filter "is_hierarchical==false && is_black_box==false && is_sequential==true"]]
redirect         "${REPORTS_DIR}/${DESIGN_NAME}.mapped.cell.flatten.rpt"     { report_cell }
redirect -append "${REPORTS_DIR}/${DESIGN_NAME}.mapped.cell.flatten.rpt"     { puts "\n\n"}
redirect -append "${REPORTS_DIR}/${DESIGN_NAME}.mapped.cell.flatten.rpt"     { puts "Number of sequential cells   $num_seq_cell" }

exit
