#=======================================================================
# UCB VLSI FLOW: Toplevel Makefile
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#
# The toplevel makefile connects together all the tools in the
# toolflow. Each tool should include a target which will enter the
# appropriate tool directory and do a default make. Tool dependencies
# should be expressed simply by adding the appropriate producer tool
# targets to the consumer tool. For example, let's say we have three
# tools (ToolA, ToolB, and ToolC) and that ToolC uses the output from
# both ToolA and ToolB. We would write our tool targets as follows,
# assuming that there are appropriate tool directories named ToolA,
# ToolB, and ToolC. Notice that we should always add the tools to
# the running "tools" make variable so that make clean and other
# miscellaneous targets can be properly setup.
#
#  tools += ToolA
#  ToolA:
#    cd ToolA; make
#
#  tools += ToolB
#  ToolB:
#    cd ToolB; make
#
#  tools += ToolC
#  ToolC: ToolA ToolB
#    cd ToolC; make
#

default: pt-pwr

tools:=

#--------------------------------------------------------------------
# vcs-sim-rtl
#--------------------------------------------------------------------

vcs-sim-rtl:
	cd vcs-sim-rtl; make

vcs-sim-rtl-clean:
	cd vcs-sim-rtl; make clean

vcs-sim-rtl-check: vcs-sim-rtl
	cd vcs-sim-rtl; make check

tools += vcs-sim-rtl

#--------------------------------------------------------------------
# vcs-sim-gl-syn (post-synthesis gate simulation)
#--------------------------------------------------------------------

vcs-sim-gl-syn: dc-syn
	cd vcs-sim-gl-syn; make

vcs-sim-gl-syn-clean:
	cd vcs-sim-gl-syn; make clean

vcs-sim-gl-syn-check: vcs-sim-gl-syn
	cd vcs-sim-gl-syn; make check

vcs-sim-gl-syn-convert: vcs-sim-gl-syn-check
	cd vcs-sim-gl-syn; make convert

tools += vcs-sim-gl-syn

#--------------------------------------------------------------------
# vcs-sim-gl-par (post-place&route gate simulation)
#--------------------------------------------------------------------

vcs-sim-gl-par: icc-par
	cd vcs-sim-gl-par; make

vcs-sim-gl-par-clean:
	cd vcs-sim-gl-par; make clean

vcs-sim-gl-par-check: vcs-sim-gl-par
	cd vcs-sim-gl-par; make check

vcs-sim-gl-par-convert: vcs-sim-gl-par-check
	cd vcs-sim-gl-par; make convert

tools += vcs-sim-gl-par

#--------------------------------------------------------------------
# dc-syn
#--------------------------------------------------------------------

dc-syn:
	cd dc-syn; make

dc-syn-clean:
	cd dc-syn; make clean

tools += dc-syn

comb-dc:
	cd comb-dc; make

comb-dc-clean:
	cd comb-dc; make clean

tools += comb-dc

#--------------------------------------------------------------------
# icc-par
#--------------------------------------------------------------------

icc-par: dc-syn
	cd icc-par; make

icc-par-clean:
	cd icc-par; make clean

tools += icc-par


#--------------------------------------------------------------------
# pt-pwr-syn (port-synthesis power estimation
#--------------------------------------------------------------------

pt-pwr-syn: vcs-sim-gl-syn vcs-sim-gl-syn-convert
	cd pt-pwr-syn; make

pt-pwr-syn-clean:
	cd pt-pwr-syn; make clean

tools += pt-pwr-syn

#--------------------------------------------------------------------
# pt-pwr-par (port-place&route power estimation
#--------------------------------------------------------------------

pt-pwr-par: vcs-sim-gl-par vcs-sim-gl-par-convert
	cd pt-pwr-par; make

pt-pwr-par-clean:
	cd pt-pwr-par; make clean

tools += pt-pwr-par

#--------------------------------------------------------------------
# Misc
#--------------------------------------------------------------------
.PHONY: $(tools)

str = "RTL SIMULATION"
print:
	@echo "======================================================
	@echo "=== $str"
	@echo "======================================================

define run-flow-cmds
	make print str="CLEAN FLOW"
	make clean_no_promt 
	make print str="RTL SIMULATION"
	make vcs-sim-rtl && make vcs-sim-rtl-check
	make print str="DESIGN SYNTHESIS"
	make dc-syn
	make print str="POST-SYNTHESIS GATE SIMULATION"
	make vcs-sim-gl-syn && make vcs-sim-gl-syn-check
	make print str="POST-SYNTHESIS POWER ESTIMATION"
	make pt-pwr-syn
	make print str="PHYSICAL PLACE-and-ROUTE"
	make icc-par
	make print str="POST-PLACE-and-ROUTE GATE SIMULATION"
	make vcs-sim-gl-par && make vcs-sim-gl-syn-par
	make print str="POST-PLACE-and-ROUTE POWER SIMULATION"
	make pt-pwr-par
endef

run-flow: $(run-flow-cmds)

clean_nopromt:
	for tool in $(tools); \
  do \
      cd $$tool; make clean; cd ..; \
  done; \
  rm -rf *~ \#*; \

clean:
	@echo ""; \
	echo -n "  Are you sure you want to do a FULL clean? [Y/N] "; \
	read ans; \
	if [ "$$ans" == "Y" ]; \
	then \
	  for tool in $(tools); \
	  do \
        cd $$tool; make clean; cd ..; \
	  done; \
	  rm -rf *~ \#*; \
	fi; \
	echo "";
