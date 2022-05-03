# Setup
using GLMakie, ColorSchemes

# Isotropic Thermal Conductivity
fig1 = Figure()
axis1 = Axis(fig1[1,1],
            title = "Thermal Conductivity of $material_string",
            xlabel = "Temperature (°F)",
            ylabel = "Thermal Conductivity (Btu s^-1 in ^-1 °F^-1)")
scatterlines!(conductivity_table."Temperature (°F)",
            conductivity_table."TC (Btu s^-1 in ^-1 °F^-1)")
display(fig1)
save(joinpath(outputdir,string(material_string,"-Conductivity",".png")), fig1)

# Isotropic Instantaneous Coefficient of Thermal Expansion
fig2 = Figure()
axis2 = Axis(fig2[1,1],
            title = "Thermal Expansion of $material_string",
            xlabel = "Temperature (°F)",
            ylabel = "Instantaneous Thermal Expansion Coefficient (°F^-1)")
scatterlines!(expansion_table."Temperature (°F)",
            expansion_table."Coefficient of Thermal Expansion (°F^-1)")
display(fig2)
save(joinpath(outputdir,string(material_string,"-Expansion",".png")), fig2)

# Isotropic Elasticity
fig3 = Figure()
axis3 = Axis(fig3[1,1],
            title = "Elasticity of $material_string",
            xlabel = "Temperature (°F)",
            ylabel = "Young's Modulus (psi)")
scatterlines!(elasticity_table."Temperature (°F)",
            elasticity_table."Young's Modulus (psi)")
display(fig3)
save(joinpath(outputdir,string(material_string,"-Elasticity",".png")), fig3)

# Multilinear Kinematic Hardening
fig4 = Figure()
axis4 = Axis(fig4[1,1], title = "Stress-Strain Curves by Temperature", xlabel = "Plastic Strain (in in^-1)", ylabel = "Stress (psi)")
for i in 1:length(hardening_tables)
    scatterlines!(hardening_tables[i]."Plastic Strain (in in^-1)",
                    hardening_tables[i]."Stress (psi)",
                    label = string(master_table.T[i],"°F"),
                    color=ColorSchemes.vik[i/length(hardening_tables)])
end
Legend(fig4[1,2], axis4, "Temperature")
display(fig4)
save(joinpath(outputdir,string(material_string,"-PlasticStrain",".png")), fig4)
