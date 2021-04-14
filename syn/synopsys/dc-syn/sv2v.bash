#!/bin/bash

for file in $1/*.sv; do
	module=$(basename -s .sv $file)
	if echo "$module" | grep -q '_pkg$' ; then
	    continue
	fi
	${HOME}/Downloads/sv2v/bin/sv2v \
        --define=SYNTHESIS \
        $1/*_pkg.sv \
        $1/../vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
        -I$1/../vendor/lowrisc_ip/ip/prim/rtl \
        -I$1/../vendor/lowrisc_ip/dv/sv/dv_utils \
        $file > $2/${module}.sv
done
