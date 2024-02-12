"""
    get_user_input()

Gather user input required to perform the table transformation into a named tuple.
"""
function get_user_input()
    # Material Specification
    tprintln(@style "Material Information" underline cyan)
    tprintln(@style "Enter the following material information with no special characters or spaces, \
        or press Enter to accept the default value." dim)

    spec_no_default = "SA-723"
    tprint("Specification Number: {dim}(Default: $spec_no_default) {/dim}", highlight=false)
    spec_no = parse_input(String, spec_no_default)

    type_grade_default = "3"
    tprint("Type/Grade: {dim}(Default: $type_grade_default) {/dim}", highlight=false)
    type_grade = parse_input(String, type_grade_default)

    class_condition_temper_default = "2a"
    tprint(
        "Class/Condition/Temper: {dim}(Default: $class_condition_temper_default) {/dim}",
        highlight=false,
    )
    class_condition_temper = parse_input(String, class_condition_temper_default)

    KM620_coefficients_table_material_category_number_default = 1
    tprint(tableKM620_options())
    tprint(
        "Table KM-620 Material Category: \
            {dim}(Default: $KM620_coefficients_table_material_category_number_default) {/dim}",
        highlight=false,
    )
    valid = false
    local KM620_coefficients_table_material_category
    local KM620_coefficients_table_material_category_number
    while valid == false
        try
            KM620_coefficients_table_material_category_number = parse_input(
                Int,
                KM620_coefficients_table_material_category_number_default
            )
            KM620_coefficients_table_material_category = KM620.coefficients_table."Material"[
                KM620_coefficients_table_material_category_number
            ]
            valid = true
        catch
            tprint(@style "Invalid option. \
                Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    # Simulation Parameters
    tprintln(@style "\nSimulation Parameters" underline cyan)
    tprintln(@style "Enter the following simulation parameters with no special characters or spaces, \
        or press Enter to accept the default value." dim)

    yield_option_default = 1
    tprint(yield_options())
    tprint(
        "Yield Point Calculation Option: {dim}(Default: $yield_option_default) {/dim}",
        highlight=false,
    )
    valid = false
    local yield_option, overwrite_yield, proportional_limit_default, proportional_limit
    while valid == false
        try
            yield_option = parse_input(Int, yield_option_default)
        catch
            yield_option = -1 # Dummy value to reach else branch
        end
        if yield_option == 1
            overwrite_yield = true
            proportional_limit = KM620.coefficients_table[yield_option, "ϵₚ"]
            valid = true
        elseif yield_option == 2
            overwrite_yield = false
            proportional_limit = 0.002
            valid = true
        elseif yield_option == 3
            overwrite_yield = true
            proportional_limit_default = 1E-6
            tprint(
                "Proportional Limit Tolerance: {dim}(Default: $proportional_limit_default) {/dim}",
                highlight=false,
            )
            proportional_limit = parse_input(Float64, proportional_limit_default)
            valid = true
        else
            tprint(@style "Invalid option. \
                Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    num_output_stress_points_default = 20
    tprint("Number of Plastic Stress-Strain Points: \
        {dim}(Default: $num_output_stress_points_default) {/dim}", highlight=false)
    num_output_stress_points = parse_input(Int, num_output_stress_points_default)

    # Files
    tprintln(@style "\nSelect the appropriate file location." underline cyan)
    input_file_path = raw"S:\Material Properties\Excel Material Data\Section II-D Tables.xlsx"
    if !isfile(input_file_path)
        println("Locate and select the input file `Section II-D Tables.xlsx`.")
        input_file_path = pick_file(filterlist="xlsx, XLSX")
    end
    println("Choose the correct material category folder \
        in which to save the output tables and figures (e.g. Q&T Steels).\n")
    output_folder = pick_folder(dirname(input_file_path))

    # Derived Quantities
    material_string = string(spec_no,'-',type_grade,'-',class_condition_temper)
    material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
    output_file_path = joinpath(output_folder, material_string*".xlsx")
    plot_folder = joinpath(output_folder, "Plots")

    user_input = (;
        spec_no,
        type_grade,
        class_condition_temper,
        KM620_coefficients_table_material_category,
        num_output_stress_points,
        overwrite_yield,
        proportional_limit,
        input_file_path,
        output_file_path,
        output_folder,
        plot_folder,
        material_string,
        material_dict,
    ) # NamedTuple collection of all user inputs

    return user_input
end

"""
    parse_input(type, default)

Reads input from the REPL and converts it to the specified type.
If nothing is entered, the default value is used.
"""
function parse_input(type, default)
    input = readline()
    if length(input) == 0
        return default
    end
    if type == String
        return input
    end
    return parse(type, input)
end

"""
    tableKM620_options()

Returns a terminal panel with the material information from Table KM-620.
Call `print` or `println` on the result to diplay it.
"""
function tableKM620_options()
    option_text = RenderableText(
        join(KM620.coefficients_table."Material", "\n"),
        style = "dim",
    )
    option_numbers = RenderableText(
        join(string.(collect(1:option_text.measure.h)), "\n"),
        style = "dim",
    )
    vline = vLine(option_numbers, style = "cyan")
    note_text = RenderableText(
        "Ferritic steel includes carbon, low alloy, and alloy steels,\n" *
        "and ferritic, martensitic, and iron-based age-hardening stainless steels.",
        style = "dim",
    )
    note_panel = Panel(
        note_text,
        title = "Note",
        style = "cyan",
        fit = true,
    )
    top_text = TextBox(
        option_numbers * " " * vline * " " * option_text,
        padding = (2, 0, 0, 0),
    )
    options_panel = Panel(
        top_text / note_panel,
        title = "Table KM-620 Material Categories",
        style = "cyan",
        fit = true,
    )
    return options_panel
end

"""
    yield_options()

Returns a terminal panel with the yield strain calculation options.
Call `print` or `println` on the result to diplay it.
"""
function yield_options()
    option_text = RenderableText(
        "Use ϵₚ from Table KM-620 as the proportional limit tolerance at yield.\n" *
        "Use 0.2% engineering offset strain as the proportional limit tolerance at yield.\n" *
        "Specify my own proportional limit tolerance at yield.",
        style = "dim",
    )
    option_numbers = RenderableText(
        join(string.(collect(1:option_text.measure.h)), "\n"),
        style = "dim",
    )
    vline = vLine(option_numbers, style = "cyan")
    options_panel = Panel(
        option_numbers * " " * vline * " " * option_text,
        title = "Yield Point Calculation Options",
        style = "cyan",
        padding = (5, 5, 1, 1),
        fit = true,
    )
    return options_panel
end

"""
    make_material_dict(
        spec_no::String,
        type_grade::String,
        class_condition_temper::String
    ) -> material_dict::Dict{String, Function}

Create dictionary to filter DataFrame material properties from material specifications.

Maps the Section II-D table header string to an anonymous function `x -> x .== input_value`.
"""
function make_material_dict(spec_no::String, type_grade::String, class_condition_temper::String)
    material_dict = Dict(
        "Spec. No." => x -> x .== spec_no,
        "Type/Grade" => x -> x .== type_grade,
        "Class/Condition/Temper" => x -> x .== class_condition_temper,
    )
    return material_dict
end

"""
    save_user_input(user_input::NamedTuple)

Saves `user_input` data to the folder specified by `user_input.inputdir`.
Variable names and values are extracted from `user_input` as (key, value) pairs,
then written to file one pair per line.
"""
function save_user_input(filepath, user_input)
    mkpath(filepath)
    filepath = joinpath(filepath, user_input.material_string * ".csv")
    open(filepath, "w") do io
        for (key, value) in pairs(user_input)
            println(io, key, ',', value)
        end
    end
end
