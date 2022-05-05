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

# Load Packages
using DataFrames, Interpolations, Latexify, PrettyTables, XLSX

# Run Files
function run()
    include(joinpath(@__DIR__, "ReadTables.jl"))
    include(joinpath(@__DIR__, "KM620.jl"))
    include(joinpath(@__DIR__, "BuildTables.jl"))
    include(joinpath(@__DIR__, "WriteTables.jl"))
    include(joinpath(@__DIR__, "PlotTables.jl"))
end

export run

end # module
