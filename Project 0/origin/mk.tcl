# reading sim parameters
set project_name "project0_build"
set topmodule_src "led_pipe"
set topmodule_test "led_test"
set device xc7z020-1-clg484

# setting up the sim project
set project_dir [file dirname [info script]]
create_project $project_name -force -dir "${project_dir}/../${project_name}" -part ${device}

# src files
add_files -norecurse -fileset sources_1 "[file normalize "led.v"]"

# sim files
add_files -norecurse -fileset sim_1 "[file normalize "led.v"]"
add_files -norecurse -fileset sim_1 "[file normalize "sim.v"]"

# contraints files
add_files -norecurse -fileset constrs_1 "[file normalize "constr.xdc"]"

set_property "top" $topmodule_src [get_filesets sources_1]
set_property "top" $topmodule_test [get_filesets sim_1]

set_property target_constrs_file "${project_dir}/constr.xdc" [current_fileset -constrset]
