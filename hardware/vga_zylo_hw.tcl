# TCL File Generated by Component Editor 21.1
# Mon May 01 21:58:13 EDT 2023
# DO NOT MODIFY


# 
# vga_zylo "VGA zylo" v1.2
#  2023.05.01.21:58:13
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module vga_zylo
# 
set_module_property DESCRIPTION ""
set_module_property NAME vga_zylo
set_module_property VERSION 1.2
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "VGA zylo"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_assignment embeddedsw.dts.vendor "csee4840"
set_module_assignment embeddedsw.dts.name "vga_zylo"
set_module_assignment embeddedsw.dts.group "vga"

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL vga_zylo
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file vga_zylo.sv SYSTEM_VERILOG PATH vga_zylo.sv
add_fileset_file sprites.sv SYSTEM_VERILOG PATH sprites.sv
add_fileset_file 0.mem OTHER PATH sprites/Sprite_rom/0.mem
add_fileset_file 1.mem OTHER PATH sprites/Sprite_rom/1.mem
add_fileset_file 2.mem OTHER PATH sprites/Sprite_rom/2.mem
add_fileset_file 3.mem OTHER PATH sprites/Sprite_rom/3.mem
add_fileset_file 4.txt OTHER PATH sprites/Sprite_rom/4.txt
add_fileset_file 5.txt OTHER PATH sprites/Sprite_rom/5.txt
add_fileset_file 6.txt OTHER PATH sprites/Sprite_rom/6.txt
add_fileset_file 7.txt OTHER PATH sprites/Sprite_rom/7.txt
add_fileset_file 8.txt OTHER PATH sprites/Sprite_rom/8.txt
add_fileset_file 9.txt OTHER PATH sprites/Sprite_rom/9.txt
add_fileset_file B.txt OTHER PATH sprites/Sprite_rom/B.txt
add_fileset_file Blue-left.txt OTHER PATH sprites/Sprite_rom/Blue-left.txt
add_fileset_file Blue-right.txt OTHER PATH sprites/Sprite_rom/Blue-right.txt
add_fileset_file C.txt OTHER PATH sprites/Sprite_rom/C.txt
add_fileset_file E.txt OTHER PATH sprites/Sprite_rom/E.txt
add_fileset_file M.txt OTHER PATH sprites/Sprite_rom/M.txt
add_fileset_file O.txt OTHER PATH sprites/Sprite_rom/O.txt
add_fileset_file Orange-left.txt OTHER PATH sprites/Sprite_rom/Orange-left.txt
add_fileset_file Orange-right.txt OTHER PATH sprites/Sprite_rom/Orange-right.txt
add_fileset_file Pink-left.txt OTHER PATH sprites/Sprite_rom/Pink-left.txt
add_fileset_file Pink-right.txt OTHER PATH sprites/Sprite_rom/Pink-right.txt
add_fileset_file Purple-left.txt OTHER PATH sprites/Sprite_rom/Purple-left.txt
add_fileset_file Purple-right.txt OTHER PATH sprites/Sprite_rom/Purple-right.txt
add_fileset_file R.txt OTHER PATH sprites/Sprite_rom/R.txt
add_fileset_file S.txt OTHER PATH sprites/Sprite_rom/S.txt


# 
# parameters
# 


# 
# module assignments
# 
set_module_assignment embeddedsw.dts.group vga
set_module_assignment embeddedsw.dts.name vga_zylo
set_module_assignment embeddedsw.dts.vendor csee4840


# 
# display items
# 


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


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 maximumPendingWriteTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 writedata writedata Input 32
add_interface_port avalon_slave_0 write write Input 1
add_interface_port avalon_slave_0 chipselect chipselect Input 1
add_interface_port avalon_slave_0 address address Input 16
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point vga
# 
add_interface vga conduit end
set_interface_property vga associatedClock clock
set_interface_property vga associatedReset ""
set_interface_property vga ENABLED true
set_interface_property vga EXPORT_OF ""
set_interface_property vga PORT_NAME_MAP ""
set_interface_property vga CMSIS_SVD_VARIABLES ""
set_interface_property vga SVD_ADDRESS_GROUP ""

add_interface_port vga VGA_B b Output 8
add_interface_port vga VGA_BLANK_n blank_n Output 1
add_interface_port vga VGA_CLK clk Output 1
add_interface_port vga VGA_G g Output 8
add_interface_port vga VGA_HS hs Output 1
add_interface_port vga VGA_R r Output 8
add_interface_port vga VGA_SYNC_n sync_n Output 1
add_interface_port vga VGA_VS vs Output 1

