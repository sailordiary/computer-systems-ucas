# setting parameters
set project_name "project1_alu"
set topmodule_src "alu_fpga"
set topmodule_test "alu_test"
set device xc7z020-1-clg484

# setting up the project
set project_dir [file dirname [info script]]
create_project $project_name -force -dir "./${project_name}" -part ${device}

# src files
# TODO: add all RTL source files of your ALU design here
add_files -norecurse -fileset sources_1 "[file normalize "${project_dir}/alu.v"]"


add_files -norecurse -fileset sources_1 "[file normalize "${project_dir}/../lib/seg.v"]"
add_files -norecurse -fileset sources_1 "[file normalize "${project_dir}/alu_fpga.v"]"
set_property verilog_define { {PRJ1_FPGA_IMPL} } [get_fileset sources_1]

# sim files
# TODO: add all RTL source files of your ALU design here
add_files -norecurse -fileset sim_1 "[file normalize "${project_dir}/alu.v"]"


add_files -norecurse -fileset sim_1 "[file normalize "${project_dir}/sim.v"]"

# contraints files
add_files -norecurse -fileset constrs_1 "[file normalize "${project_dir}/constr.xdc"]"

set_property "top" $topmodule_src [get_filesets sources_1]
set_property "top" $topmodule_test [get_filesets sim_1]

set_property target_constrs_file "${project_dir}/constr.xdc" [current_fileset -constrset]
