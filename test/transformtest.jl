"""
    check_table(table, column, value)

Obtain table row where `column` matches `value`,
then print the name and value in each column.
If the cell contains a collection,
then print the first and last element.
`table` - DataFrame to check
`column` - column name as a String or Symbol
`value` - cell value to look for in the `column` (any type)
"""
function check_table(table, column, value)
    for col in names(table)
        println("")
        println(col)
        data = only(table[table[:, column] .== value, col])
        if typeof(data) <: AbstractArray
            println(data[1])
            println(data[end])
        else
            println(data)
        end
    end
end

user_input = (spec_no = "SA-723",
                type_grade = "3",
                class_condition_temper = "2a",
                tableKM620_material_category = "Ferritic steel",
                num_output_stress_points = 50,
                overwrite_yield = true,
                proportional_limit = 1.0e-5,
                input_file_path = "S:\\Material Properties\\Section II-D Tables.xlsx",
                output_file_path = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\SA-723-3-2a.xlsx",
                output_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels",
                plot_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\Plots",
                material_string = "SA-723-3-2a",
                material_dict = Dict("Spec. No." => x -> x .== "SA-723",
                                    "Type/Grade" => x -> x .== "3",
                                    "Class/Condition/Temper" => x -> x .== "2a"))
ASME_tables, ASME_groups = read_ASME_tables(user_input)
ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups, user_input)
ANSYS_tables = transform_ASME_tables(ASME_tables, ASME_groups; user_input...)


check_table(ANSYS_tables["Stress-Strain"], "T", 200)