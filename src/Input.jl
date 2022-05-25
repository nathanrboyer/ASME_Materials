"""
    output = parse_input(type, default)

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
    strain_options()

Returns a terminal panel with the plastic strain calculation options. Call `print` or `println` on the result to diplay it.
"""
function strain_options()
    option_text = RenderableText("Specify my own plastic strain tolerance.\n" *
                                "Use ASME plastic strain tolerance of 0.002 in/in.",
                                style = "dim")
    option_numbers = RenderableText(join(string.(collect(1:option_text.measure.h)), "\n"), style = "dim")
    vline = vLine(option_numbers, style = "cyan")
    options_panel = Panel(" " * option_numbers * " " * vline * " " * option_text,
                            title = "Plastic Strain Options",
                            title_style = "cyan",
                            style = "cyan",
                            title_justify = :center,
                            fit = true)
    return options_panel
end

"""
    tableKM620_options()

Returns a terminal panel with the material information from Table KM-620. Call `print` or `println` on the result to diplay it.
"""
function tableKM620_options()
    option_text = RenderableText(join(tableKM620."Material", "\n"), style = "dim")
    note_text = RenderableText("Ferritic steel includes carbon, low alloy, and alloy steels,\n" *
                                "and ferritic, martensitic, and iron-based age-hardening stainless steels."
                                , style = "dim")
    option_numbers = RenderableText(join(string.(collect(1:option_text.measure.h)), "\n"), style = "dim")
    vline = vLine(option_numbers, style = "cyan")
    note_panel = Panel(note_text,
                            title = "Note",
                            style = "cyan",
                            fit = true)
    options_panel = Panel(" " / (" " * option_numbers * " " * vline * " " * option_text) / " " / note_panel,
                            title = "Table KM-620 Options",
                            title_style = "cyan",
                            style = "cyan",
                            title_justify = :center,
                            fit = true)
    return options_panel
end

"""
    get_user_input()

Gather user input required to perform the table transformation into a named tuple .
"""
function get_user_input()
    # Material Specification
    tprintln(@style "Enter the following material information with no special characters or spaces, or press Enter to accept the default value." underline cyan)

    spec_no_default = "SA-723"
    tprint("Specification Number: [dim](Default: $spec_no_default) [/dim]")
    spec_no = parse_input(String, spec_no_default)

    type_grade_default = "3"
    tprint("Type/Grade: [dim](Default: $type_grade_default) [/dim]")
    type_grade = parse_input(String, type_grade_default)

    class_condition_temper_default = "2a"
    tprint("Class/Condition/Temper: [dim](Default: $class_condition_temper_default) [/dim]")
    class_condition_temper = parse_input(String, class_condition_temper_default)

    tableKM620_material_category_number_default = 1
    tprint(tableKM620_options())
    tprint("Table KM-620 Material Category: [dim](Default: $tableKM620_material_category_number_default)[/dim]")
    valid = false
    local tableKM620_material_category_number, tableKM620_material_category
    while valid == false
        try
            tableKM620_material_category_number = parse_input(Int, tableKM620_material_category_number_default)
            tableKM620_material_category = tableKM620."Material"[tableKM620_material_category_number]
            valid = true
        catch
            tprint(@style "Invalid option. Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    # Simulation Parameters
    tprintln(@style "\nEnter the following simulation parameters with no special characters or spaces." underline cyan)

    num_output_stress_points_default = 50
    tprint("Number of Plastic Stress-Strain Points: [dim](Default: $num_output_stress_points_default) [/dim]")
    num_output_stress_points = parse_input(Int, num_output_stress_points_default)

    overwrite_yield_number_default = 1
    tprint(strain_options())
    tprint("How do you want to calculate the point to consider as zero plastic strain? [dim](Default: $overwrite_yield_number_default) [/dim]")
    valid = false
    local overwrite_yield_number, overwrite_yield, plastic_strain_tolerance_default, plastic_strain_tolerance
    while valid == false
        overwrite_yield_number = parse_input(Int, overwrite_yield_number_default)
        if overwrite_yield_number == 1
            overwrite_yield = true
            plastic_strain_tolerance_default = 1e-5
            tprint("Plastic Plastic Strain Tolerance to Consider as Zero: [dim](Default: $plastic_strain_tolerance_default) [/dim]")
            plastic_strain_tolerance = parse_input(Float64, plastic_strain_tolerance_default)
            valid = true
        elseif overwrite_yield_number == 2
            overwrite_yield = false
            plastic_strain_tolerance = 0.002
            valid = true
        else
            tprint(@style "Invalid option. Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    # Files
    tprintln(@style "\nSelect the appropriate file locations below." underline cyan)
    println("Locate and select the input file `Section II-D Tables.xlsx`.")
    input_file_path = pick_file(raw"S:\Material Properties", filterlist="xlsx, XLSX")
    println("Choose the correct folder (AIP Material Category) in which to save the output tables and figures.\n")
    output_folder = pick_folder(raw"S:\Material Properties\Excel Material Data")

    # Derived Quantities
    material_string = string(spec_no,'-',type_grade,'-',class_condition_temper)
    material_dict = Dict("Spec. No." => x -> x .== spec_no,
                        "Type/Grade" => x -> x .== type_grade,
                        "Class/Condition/Temper" => x -> x .== class_condition_temper)
    output_file_path = joinpath(output_folder, material_string*".xlsx")
    plot_folder = joinpath(output_folder, "Plots")

    user_input = (; spec_no,
                    type_grade,
                    class_condition_temper,
                    tableKM620_material_category,
                    num_output_stress_points,
                    overwrite_yield,
                    plastic_strain_tolerance,
                    input_file_path,
                    output_file_path,
                    output_folder,
                    plot_folder,
                    material_string,
                    material_dict)

    return user_input
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