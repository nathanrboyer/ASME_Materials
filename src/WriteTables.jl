"""
    write_ANSYS_tables(tables, filepath)
    write_ANSYS_tables(tables, user_input)
    write_ANSYS_tables(tables, filepath, user_input)

Writes all ANSYS `tables` to an Excel file.

Name and path to output Excel file is specified by `filepath` or within `user_input`.
Additional input data is written to file if `user_input` is provided using `make_info_table`.

# Arguments
- `tables::LittleDict{String, DataFrame}`: dictionary of ANSYS tables to be written to file
- `filepath::AbstractString`: location to save file including file name
- `user_input::NamedTuple`: collection of metadata to include in output file from `get_user_input`
    -`output_file_path`
    -`num_plastic_points`
    -`KM620_coefficients_table_material_category`
"""
function write_ANSYS_tables(
        tables::LittleDict{String, DataFrame},
        filepath::AbstractString,
        user_input::Union{Nothing, NamedTuple} = nothing,
    )
    XLSX.openxlsx(filepath, mode="w") do file
        sheet = file[1]
        XLSX.rename!(sheet, "Overview (Info)")
        sheet["A1"] = "This Excel file was created by the ASME_Materials Julia package."
        sheet["A2"] = "All sheets, except those with \"(Info)\", should be copied directly \
            into ANSYS to create the elastic-plastic material models."
        if !isnothing(user_input)
            sheet["A3"] = "The user inputs used to create this file are listed below."
            XLSX.writetable!(sheet, make_info_table(; user_input...), anchor_cell=XLSX.CellRef("A5"))
        end
        sheet = XLSX.addsheet!(file, "Yield Strength (Info)")
        XLSX.writetable!(sheet, tables["Yield Strength"])
        sheet = XLSX.addsheet!(file, "Ultimate Strength (Info)")
        XLSX.writetable!(sheet, tables["Ultimate Strength"])
        sheet = XLSX.addsheet!(file, "Density")
        XLSX.writetable!(sheet, tables["Density"])
        sheet = XLSX.addsheet!(file, "Iso Inst Coef Thermal Expansion")
        XLSX.writetable!(sheet, tables["Thermal Expansion"])
        sheet = XLSX.addsheet!(file, "Isotropic Elasticity")
        XLSX.writetable!(sheet, tables["Elasticity"])
        sheet = XLSX.addsheet!(file, "Multilinear Kinematic Hardening")
        XLSX.writetable!(sheet, tables["Temperature"])
        for (i, temp) in enumerate(tables["Temperature"][:,1])
            sheet[1,3*i] = "Temperature = $(temp)°F"
            XLSX.writetable!(sheet, tables["Hardening $(temp)°F"], anchor_cell=XLSX.CellRef(2,3*i))
        end
        sheet = XLSX.addsheet!(file, "Iso Thermal Conductivity")
        XLSX.writetable!(sheet, tables["Thermal Conductivity"])
        sheet = XLSX.addsheet!(file, "Pure EPP Hardening")
        sheet["E1"] = "To create an Elastic Perfectly-Plastic (EPP) material model, \
            duplicate the material and replace the Multilinear Kinematic Hardening data \
            with the data below."
        XLSX.writetable!(sheet, tables["EPP"])
        sheet = XLSX.addsheet!(file, "Stable EPP Hardening")
        sheet["E1"] = "To create an Elastic Perfectly-Plastic (EPP) material model, \
            duplicate the material and replace the Multilinear Kinematic Hardening data \
            with the data below."
        XLSX.writetable!(sheet, tables["EPP Stabilized"])
    end
end
write_ANSYS_tables(
    tables::LittleDict{String, DataFrame},
    user_input::NamedTuple
) = write_ANSYS_tables(
    tables,
    user_input.output_file_path,
    user_input,
)
export write_ANSYS_tables

"""
    make_info_table(;
        num_plastic_points,
        KM620_coefficients_table_material_category,
        _...,
    )

Create an informational table from relevant user inputs.
"""
function make_info_table(;
        spec_no,
        type_grade,
        class_condition_temper,
        KM620_coefficients_table_material_category,
        num_plastic_points,
        _...,
    )
    info_table = DataFrame("Variable" => [], "Value" => [], "Description" => [])
    push!(
        info_table,
        (
            "spec_no",
            spec_no,
            "Material Specification Number",
        ),
    )
    push!(
        info_table,
        (
            "type_grade",
            type_grade,
            "Material Type/Grade",
        ),
    )
    push!(
        info_table,
        (
            "class_condition_temper",
            class_condition_temper,
            "Material Class/Condition/Temper",
        ),
    )
    push!(
        info_table,
        (
            "KM620_coefficients_table_material_category",
            KM620_coefficients_table_material_category,
            "Table KM-620 Material Category",
        ),
    )
    push!(
        info_table,
        (
            "num_plastic_points",
            num_plastic_points,
            "Number of Plastic Stress-Strain Data Points",
        ),
    )
    return info_table
end
export make_info_table
