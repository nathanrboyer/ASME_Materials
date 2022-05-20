"""
    fig1, fig2, fig3, fig4 = plot_ANSYS_tables(tables)

Plots ANSYS `tables and saves the figures to `outputdir`.
"""
function plot_ANSYS_tables(tables)
    mkpath(plotdir)
    # Isotropic Thermal Conductivity
    fig1 = Figure()
    axis1 = Axis(fig1[1,1],
                title = "Thermal Conductivity of $material_string",
                xlabel = "Temperature (°F)",
                ylabel = "Thermal Conductivity (Btu s^-1 in ^-1 °F^-1)")
    scatterlines!(tables["Thermal Conductivity"]."Temperature (°F)",
                    tables["Thermal Conductivity"]."TC (Btu s^-1 in ^-1 °F^-1)")
    display(fig1)
    save(joinpath(plotdir,string(material_string,"-ThermalConductivity",".png")), fig1)

    # Isotropic Instantaneous Coefficient of Thermal Expansion
    fig2 = Figure()
    axis2 = Axis(fig2[1,1],
                title = "Thermal Expansion of $material_string",
                xlabel = "Temperature (°F)",
                ylabel = "Instantaneous Thermal Expansion Coefficient (°F^-1)")
    scatterlines!(tables["Thermal Expansion"]."Temperature (°F)",
                    tables["Thermal Expansion"]."Coefficient of Thermal Expansion (°F^-1)")
    display(fig2)
    save(joinpath(plotdir,string(material_string,"-ThermalExpansion",".png")), fig2)

    # Isotropic Elasticity
    fig3 = Figure()
    axis3 = Axis(fig3[1,1],
                title = "Elasticity of $material_string",
                xlabel = "Temperature (°F)",
                ylabel = "Young's Modulus (psi)")
    scatterlines!(tables["Elasticity"]."Temperature (°F)",
                    tables["Elasticity"]."Young's Modulus (psi)")
    display(fig3)
    save(joinpath(plotdir,string(material_string,"-Elasticity",".png")), fig3)

    # Multilinear Kinematic Hardening
    fig4 = Figure()
    axis4 = Axis(fig4[1,1], title = "Stress-Strain Curves of $material_string", xlabel = "Plastic Strain (in in^-1)", ylabel = "Stress (psi)")
    for temp in tables["Temperature"][:,1]
        scatterlines!(tables["Hardening $(temp)°F"]."Plastic Strain (in in^-1)",
                        tables["Hardening $(temp)°F"]."Stress (psi)",
                        label = "$(temp)°F",
                        color=ColorSchemes.vik[temp/tables["Temperature"][end,1]])
    end
    Legend(fig4[1,2], axis4, "Temperature")
    display(fig4)
    save(joinpath(plotdir,string(material_string,"-PlasticStrain",".png")), fig4)

    return fig1, fig2, fig3, fig4
end