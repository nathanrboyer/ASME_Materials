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
    get_user_input()

Gather user input required to perform the table transformation into a named tuple .
"""
function get_user_input()
    # Material Specification
    tprintln(@style "Enter the following material information with no special characters or spaces, or press Enter to accept the default value." cyan underline bold)

    specno_default = "SA-723"
    tprint("Specification Number: [dim](Default: $specno_default) [/dim]")
    global specno = parse_input(String, specno_default)

    type_grade_default = "3"
    tprint("Type/Grade: [dim](Default: $type_grade_default) [/dim]")
    global type_grade = parse_input(String, type_grade_default)

    class_condition_temper_default = "2a"
    tprint("Class/Condition/Temper: [dim](Default: $class_condition_temper_default) [/dim]")
    global class_condition_temper = parse_input(String, class_condition_temper_default)

    tableKM620_material_category_number_default = 1
    tprintln(@style "Table KM-620 Options" cyan underline)
    for i in 1:nrow(tableKM620)
        tprintln("[cyan]$i: $(tableKM620."Material"[i])[/cyan]")
    end
    tprintln(@style "Note: Ferritic steel includes carbon, low alloy, and alloy steels, and ferritic, martensitic, and iron-based age-hardening stainless steels." italic dim bold)
    tprint("Table KM-620 Material Category: [dim](Default: $tableKM620_material_category_number_default)[/dim]")
    valid = false
    while valid == false
        try
            tableKM620_material_category_number = parse_input(Int, tableKM620_material_category_number_default)
            global tableKM620_material_category = tableKM620."Material"[tableKM620_material_category_number]
            valid = true
        catch
            tprint(@style "Invalid option. Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    # Simulation Parameters
    tprintln(@style "\nEnter the following simulation parameters with no special characters or spaces." cyan underline)

    num_output_stress_points_default = 50
    tprint("Number of Plastic Stress-Strain Points: [dim](Default: $num_output_stress_points_default) [/dim]")
    global num_output_stress_points = parse_input(Int, num_output_stress_points_default)

    overwrite_yield_number_default = 1
    tprintln(@style "Plastic Strain Options" cyan underline)
    tprintln(@style "1: Specify my own strain tolerance." cyan)
    tprintln(@style "2: Use ASME strain tolerance of 0.002 in/in." cyan)
    tprint("How do you want to calculate the point to consider as zero plastic strain? [dim](Default: $overwrite_yield_number_default) [/dim]")
    valid = false
    while valid == false
        overwrite_yield_number = parse_input(Int, overwrite_yield_number_default)
        if overwrite_yield_number == 1
            global overwrite_yield = true
            plastic_tolerance_default = 1e-5
            tprint("Plastic Strain Tolerance to Consider as Zero: [dim](Default: $plastic_tolerance_default) [/dim]")
            global plastic_tolerance = parse_input(Float64, plastic_tolerance_default)
            valid = true
        elseif overwrite_yield_number == 2
            global overwrite_yield = false
            global plastic_tolerance = 0.002
            valid = true
        else
            tprint(@style "Invalid option. Please enter an integer number corresponding to one of the options above: " red)
        end
    end

    # Files
    println("Locate and select the input file `Section II-D Tables.xlsx`.")
    global inputfilepath = pick_file(raw"S:\Material Properties", filterlist="xlsx, XLSX")
    println("Choose the correct folder (AIP Material Category) in which to save the output tables and figures.\n")
    global outputdir = pick_folder(raw"S:\Material Properties\Excel Material Data")

    # Derived Quantities
    global material_string = string(specno,'-',type_grade,'-',class_condition_temper)
    global material_dict = Dict("Spec. No." => x -> x .== specno,
                    "Type/Grade" => x -> x .== type_grade,
                    "Class/Condition/Temper" => x -> x .== class_condition_temper)

    return (specno = specno,
            type_grade = type_grade,
            class_condition_temper = class_condition_temper,
            tableKM620_material_category = tableKM620_material_category,
            num_output_stress_points = num_output_stress_points,
            overwrite_yield = overwrite_yield,
            plastic_tolerance = plastic_tolerance,
            inputfilepath = inputfilepath,
            outputdir = outputdir,
            material_string = material_string,
            material_dict = material_dict)
end
