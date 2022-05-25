user_input = (spec_no = "SA-723",
                type_grade = "3",
                class_condition_temper = "2a",
                tableKM620_material_category = "Ferritic steel",
                num_output_stress_points = 50,
                overwrite_yield = true,
                plastic_strain_tolerance = 1.0e-5,
                input_file_path = "S:\\Material Properties\\Section II-D Tables.xlsx",
                output_file_path = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\SA-723-3-2a.xlsx",
                output_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels",
                plot_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\Plots",
                material_string = "SA-723-3-2a",
                material_dict = Dict("Spec. No." => x -> x .== "SA-723",
                                    "Type/Grade" => x -> x .== "3",
                                    "Class/Condition/Temper" => x -> x .== "2a"))
ASME_tables, ASME_groups = read_ASME_tables(user_input)
ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups, user_input)

fig_tc, fig_te, fig_ym, fig_ps = plot_ANSYS_tables(ANSYS_tables, user_input)
fig_tc, fig_te, fig_ym, fig_ps = plot_ANSYS_tables(ANSYS_tables, user_input.material_string, user_input.plot_folder)
fig_tc, fig_te, fig_ym, fig_ps = plot_ANSYS_tables(ANSYS_tables, user_input.material_string)

display(fig_tc)
display(fig_te)
display(fig_ym)
display(fig_ps)