# Board Design Automative Generation Script
# File Name: deoi_based_armv7_server_node_bd.tcl

# CHANGE DESIGN NAME HERE
set design_name zynq_soc 

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

#===================================
# Create IP Blocks
#===================================

  # Create instance: Zynq Processing System
  set armv7_ps [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 armv7_processing_system ]
  set_property -dict [ list CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {800} \
				CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
				CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {1} ] $armv7_ps 

  # Create instance: AXI protocol converter
  set axi3_to_lite_pc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi3_to_lite_pc ]
  set_property -dict [ list CONFIG.SI_PROTOCOL.VALUE_SRC {USER} \
				CONFIG.SI_PROTOCOL {AXI3} \
				CONFIG.MI_PROTOCOL.VALUE_SRC {USER} ] $axi3_to_lite_pc
  
#=============================================
# Clock ports
#=============================================
  # PS FCLK0 output
  create_bd_port -dir O -type clk ps_fclk_clk0

#==============================================
# Reset ports
#==============================================
  #PL system reset using PS-PL user_reset_n signal
  create_bd_port -dir O -type rst ps_user_reset_n

  create_bd_port -dir I -type rst mips_cpu_reset_n
  set_property CONFIG.ASSOCIATED_RESET {mips_cpu_reset_n} [get_bd_ports ps_fclk_clk0]

#==============================================
# Export AXI Interface
#==============================================
  # Connect to DoCE AXI-Lite slave
  set mips_cpu_axi_if [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 mips_cpu_axi_if]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4Lite} ] $mips_cpu_axi_if

  set_property CONFIG.ASSOCIATED_BUSIF {mips_cpu_axi_if} [get_bd_ports ps_fclk_clk0]

#=============================================
# System clock connection
#=============================================
  connect_bd_net -net armv7_ps_fclk_0 [get_bd_pin armv7_processing_system/FCLK_CLK0] \
			[get_bd_pins ps_fclk_clk0] \
			[get_bd_pins armv7_processing_system/M_AXI_GP0_ACLK] \
			[get_bd_pins axi3_to_lite_pc/aclk]

#=============================================
# System reset connection
#=============================================
  connect_bd_net -net ps_user_reset_n [get_bd_pins armv7_processing_system/FCLK_RESET0_N] \
			[get_bd_pins ps_user_reset_n]

  connect_bd_net -net mips_cpu_reset_n [get_bd_pins mips_cpu_reset_n] \
			[get_bd_pins axi3_to_lite_pc/aresetn]

#==============================================
# AXI Interface Connection
#==============================================
  connect_bd_intf_net -intf_net armv7_ps_M_AXI_GP0 [get_bd_intf_pins axi3_to_lite_pc/S_AXI] \
			[get_bd_intf_pins armv7_processing_system/M_AXI_GP0] 

  connect_bd_intf_net -intf_net mips_cpu_axi_if [get_bd_intf_pins axi3_to_lite_pc/M_AXI] \
			[get_bd_intf_pins mips_cpu_axi_if] 

#=============================================
# ARMv7 Processing System connection
#=============================================
  apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} $armv7_ps

#=============================================
# Create address segments
#=============================================

  # MMIO registers
  create_bd_addr_seg -range 0x400000 -offset 0x40000000 [get_bd_addr_spaces armv7_processing_system/Data] [get_bd_addr_segs mips_cpu_axi_if/Reg] PS_VIEW_MIPS_MEM

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()

##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
