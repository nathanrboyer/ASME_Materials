"""
    get_user_input()

Gather user input required to perform the table transformation into a named tuple .
"""
function get_user_input()
    # Scalars
    # Convert these to `parse(String, readline())` once working.
    global specno = "SA-723"
    global type_grade = 3
    global class_condition_temper = 2
    global tableKM620_material_category = "Ferritic steel"
    global num_output_stress_points = 50
    global overwrite_yield = true
    if overwrite_yield == true
        global plastic_tolerance = 0.0002
    else
        global plastic_tolerance = 0.002
    end

    # Files
    # Convert these to NativeFileDialog.jl once working.
    global inputfilepath = "S:/Material Properties/Section II-D Tables.xlsx"
    global outputdir = "S:/Material Properties/Excel Material Data/AIP Q&T Steels"

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
