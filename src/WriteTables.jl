"""
    info_table()

Create an informational table from relevant user inputs.
"""
function make_info_table(; plastic_strain_tolerance, num_output_stress_points, tableKM620_material_category, _...)
    info_table = DataFrame("Input" => [], "Value" => [])
    push!(info_table, ("Tolerance to Consider as Zero Plastic Strain:", plastic_strain_tolerance))
    push!(info_table, ("Number of Plastic Stress-Strain Data Points:", num_output_stress_points))
    push!(info_table, ("Table KM-620 Material Category:", tableKM620_material_category))
    return info_table
end

"""
    write_ANSYS_tables(tables::Dict{String, DataFrame})

Writes ANSYS `tables` to an Excel file.
"""
function write_ANSYS_tables(tables, user_input::NamedTuple)
    filepath = user_input.output_file_path
    XLSX.openxlsx(filepath, mode="w") do file
        XLSX.rename!(file[1], "Iso Thermal Conductivity")
        XLSX.writetable!(file[1], tables["Thermal Conductivity"])
        XLSX.addsheet!(file, "Density")
        XLSX.writetable!(file[2], tables["Density"])
        XLSX.addsheet!(file, "Iso Inst Coef Thermal Expansion")
        XLSX.writetable!(file[3], tables["Thermal Expansion"])
        XLSX.addsheet!(file, "Isotropic Elasticity")
        XLSX.writetable!(file[4], tables["Elasticity"])
        XLSX.addsheet!(file, "Multilinear Kinematic Hardening")
        XLSX.writetable!(file[5], tables["Temperature"])
        for (i, temp) in enumerate(tables["Temperature"][:,1])
            file[5][1,3*i] = "Temperature = $(temp)°F"
            XLSX.writetable!(file[5], tables["Hardening $(temp)°F"], anchor_cell=XLSX.CellRef(2,3*i))
        end
        XLSX.addsheet!(file, "Input Information")
        file[6][1,1] = "FYI: NOT FOR ANSYS"
        file[6][2,1] = "The input values below were used to generate the tables in this workbook."
        XLSX.writetable!(file[6], make_info_table(; user_input...), anchor_cell=XLSX.CellRef(4,1))
    end
end