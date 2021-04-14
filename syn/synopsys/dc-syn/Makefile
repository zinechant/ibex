#=======================================================================
# This makefile will use Synopsys Design Compiler to synthesize
# your RTL into a gate-level verilog netlist.
# This makefile will use Synopsys Formality to verify
# generated gate-level verilog netlist against your RTL implementation.
#
#=======================================================================

include ../Makefrag

default: all

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

# Library components

# Verilog sources (do not include test harness!)

srcdir = ../../../rtl
vsrcs = $(shell ls ../../../rtl/*.sv prim_clock_gating.sv | grep -v "pkg\.sv$$" | grep -v "ibex_tracer.sv$$" | sed "s/.*\/\([a-z0-9_]*\).sv/current-dc\/\1.sv/")

toplevel 		= ibex_top
testharness 	= $(toplevel)_test
toplevelinst 	= $(toplevel)_inst

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

dc_exec         		:= dc_shell -gui -64bit -topographical_mode
#dc_exec         		:= dc_shell-t  -64bit
fm_exec         		:= fm_shell -64bit
build_suffix    		:= $(shell date +%Y-%m-%d_%H-%M)
build_dc_dir    		:= build-dc-$(build_suffix)-$(toplevel)

reports_dir     		:= reports
results_dir     		:= results
log_dir         		:= log

stdcells_dir    := $(TECHNOLOGY_PATH)/$(STD_CELL_NAME)
cur_build_dc_dir:= current-dc
dc_timestamp    := $(cur_build_dc_dir)/timestamp
dc_ddc          := $(cur_build_dc_dir)/$(results_dir)/$(toplevel).mapped.ddc
fm_rpt          := $(cur_build_dc_dir)/$(reports_dir)/$(toplevel).fmv_verify.rpt

vars_tcl        := rm_setup/common_setup.tcl rm_setup/dc_setup.tcl rm_setup/dc_setup_filenames.tcl  rm_dc_scripts/dont_use_cell.tcl
makegen_tcl     := make_generated_vars.tcl

dc_tcl          := rm_dc_scripts/dc.tcl
dc_misc_tcl     := rm_dc_scripts/find_regs.tcl
fm_tcl          := rm_dc_scripts/fm.tcl
constraints_tcl := constraints.tcl

#TODO: add clock gated cells?
#set TARGET_LIBRARY_FILES        "cells.db cells_cg.db";\n \
	set TARGET_LIBRARY_FILES        	"saed32hvt_tt1p05v25c.db saed32lvt_tt1p05v25c.db";\n \
	set MW_REFERENCE_LIB_DIRS       	"$(stdcells_dir)/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m \
																		 $(stdcells_dir)/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m \
										  							 $(stdcells_dir)/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m";\n \
	set TARGET_LIBRARY_FILES		"saed32lvt_ss0p75v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32lvt_tt0p78v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32lvt_ff0p85v25c.db";\n \
	set MW_REFERENCE_LIB_DIRS		"$(stdcells_dir)/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m";\n \
	set TARGET_LIBRARY_FILES		"saed32rvt_ss0p75v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32rvt_tt0p78v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32rvt_ff0p85v25c.db";\n \
	set MW_REFERENCE_LIB_DIRS		"$(stdcells_dir)/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m";\n \
	set TARGET_LIBRARY_FILES		"saed32hvt_ss0p75v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32hvt_tt0p78v25c.db";\n \
	set TARGET_LIBRARY_FILES		"saed32hvt_ff0p85v25c.db";\n \
	set MW_REFERENCE_LIB_DIRS		"$(stdcells_dir)/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m";\n \

vars = \
	set DESIGN_NAME                	 	"$(toplevel)";\n \
	set STRIP_PATH                  	"$(testharness)/$(toplevelinst)";\n \
	set ADDITIONAL_SEARCH_PATH      	"$(stdcells_dir)/lib/stdcell_hvt/db_ccs \
										 								 $(stdcells_dir)/lib/stdcell_rvt/db_ccs \
										 								 $(stdcells_dir)/lib/stdcell_lvt/db_ccs \
										 								 ../$(srcdir)";\n \
	set TARGET_LIBRARY_FILES		"saed32lvt_ff0p85v25c.db";\n \
	set MW_REFERENCE_LIB_DIRS		"$(stdcells_dir)/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m";\n \
	set TECH_FILE                   	"$(stdcells_dir)/tech/milkyway/saed32nm_1p9m_mw.tf";\n \
	set MAP_FILE                    	"$(stdcells_dir)/tech/star_rcxt/saed32nm_tf_itf_tluplus.map";\n \
	set TLUPLUS_MAX_FILE            	"$(stdcells_dir)/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus";\n \
	set TLUPLUS_MIN_FILE            	"$(stdcells_dir)/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus";\n \
	set ALIB_DIR                    	".";\n \
	set RTL_SOURCE_FILES            	"$(notdir $(vsrcs))";\n \
	set DCRM_CONSTRAINTS_INPUT_FILE 	"constraints.tcl";\n \
	set REPORTS_DIR                 	"$(reports_dir)";\n \
	set RESULTS_DIR                 	"$(results_dir)";\n \
	set CLOCK_PERIOD               		"$(dc_clock_period)";\n \

define new-build-dir-cmds
	mkdir $(build_dc_dir)
	rm -f $(cur_build_dc_dir)
	ln -s $(build_dc_dir) $(cur_build_dc_dir)
	cp $(dc_tcl) $(dc_misc_tcl) $(constraints_tcl) $(vars_tcl) $(cur_build_dc_dir)
	bash sv2v.bash ${srcdir} ${cur_build_dc_dir}
	cp prim_clock_gating.sv ${cur_build_dc_dir}

	echo -e '$(vars)' > $(cur_build_dc_dir)/$(makegen_tcl)
	date > $(dc_timestamp)
endef

new-build-dir:
	$(new-build-dir-cmds)

$(dc_timestamp): Makefile $(vars_tcl) $(constraints_tcl) $(dc_tcl) $(dc_misc_tcl)
	$(new-build-dir-cmds)

$(dc_ddc): $(dc_timestamp)
	cd $(cur_build_dc_dir); \
	mkdir -p $(log_dir); \
	$(dc_exec) -f $(notdir $(dc_tcl)) | tee $(log_dir)/dc.log;

dc:
	rm -rf $(cur_build_dc_dir)
	make $(dc_ddc)

#--------------------------------------------------------------------
# Formal verification
#--------------------------------------------------------------------
$(fm_rpt): $(dc_ddc) $(fm_tcl)
	cp $(fm_tcl) $(constraints_tcl) $(vars_tcl) $(cur_build_dc_dir)
	echo -e '$(vars)' > $(cur_build_dc_dir)/$(makegen_tcl)
	cd $(cur_build_dc_dir); \
	mkdir -p $(log_dir); \
	$(fm_exec) -f $(notdir $(fm_tcl)) | tee $(log_dir)/fm.log; \
	cd ..

fm: $(fm_rpt)

#--------------------------------------------------------------------
# Default make target
#--------------------------------------------------------------------

.PHONY: dc fm

all: dc

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

junk +=

clean:
	rm -rf build* current* $(junk) *~ \#*
