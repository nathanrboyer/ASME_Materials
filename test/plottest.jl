user_input = (
    spec_no = "SA-723",
    type_grade = "3",
    class_condition_temper = "2",
    KM620_coefficients_table_material_category = "Ferritic steel",
    num_plastic_points = 20,
    input_file_path = "S:\\Material Properties\\Excel Material Data\\Section II-D Tables.xlsx",
    output_file_path = "S:\\Material Properties\\Excel Material Data\\Q&T Steels\\SA-723-3-2a.xlsx",
    output_folder = "S:\\Material Properties\\Excel Material Data\\Q&T Steels",
    plot_folder = "S:\\Material Properties\\Excel Material Data\\Q&T Steels\\Plots",
    material_string = "SA-723-3-2",
    material_dict = LittleDict(
        "Spec. No." => x -> x .== "SA-723",
        "Type/Grade" => x -> x .== "3",
        "Class/Condition/Temper" => x -> x .== "2",
    )
)
ASME_tables, ASME_groups = read_ASME_tables(user_input)
ANSYS_tables, master_table = transform_ASME_tables(ASME_tables, ASME_groups, user_input)

figures = plot_ANSYS_tables(ANSYS_tables, user_input)
figures = plot_ANSYS_tables(ANSYS_tables, user_input.material_string, user_input.plot_folder)
figures = plot_ANSYS_tables(ANSYS_tables, user_input.material_string)

display(figures["Thermal Conductivity"])
display(figures["Thermal Expansion"])
display(figures["Elasticity"])
display(figures["Stress-Strain"])
display(figures["Yield Strength"])
display(figures["Ultimate Strength"])
display(figures["EPP Stress-Strain"])
