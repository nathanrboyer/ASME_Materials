"""
    plot_ANSYS_tables(
        tables::Dict,
        material_string::String,
        output_folder::String = pwd()
    ) -> figures::Dict{String, Figure}

Plots ANSYS `tables`, titles figures with `material_string`, and saves figures to `output_folder`.

# Figures
- Thermal Conductivity
- Thermal Expansion
- Elasticity
- Platic Stress-Strain
- Yield Strength
- Ultimate Strength
- EPP Stress-Strain (Elastic Perfectly-Plastic Stress-Strain Curves with Allowed Stabilization)
- Total Stress-Strain
"""
function plot_ANSYS_tables(tables::Dict, material_string::String, output_folder::String = pwd())
    figures = Dict(
        "Thermal Conductivity" => plot_thermal_conductivity(tables, material_string, output_folder),
        "Thermal Expansion" => plot_thermal_expansion(tables, material_string, output_folder),
        "Elasticity" => plot_elasticity(tables, material_string, output_folder),
        "Plastic Stress-Strain" => plot_multilinear_hardening(tables, material_string, output_folder),
        "Yield Strength" => plot_yield_strength(tables, material_string, output_folder),
        "Ultimate Strength" => plot_ultimate_strength(tables, material_string, output_folder),
        "EPP Stress-Strain" => plot_epp_hardening(tables, material_string, output_folder),
        "Total Stress-Strain" => plot_total_stress_strain(tables, material_string, output_folder),
    )
    return figures
end

"""
    plot_ANSYS_tables(tables::Dict, user_input::NamedTuple) -> figures::Dict

Plots ANSYS `tables`, titles figures with `user_input.material_string`,
and saves figures to `user_input.plot_folder`.

# Figures
- Thermal Conductivity
- Thermal Expansion
- Elasticity
- Plastic Stress-Strain
- Yield Strength
- Ultimate Strength
- EPP Stress-Strain (Elastic Perfectly-Plastic Stress-Strain Curves with Allowed Stabilization)
- Total Stress-Strain
"""
function plot_ANSYS_tables(tables::Dict, user_input::NamedTuple)
    material_string = user_input.material_string
    output_folder = user_input.plot_folder
    plot_ANSYS_tables(tables::Dict, material_string::String, output_folder::String)
end


"""
    plot_thermal_conductivity(
        tables::Dict,
        material_string::String,
        output_folder::String = pwd(),
    )

Plot Isotropic Thermal Conductivity
"""
function plot_thermal_conductivity(
        tables::Dict,
        material_string::String,
        output_folder::String = pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Thermal Conductivity of $material_string",
        xlabel = "Temperature (°F)",
        ylabel = "Thermal Conductivity (Btu s^-1 in ^-1 °F^-1)",
    )
    scatterlines!(
        axis,
        tables["Thermal Conductivity"]."Temperature (°F)",
        tables["Thermal Conductivity"]."TC (Btu s^-1 in ^-1 °F^-1)",
    )
    display(fig)
    save(joinpath(output_folder,string(material_string,"-ThermalConductivity",".png")), fig)
    return fig
end

"""
    plot_thermal_expansion(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Isotropic Instantaneous Coefficient of Thermal Expansion
"""
function plot_thermal_expansion(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1, 1],
        title="Thermal Expansion of $material_string",
        xlabel="Temperature (°F)",
        ylabel="Instantaneous Thermal Expansion Coefficient (°F^-1)",
    )
    scatterlines!(
        axis,
        tables["Thermal Expansion"]."Temperature (°F)",
        tables["Thermal Expansion"]."Coefficient of Thermal Expansion (°F^-1)",
    )
    display(fig)
    save(joinpath(output_folder, string(material_string, "-ThermalExpansion", ".png")), fig)
    return fig
end

"""
    plot_elasticity(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Isotropic Elasticity
"""
function plot_elasticity(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Elasticity of $material_string",
        xlabel = "Temperature (°F)",
        ylabel = "Young's Modulus (psi)",
    )
    scatterlines!(
        axis,
        tables["Elasticity"]."Temperature (°F)",
        tables["Elasticity"]."Young's Modulus (psi)",
    )
    display(fig)
    save(joinpath(output_folder,string(material_string,"-Elasticity",".png")), fig)
    return fig
end


