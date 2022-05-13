module ASME_Materials

# Welcome Message
function __init__()
    @info("""You have just loaded the ASME_Materials package!
    \tEnsure the material you need has been added to every sheet of the file `Section II-D Tables.xlsx`.
    \tThen type `main();` and press Enter.
    """)
end

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, NativeFileDialog, Term, XLSX

# Define Functions
include("KM620.jl")
include("Input.jl")
include("ReadTables.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# Full Program
function main()
    user_input = get_user_input()

    println("Reading Input File...")
    ASME_tables, ASME_groups = read_ASME_tables(user_input.inputfilepath)

    println("Transforming Tables...")
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups)

    println("Writing Output Tables...")
    write_ANSYS_tables(ANSYS_tables)

    println("Plotting Results...")
    fig1, fig2, fig3, fig4 = plot_ANSYS_tables(ANSYS_tables)
    display(fig4)
    println("Complete\n")

    println("Output files are located in $(user_input.outputdir)")
    println("""
    In ANSYS Workbench:
        1. Open "Engineering Data"
        2. Add and name a new material
        3. For every sheet in the output Excel file:
            a. Add the property to the material that matches the sheet name.
            b. Copy and paste the Excel table data into the matching empty ANSYS table.
    """)
    return ANSYS_tables
end

# Make Functions Available to Use Outside Module
export main, get_user_input, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, plot_ANSYS_tables, find_true_yield_stress

end # module
