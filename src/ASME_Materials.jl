module ASME_Materials

# Load Packages
using ColorSchemes, DataFrames, GLMakie, Interpolations, NativeFileDialog, Term, XLSX
import KM620

# Export Function Names
export main, get_user_input, read_ASME_tables, transform_ASME_tables, write_ANSYS_tables, save_user_input, plot_ANSYS_tables, find_true_sleep_stress, make_material_dict, goodbye_message

# Define Functions
include("Input.jl")
include("ReadTables.jl")
include("TransformTables.jl")
include("WriteTables.jl")
include("PlotTables.jl")

# KM-610 Ideally Elastic Plastic Stability Parameters
const increase_in_strength = 0.05 # 5%
const increase_in_plastic_strain = 0.20 # 20%

# Welcome Message
function __init__()
    @info("""You have just loaded the ASME_Materials package!
    \tEnsure the material you need has been added to every sheet of the file `Section II-D Tables.xlsx`.
    \tThen type `main()` and press Enter.
    """)
end

# Goodbye Message
function goodbye_message(output_file_path)
    goodbye_panel = Panel("1. Open {cyan}Engineering Data{/cyan} in {cyan}ANSYS Workbench{/cyan}.\n" *
                            "2. Ensure {cyan}Units{/cyan} in the menu bar are set to {cyan}U.S. Customary{/cyan}.\n" *
                            "3. Click on {cyan}Engineering Data Sources{/cyan} under the {cyan}Engineering Data{/cyan} tab.\n" *
                            "4. Click the check box next to the appropriate {cyan}Data Source{/cyan} to edit it.\n" *
                            "5. Add and name a new material.\n" *
                            "6. For every sheet in {cyan}$output_file_path{/cyan}:\n" *
                            "    a. Add the property to the new ANSYS material that matches the Excel sheet name.\n" *
                            "    b. Copy and paste the Excel sheet data into the matching empty ANSYS table.\n" *
                            "7. Click the {cyan}Save{/cyan} button next to the {cyan}Data Source{/cyan} checkbox.",
                        title = "ANSYS Workbench Instructions",
                        title_style = "bold",
                        title_justify = :center,
                        style = "cyan",
                        fit = true)
    return goodbye_panel
end

# Output Struct
struct ASME_Materials_Data
    user_input
    ASME_tables
    ASME_groups
    ANSYS_tables
    fig_tc
    fig_te
    fig_ym
    fig_ps
    fig_epp
end
Base.show(io::IO, ::MIME"text/plain", x::ASME_Materials_Data) = tprint(io, "{dim}   Output Fields: $(join(fieldnames(typeof(x)),", ")){/dim}")

# Full Program
function main(user_input::NamedTuple)
    tprintln(@style "Reading input file ..." cyan italic)
    ASME_tables, ASME_groups = read_ASME_tables(user_input)

    tprintln(@style "Transforming input tables ..." cyan italic)
    ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups, user_input)

    tprintln(@style "Writing output tables ..." cyan italic)
    write_ANSYS_tables(ANSYS_tables, user_input)

    tprintln(@style "Plotting results ..." cyan italic)
    fig_tc, fig_te, fig_ym, fig_ps, fig_epp = plot_ANSYS_tables(ANSYS_tables, user_input)
    display(fig_ps)

    print("\n", goodbye_message(user_input.output_file_path))

    return ASME_Materials_Data(user_input, ASME_tables, ASME_groups, ANSYS_tables, fig_tc, fig_te, fig_ym, fig_ps, fig_epp)
end
main() = main(get_user_input())

end # module