"""
    plot_multilinear_hardening(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Multilinear Kinematic Hardening
"""
function plot_multilinear_hardening(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Plastic Stress-Strain Curves of $material_string",
        xlabel = "Plastic Strain (in in^-1)",
        ylabel = "Stress (psi)",
    )
    for temp in tables["Temperature"][:,1]
        scatterlines!(
            axis,
            tables["Hardening $(temp)°F"]."Plastic Strain (in in^-1)",
            tables["Hardening $(temp)°F"]."Stress (psi)",
            label = "$(temp)°F",
            color=ColorSchemes.rainbow[temp/tables["Temperature"][end,1]],
        )
    end
    Legend(fig[1,2], axis, "Temperature")
    display(fig)
    save(joinpath(output_folder,string(material_string,"-PlasticStrain",".png")), fig)
    return fig
end

"""
    plot_yield_strength(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Yield Strength
"""
function plot_yield_strength(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Yield Strength of $material_string",
        xlabel = "Temperature (°F)",
        ylabel = "Yield Strength (psi)",
    )
    scatterlines!(
        axis,
        tables["Yield Strength"]."Temperature (°F)",
        tables["Yield Strength"]."Yield Strength (psi)",
    )
    display(fig)
    save(joinpath(output_folder,string(material_string,"-YieldStrength",".png")), fig)
    return fig
end

"""
    plot_ultimate_strength(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Ultimate Tensile Strength
"""
function plot_ultimate_strength(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Ultimate Strength of $material_string",
        xlabel = "Temperature (°F)",
        ylabel = "Ultimate Strength (psi)",
    )
    scatterlines!(
        axis,
        tables["Ultimate Strength"]."Temperature (°F)",
        tables["Ultimate Strength"]."Tensile Ultimate Strength (psi)",
    )
    display(fig)
    save(joinpath(output_folder,string(material_string,"-UltimateStrength",".png")), fig)
    return fig
end

"""
    plot_epp_hardening(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Elastic Perfectly Plastic Hardening
"""
function plot_epp_hardening(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "EPP Stress-Strain Curves of $material_string",
        xlabel = "Total Strain (in in^-1)",
        ylabel = "Stress (psi)",
    )
    elasticity_interp = linear_interpolation(
        tables["Elasticity"]."Temperature (°F)",
        tables["Elasticity"]."Young's Modulus (psi)",
        extrapolation_bc=Line(),
    )
    largest_temp = tables["EPP"][end-2,"Temperature (°F)"]
    for i in 1:Int(nrow(tables["EPP"])/3)
        j = 3 * (i - 1) + 1
        temp = tables["EPP"][j, "Temperature (°F)"]
        yield_stress = tables["EPP"][j, "Stress (psi)"]
        ultimate_stress = tables["EPP"][j+1, "Stress (psi)"]
        yield_strain = yield_stress/elasticity_interp(temp) +
                          tables["EPP"][j, "Plastic Strain (in in^-1)"]
        ultimate_strain = ultimate_stress/elasticity_interp(temp) +
                          tables["EPP"][j+1, "Plastic Strain (in in^-1)"]
        x = [0, yield_strain, ultimate_strain]
        y = [0, yield_stress, ultimate_stress]
        scatterlines!(
            axis,
            x,
            y,
            label = "$(temp)°F",
            color=ColorSchemes.rainbow[temp/largest_temp],
        )
    end
    Legend(fig[1,2], axis, "Temperature")
    display(fig)
    save(joinpath(output_folder,string(material_string,"-EPPStabilized",".png")), fig)
    return fig
end

"""
    plot_total_stress_strain(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )

Plot Total Stress-Strain
"""
function plot_total_stress_strain(
        tables::Dict,
        material_string::String,
        output_folder::String=pwd(),
    )
    mkpath(output_folder)
    fig = Figure()
    axis = Axis(
        fig[1,1],
        title = "Stress-Strain Curves of $material_string",
        xlabel = "Total Strain (in in^-1)",
        ylabel = "Stress (psi)",
    )
    for (i, temp) in enumerate(tables["Temperature"][:,1])
        scatterlines!(
            axis,
            vcat(0.0, tables["Stress-Strain"].ϵ_ts[i]),
            vcat(0.0, tables["Stress-Strain"].σ_t[i]),
            label = "$(temp)°F",
            color=ColorSchemes.rainbow[temp/tables["Temperature"][end,1]],
        )
    end
    Legend(fig[1,2], axis, "Temperature")
    display(fig)
    save(joinpath(output_folder,string(material_string,"-TotalStrain",".png")), fig)
    return fig
end
