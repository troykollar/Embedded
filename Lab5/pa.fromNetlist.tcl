
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Lab5 -dir "/home/troy/Embedded/Lab5/planAhead_run_2" -part xc6slx9csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/troy/Embedded/Lab5/counter.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/troy/Embedded/Lab5} }
set_property target_constrs_file "/home/troy/Embedded/Lab5/Test/counter.ucf" [current_fileset -constrset]
add_files [list {/home/troy/Embedded/Lab5/Test/counter.ucf}] -fileset [get_property constrset [current_run]]
link_design
