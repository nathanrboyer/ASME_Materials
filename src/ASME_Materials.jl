module ASME_Materials

# Welcome Message
@info("""You have just loaded the ASME_Materials package!
\t Ensure the material you need has been added to every sheet of the file `Section II-D Tables.xlsx`.
\t Then, once you see the `julia>` prompt, type `main()` and press Enter.
""")

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, NativeFileDialog, XLSX

# Define Functions
include("KM620.jl")
include("Input.jl")
include("ReadTables.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# Collect Functions Together
function main()
    println("Processing KM620")
    user_input = get_user_input()
    println("Reading Input File")
    ASME_tables, ASME_groups = read_ASME_tables(user_input.inputfilepath)
    println("Transforming Tables")
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups)
    println("Writing Output Tables")
    write_ANSYS_tables(ANSYS_tables)
    println("Plotting Results")
    fig1, fig2, fig3, fig4 = plot_ANSYS_tables(ANSYS_tables)
    display(fig4)
    println("Complete")
    return ANSYS_tables
end

# Make Functions Available
export main, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, plot_ANSYS_tables, find_true_yield_stress, get_user_input

end # module
