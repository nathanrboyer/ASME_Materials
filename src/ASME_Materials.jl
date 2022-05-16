module ASME_Materials

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, NativeFileDialog, Term, XLSX

# Export Function Names
export main, get_user_input, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, plot_ANSYS_tables, find_true_yield_stress

# Define Functions
include("KM620.jl")
include("Input.jl")
include("ReadTables.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# Welcome Message
function __init__()
    @info("""You have just loaded the ASME_Materials package!
    \tEnsure the material you need has been added to every sheet of the file `Section II-D Tables.xlsx`.
    \tThen type `main()` and press Enter.
    """)
end

# Goodbye Message
function goodbye_message(outputfilepath)
    goodbye_panel = Panel("1. Open [cyan]Engineering Data[/cyan] in [cyan]ANSYS Workbench[/cyan].\n" *
                            "2. Click on [cyan]Engineering Data Sources[/cyan].\n" *
                            "3. Click the check box next to the appropriate [cyan]Data Source[/cyan] to edit it.\n" *
                            "4. Add and name a new material.\n" *
                            "5. For every sheet in [cyan]$outputfilepath[/cyan]:\n" *
                                "\ta. Add the property to the new ANSYS material that matches the Excel sheet name.\n" *
                                "\tb. Copy and paste the Excel sheet data into the matching empty ANSYS table.\n" *
                            "6. Click the [cyan]Save[/cyan] button next to the [cyan]Data Source[/cyan] checkbox.",
                        title = "ANSYS Workbench Instructions",
                        title_style = "bold cyan",
                        title_justify = :center,
                        style = "cyan",
                        fit = true)
    return goodbye_panel
end

# Full Program
function main()
    user_input = get_user_input()

    tprintln(@style "Reading Input File..." cyan italic)
    ASME_tables, ASME_groups = read_ASME_tables(user_input.inputfilepath)

    tprintln(@style "Transforming Tables..." cyan italic)
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups)

    tprintln(@style "Writing Output Tables..." cyan italic)
    write_ANSYS_tables(ANSYS_tables)

    tprintln(@style "Plotting Results..." cyan italic)
    fig1, fig2, fig3, fig4 = plot_ANSYS_tables(ANSYS_tables)
    display(fig4)
    tprintln(@style "Complete\n" cyan italic)

    print(goodbye_message(user_input.outputfilepath))
    return nothing
end

end # module
