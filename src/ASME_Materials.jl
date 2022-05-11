module ASME_Materials

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, XLSX

# Define Functions
include("Input.jl")
include("ReadTables.jl")
include("KM620.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# Execute Code
function main()
    user_input = get_user_input()
    ASME_tables, ASME_groups = read_ASME_tables(inputfilepath)
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups)
    write_ANSYS_tables(ANSYS_tables)
    plot_ANSYS_tables(ANSYS_tables)
    return ANSYS_tables
end

export main, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, plot_ANSYS_tables, find_true_yield_stress, get_user_input

end # module
