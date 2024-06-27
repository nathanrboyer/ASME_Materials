using Test
using ASME_Materials
using ColorSchemes, DataFrames, GLMakie, Interpolations, Latexify, NativeFileDialog, PrettyTables, Term, XLSX

user_input = (
    spec_no = "SA-723",
    type_grade = "3",
    class_condition_temper = "2a",
    KM620_coefficients_table_material_category = "Ferritic steel",
    num_plastic_points = 20,
    input_file_path = "S:\\Material Properties\\Excel Material Data\\Section II-D Tables.xlsx",
    output_file_path = "S:\\Material Properties\\Excel Material Data\\Q&T Steels\\SA-723-3-2a.xlsx",
    output_folder = "S:\\Material Properties\\Excel Material Data\\Q&T Steels",
    plot_folder = "S:\\Material Properties\\Excel Material Data\\Q&T Steels\\Plots",
    material_string = "SA-723-3-2a",
    material_dict = LittleDict(
        "Spec. No." => x -> x .== "SA-723",
        "Type/Grade" => x -> x .== "3",
        "Class/Condition/Temper" => x -> x .== "2a",
    )
)

include("readtest.jl")
include("transformtest.jl")
include("writetest.jl")
include("plottest.jl")
include("verification.jl")
