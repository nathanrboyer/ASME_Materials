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
    println("Enter the following material information with no special characters or spaces, or press Enter to accept the default value.")

    specno_default = "SA-723"
    println("\nSpecification Number (Default: $specno_default)")
    global specno = parse_input(String, specno_default)

    type_grade_default = 3
    println("\nType/Grade (Default: $type_grade_default)")
    global type_grade = parse_input(String, type_grade_default)

    class_condition_temper_default = "2a"
    println("\nClass/Condition/Temper (Default: $class_condition_temper_default)")
    global class_condition_temper = parse_input(String, class_condition_temper_default)

    tableKM620_material_category_number_default = 1
    println("\nTable KM-620 Material Category (Default: $tableKM620_material_category_number_default)")
    println("Options:")
    for i in 1:nrow(tableKM620)
        println("$i: $(tableKM620."Material"[i])")
    end
    println("Note: Ferritic steel includes carbon, low alloy, and alloy steels, and ferritic, martensitic, and iron-based age-hardening stainless steels.")
    valid = false
    while valid == false
        try
            tableKM620_material_category_number = parse_input(Int, tableKM620_material_category_number_default)
            global tableKM620_material_category = tableKM620."Material"[tableKM620_material_category_number]
            valid = true
        catch
            println("Invalid option. Please enter an integer number corresponding to one of the options above.")
        end
    end

    # Simulation Parameters
    println("\nEnter the following simulation parameters with no special characters or spaces.")

    num_output_stress_points_default = 50
    println("\nNumber of Plastic Stress-Strain Points (Default: $num_output_stress_points_default)")
    global num_output_stress_points = parse_input(Int, num_output_stress_points_default)

    overwrite_yield_number_default = 1
    println("\nHow do you want to calculate the point to consider as zero plastic strain? (Default: $overwrite_yield_number_default)")
    println("Options:")
    println("1: Specify my own strain tolerance.")
    println("2: Use ASME strain tolerance of 0.002 in/in.")
    valid = false
    while valid == false
        overwrite_yield_number = parse_input(Int, overwrite_yield_number_default)
        if overwrite_yield_number == 1
            global overwrite_yield = true
            plastic_tolerance_default = 1e-5
            println("\nPlastic Strain Tolerance to Consider as Zero (Default: $plastic_tolerance_default)")
            global plastic_tolerance = parse_input(Float64, plastic_tolerance_default)
            valid = true
        elseif overwrite_yield_number == 2
            global overwrite_yield = false
            global plastic_tolerance = 0.002
            valid = true
        else
            println("Invalid option. Please enter an integer number corresponding to one of the options above.")
        end
    end

    # Files
    println("\nLocate and select the input file `Section II-D Tables.xlsx`.")
    global inputfilepath = pick_file(raw"S:\Material Properties", filterlist="xlsx, XLSX")
    println("\nChoose the correct folder (AIP Material Category) in which to save the output tables and figures.\n")
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
