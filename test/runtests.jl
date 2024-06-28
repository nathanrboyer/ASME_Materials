using Test
using ASME_Materials
using ColorSchemes, DataFrames, GLMakie, Interpolations, Latexify, NativeFileDialog,
        OrderedCollections, PrettyTables, Printf, Term, XLSX

include("testingfunctions.jl")

# Input
user_input = let
    # Material Data
    spec_no = "SA-723"
    type_grade = "3"
    class_condition_temper = "2"
    KM620_coefficients_table_material_category = "Ferritic steel"
    AIP_material_category = "Q&T Steels"
    num_plastic_points = 20

    # Derived Data
    material_string = make_material_string(spec_no, type_grade, class_condition_temper)
    material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
    input_file_path = "S:\\Material Properties\\Excel Material Data\\Section II-D Tables.xlsx"
    output_file_path = joinpath(dirname(input_file_path), AIP_material_category, "$material_string.xlsx")
    plot_folder = joinpath(dirname(output_file_path), "Plots")
    user_input = (;
        spec_no,
        type_grade,
        class_condition_temper,
        KM620_coefficients_table_material_category,
        num_plastic_points,
        input_file_path,
        output_file_path,
        plot_folder,
        material_string,
        material_dict,
    )
end

# Read
ASME_tables, ASME_groups = read_ASME_tables(user_input)
ASME_tables, ASME_groups = read_ASME_tables(user_input.input_file_path, user_input.material_dict)
ASME_tables, ASME_groups = read_ASME_tables(
    user_input.input_file_path,
    user_input.spec_no,
    user_input.type_grade,
    user_input.class_condition_temper
)

# Transform
ANSYS_tables, master_table = transform_ASME_tables(ASME_tables, ASME_groups, user_input)
ANSYS_tables, master_table = transform_ASME_tables(ASME_tables, ASME_groups; user_input...)
check_table(master_table, "T", 200)

# Write
write_ANSYS_tables(ANSYS_tables, user_input.output_file_path)
write_ANSYS_tables(ANSYS_tables, user_input)

# Plot
figures = plot_ANSYS_tables(ANSYS_tables, user_input)
figures = plot_ANSYS_tables(ANSYS_tables, user_input.material_string)
figures = plot_ANSYS_tables(ANSYS_tables, user_input.material_string, user_input.plot_folder)

display(figures["Thermal Conductivity"])
display(figures["Thermal Expansion"])
display(figures["Elasticity"])
display(figures["Plasticity"])
display(figures["Yield Strength"])
display(figures["Ultimate Strength"])
display(figures["EPP Stress-Strain"])
display(figures["Total Stress-Strain"])

# Full
results = main(user_input)

include("dataverification.jl")
include("actualtests.jl")
