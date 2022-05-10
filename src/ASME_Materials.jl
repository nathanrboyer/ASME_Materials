module ASME_Materials

# Inputs
const specno = "SA-723"
const type_grade = 3
const class_condition_temper = 2
const AIP_material_category = "AIP Q&T Steels"
const tableKM620_material_category = "Ferritic steel" # NOTE: Ferritic steel includes carbon, low alloy, and alloy steels, and ferritic, martensitic, and iron-based age-hardening stainless steels.
const num_output_stress_points = 50 # Number of points to compute on each stress-strain curve

# File Paths
const inputfilepath = "S:/Material Properties/Section II-D Tables.xlsx"
const outputdir = joinpath("S:/Material Properties/Excel Material Data", AIP_material_category)
mkpath(outputdir)

# Combine Material Information from Inputs
const material_dict = Dict("Spec. No." => x -> x .== specno,
                    "Type/Grade" => x -> x .== type_grade,
                    "Class/Condition/Temper" => x -> x .== class_condition_temper)
const material_string = string(specno,'-',type_grade,'-',class_condition_temper)

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, XLSX

# Define Functions
include("ReadTables.jl")
include("KM620.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# Execute Code
function main()
    ASME_tables, ASME_groups = read_ASME_tables(inputfilepath)
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups)
    write_ANSYS_tables(ANSYS_tables)
    plot_ANSYS_tables(ANSYS_tables)
    return ANSYS_tables
end

export main, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, plot_ANSYS_tables

end # module
