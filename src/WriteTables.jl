"""
    write_ANSYS_tables(tables::Dict{String, DataFrame})

Writes ANSYS `tables` to an Excel file.
"""
function write_ANSYS_tables(tables)
    XLSX.openxlsx(outputfilepath, mode="w") do file
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
    end
end