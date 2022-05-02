module ASME_Materials

# Inputs
const specno = "SA-723"
const type_grade = 3
const class_condition_temper = 2
const AIP_material_category = "AIP Q&T Steels"
const tableKM620_material_category = "Ferritic steel"
const num_output_stress_points = 50 # Number of points to compute on each stress-strain curve

# File Paths
const inputfilepath = "S:/Material Properties/Section II-D Tables.xlsx"
const outputdir = joinpath("S:/Material Properties/Excel Material Data", AIP_material_category)
const outputfile = string(specno,'-',type_grade,'-',class_condition_temper,".xlsx")

# Load Packages
using DataFrames, Interpolations, Latexify, PrettyTables, XLSX

# Run Files
include("ReadTables.jl")
include("KM620.jl")
include("BuildTables.jl")
include("WriteTables.jl")

# Export Full Namespace
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include)
        @eval export $n
    end
end

end # module
