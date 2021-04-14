# set dont_use cell here
	#set_dont_use [get_lib_cells */*LVT]


	#remove_attribute [get_lib_cells */INV*_LVT] 		dont_use
	#remove_attribute [get_lib_cells */IBUF*_LVT] 		dont_use
	#remove_attribute [get_lib_cells */NBUF*_LVT] 		dont_use
	#remove_attribute [get_lib_cells */TNBUFF*_LVT] 	dont_use

	#remove_attribute [get_lib_cells */PMT*_LVT] 		dont_use
	#remove_attribute [get_lib_cells */NMT*_LVT] 		dont_use

