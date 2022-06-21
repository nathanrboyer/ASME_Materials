using ASME_Materials, DataFrames, Interpolations, GLMakie

user_input = (spec_no = "SA-723",
                type_grade = "3",
                class_condition_temper = "2",
                tableKM620_material_category = "Ferritic steel",
                num_output_stress_points = 20,
                overwrite_yield = true,
                proportional_limit = 5.0e-5,
                input_file_path = "S:\\Material Properties\\Section II-D Tables.xlsx",
                output_file_path = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\SA-723-3-2.xlsx",
                output_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels",
                plot_folder = "S:\\Material Properties\\Excel Material Data\\AIP Q&T Steels\\Plots",
                material_string = "SA-723-3-2",
                material_dict = Dict("Spec. No." => x -> x .== "SA-723",
                                    "Type/Grade" => x -> x .== "3",
                                    "Class/Condition/Temper" => x -> x .== "2"))

data = main(user_input)
df = data.ANSYS_tables["Stress-Strain"]
i200 = findfirst(df.T .== 200)
df200 = DataFrame(st = df[i200, :σ_t], ets = df[i200, :ϵ_ts],  eps = df[i200, :γ_total], ees = df[i200, :ϵ_ts] .- df[i200, :γ_total])
stress_value = 145001.533501501

interp_ets = LinearInterpolation(df200.st, df200.ets)
interp_eps = LinearInterpolation(df200.st, df200.eps)
interp_ees = LinearInterpolation(df200.st, df200.ees)

println(df200)
println("True Stress ", stress_value,
        "\nTotal Strain: ", interp_ets(stress_value),
        "\nPlastic Strain: ", interp_eps(stress_value),
        "\nElastic Strain: ", interp_ees(stress_value))

ϵp_AIP = df200.eps[1:5]
ϵp_original = copy(ϵp_AIP); ϵp_original[1] = data.user_input.proportional_limit
ϵp_SIA = ϵp_original .- data.user_input.proportional_limit
σ = df200.st[1:5]

fig = Figure(fontsize = 18)
axis = Axis(fig[1,1],
            title = "Plastic Stress-Strain Curves",
            xlabel = "Plastic Strain (in in^-1)",
            ylabel = "Stress (psi)",
            titlesize = 28,
            xlabelsize = 24,
            ylabelsize = 24)
scatterlines!(ϵp_original, σ, markersize = 20, linewidth = 5, label = "None")
scatterlines!(ϵp_SIA, σ, markersize = 20, linewidth = 5, label = "SIA")
scatterlines!(ϵp_AIP, σ, markersize = 20, linewidth = 5, label = "AIP")
axislegend("Zeroing\nMethod", position = :lt, titlesize = 24, labelsize = 22)
display(fig)
save(joinpath(@__DIR__,"test_sia.png"), fig)