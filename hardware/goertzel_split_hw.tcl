# TCL File Generated by Component Editor 21.1
# Fri Apr 14 17:25:20 EDT 2023
# DO NOT MODIFY


# 
# goertzel_split "goertzel_split" v1.0
#  2023.04.14.17:25:20
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module goertzel_split
# 
set_module_property DESCRIPTION ""
set_module_property NAME goertzel_split
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME goertzel_split
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_assignment embeddedsw.dts.vendor "csee4840"
set_module_assignment embeddedsw.dts.name "goertzel_split"
set_module_assignment embeddedsw.dts.group "aud"

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL goertzel_split
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file goertzel.sv SYSTEM_VERILOG PATH goertzel.sv TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point input
# 
add_interface input conduit end
set_interface_property input associatedClock clock
set_interface_property input associatedReset ""
set_interface_property input ENABLED true
set_interface_property input EXPORT_OF ""
set_interface_property input PORT_NAME_MAP ""
set_interface_property input CMSIS_SVD_VARIABLES ""
set_interface_property input SVD_ADDRESS_GROUP ""

add_interface_port input input_sig input_sig Input 24
add_interface_port input advance_in advance Input 1


# 
# connection point output1
# 
add_interface output1 conduit end
set_interface_property output1 associatedClock clock
set_interface_property output1 associatedReset ""
set_interface_property output1 ENABLED true
set_interface_property output1 EXPORT_OF ""
set_interface_property output1 PORT_NAME_MAP ""
set_interface_property output1 CMSIS_SVD_VARIABLES ""
set_interface_property output1 SVD_ADDRESS_GROUP ""

add_interface_port output1 output_sig1 input_sig Output 24
add_interface_port output1 advance1 advance Output 1


# 
# connection point output2
# 
add_interface output2 conduit end
set_interface_property output2 associatedClock clock
set_interface_property output2 associatedReset ""
set_interface_property output2 ENABLED true
set_interface_property output2 EXPORT_OF ""
set_interface_property output2 PORT_NAME_MAP ""
set_interface_property output2 CMSIS_SVD_VARIABLES ""
set_interface_property output2 SVD_ADDRESS_GROUP ""

add_interface_port output2 output_sig2 input_sig Output 24
add_interface_port output2 advance2 advance Output 1


# 
# connection point output3
# 
add_interface output3 conduit end
set_interface_property output3 associatedClock clock
set_interface_property output3 associatedReset ""
set_interface_property output3 ENABLED true
set_interface_property output3 EXPORT_OF ""
set_interface_property output3 PORT_NAME_MAP ""
set_interface_property output3 CMSIS_SVD_VARIABLES ""
set_interface_property output3 SVD_ADDRESS_GROUP ""

add_interface_port output3 output_sig3 input_sig Output 24
add_interface_port output3 advance3 advance Output 1


# 
# connection point output4
# 
add_interface output4 conduit end
set_interface_property output4 associatedClock clock
set_interface_property output4 associatedReset ""
set_interface_property output4 ENABLED true
set_interface_property output4 EXPORT_OF ""
set_interface_property output4 PORT_NAME_MAP ""
set_interface_property output4 CMSIS_SVD_VARIABLES ""
set_interface_property output4 SVD_ADDRESS_GROUP ""

add_interface_port output4 output_sig4 input_sig Output 24
add_interface_port output4 advance4 advance Output 1


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

