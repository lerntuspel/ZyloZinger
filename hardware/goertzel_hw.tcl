# TCL File Generated by Component Editor 21.1
# Fri Apr 14 17:23:13 EDT 2023
# DO NOT MODIFY


# 
# goertzel "goertzel" v1.0
#  2023.04.14.17:23:13
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module goertzel
# 
set_module_property DESCRIPTION ""
set_module_property NAME goertzel
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME goertzel
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_assignment embeddedsw.dts.vendor "csee4840"
set_module_assignment embeddedsw.dts.name "goertzel"
set_module_assignment embeddedsw.dts.group "aud"

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL goertzel
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file goertzel.sv SYSTEM_VERILOG PATH goertzel.sv TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter bin_coeff STD_LOGIC_VECTOR 0 ""
set_parameter_property bin_coeff DEFAULT_VALUE 0
set_parameter_property bin_coeff DISPLAY_NAME bin_coeff
set_parameter_property bin_coeff WIDTH 32
set_parameter_property bin_coeff TYPE STD_LOGIC_VECTOR
set_parameter_property bin_coeff UNITS None
set_parameter_property bin_coeff DESCRIPTION ""
set_parameter_property bin_coeff HDL_PARAMETER true


# 
# display items
# 


# 
# connection point power
# 
add_interface power conduit end
set_interface_property power associatedClock clock
set_interface_property power associatedReset ""
set_interface_property power ENABLED true
set_interface_property power EXPORT_OF ""
set_interface_property power PORT_NAME_MAP ""
set_interface_property power CMSIS_SVD_VARIABLES ""
set_interface_property power SVD_ADDRESS_GROUP ""

add_interface_port power power power Output 64
add_interface_port power advance done Output 1


# 
# connection point goertzel_ctrl
# 
add_interface goertzel_ctrl conduit end
set_interface_property goertzel_ctrl associatedClock clock
set_interface_property goertzel_ctrl associatedReset ""
set_interface_property goertzel_ctrl ENABLED true
set_interface_property goertzel_ctrl EXPORT_OF ""
set_interface_property goertzel_ctrl PORT_NAME_MAP ""
set_interface_property goertzel_ctrl CMSIS_SVD_VARIABLES ""
set_interface_property goertzel_ctrl SVD_ADDRESS_GROUP ""

add_interface_port goertzel_ctrl input_sig input_sig Input 24
add_interface_port goertzel_ctrl advance_in advance Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1

