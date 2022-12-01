"""
    info_table()

Create an informational table from relevant user inputs.
"""
function make_info_table(; proportional_limit, num_output_stress_points, KM620_coefficients_table_material_category, _...)
    info_table = DataFrame("Name" => [], "Value" => [], "Description" => [])
    push!(info_table, ("proportional_limit", proportional_limit, "Minimum Plastic Strain Value to Consider \"Yielded\""))
    push!(info_table, ("num_output_stress_points", num_output_stress_points, "Number of Plastic Stress-Strain Data Points"))
    push!(info_table, ("KM620_coefficients_table_material_category", KM620_coefficients_table_material_category, "Table KM-620 Material Category"))
    return info_table
end

"""
    write_ANSYS_tables(tables::Dict{String, DataFrame}, filepath::String)

Writes ANSYS `tables` to an Excel file.
Path to output Excel file (including file name) is specified by `filepath`.
"""
function write_ANSYS_tables(tables::Dict{String, DataFrame}, filepath::String)
    XLSX.openxlsx(filepath, mode="w") do file
        XLSX.rename!(file[1], "Density")
        XLSX.writetable!(file[1], tables["Density"])
        XLSX.addsheet!(file, "Iso Inst Coef Thermal Expansion")
        XLSX.writetable!(file[2], tables["Thermal Expansion"])
        XLSX.addsheet!(file, "Isotropic Elasticity")
        XLSX.writetable!(file[3], tables["Elasticity"])
        XLSX.addsheet!(file, "Multilinear Kinematic Hardening")
        XLSX.writetable!(file[4], tables["Temperature"])
        for (i, temp) in enumerate(tables["Temperature"][:,1])
            file[4][1,3*i] = "Temperature = $(temp)°F"
            XLSX.writetable!(file[4], tables["Hardening $(temp)°F"], anchor_cell=XLSX.CellRef(2,3*i))
        end
        XLSX.addsheet!(file, "Yield Strength")
        XLSX.writetable!(file[5], tables["Yield Strength"])
        XLSX.addsheet!(file, "Ultimate Strength")
        XLSX.writetable!(file[6], tables["Ultimate Strength"])
        XLSX.addsheet!(file, "Iso Thermal Conductivity")
        XLSX.writetable!(file[7], tables["Thermal Conductivity"])
        XLSX.addsheet!(file, "Perfectly Plastic Hardening")
        file[8]["A1"] = "To create an Elastic Perfectly-Plastic (EPP) material model, duplicate the material and replace the Multilinear Kinematic Hardening data with the data below."
        file[8]["A2"] = "Use only the first datapoint at each temperature for a pure EPP material. Use both datapoints at each temperature for a stabilized EPP material. Stabilization is the maximum amount allowed by KM-610."
        XLSX.writetable!(file[8], tables["EPP"], anchor_cell=XLSX.CellRef("A4"))
    end
end

"""
    write_ANSYS_tables(tables::Dict{String, DataFrame}, user_input::NamedTuple)

Writes ANSYS `tables` to an Excel file using information specified in `user_input`.
`output_file_path`, `proportional_limit`, `num_output_stress_points`, and `KM620_coefficients_table_material_category` must be present in `user_input`.
"""
function write_ANSYS_tables(tables::Dict{String, DataFrame}, user_input::NamedTuple)
    XLSX.openxlsx(user_input.output_file_path, mode="w") do file
        XLSX.rename!(file[1], "Density")
        XLSX.writetable!(file[1], tables["Density"])
        XLSX.addsheet!(file, "Iso Inst Coef Thermal Expansion")
        XLSX.writetable!(file[2], tables["Thermal Expansion"])
        XLSX.addsheet!(file, "Isotropic Elasticity")
        XLSX.writetable!(file[3], tables["Elasticity"])
        XLSX.addsheet!(file, "Multilinear Kinematic Hardening")
        XLSX.writetable!(file[4], tables["Temperature"])
        for (i, temp) in enumerate(tables["Temperature"][:,1])
            file[4][1,3*i] = "Temperature = $(temp)°F"
            XLSX.writetable!(file[4], tables["Hardening $(temp)°F"], anchor_cell=XLSX.CellRef(2,3*i))
        end
        XLSX.addsheet!(file, "Yield Strength")
        XLSX.writetable!(file[5], tables["Yield Strength"])
        XLSX.addsheet!(file, "Ultimate Strength")
        XLSX.writetable!(file[6], tables["Ultimate Strength"])
        XLSX.addsheet!(file, "Iso Thermal Conductivity")
        XLSX.writetable!(file[7], tables["Thermal Conductivity"])
        XLSX.addsheet!(file, "Perfectly Plastic Hardening")
        file[8]["A1"] = "To create an Elastic Perfectly-Plastic (EPP) material model, duplicate the material and replace the Multilinear Kinematic Hardening data with the data below."
        file[8]["A2"] = "Use only the first datapoint at each temperature for a pure EPP material. Use both datapoints at each temperature for a stabilized EPP material. Stabilization is the maximum amount allowed by KM-610."
        XLSX.writetable!(file[8], tables["EPP"], anchor_cell=XLSX.CellRef("A4"))
        XLSX.addsheet!(file, "Input Information")
        file[9]["A1"] = "Do not enter this table into ANSYS. It is provided for informational purposes."
        file[9]["A2"] = "The input values below were used to generate the tables in this workbook."
        XLSX.writetable!(file[9], make_info_table(; user_input...), anchor_cell=XLSX.CellRef("A4"))
    end
end
