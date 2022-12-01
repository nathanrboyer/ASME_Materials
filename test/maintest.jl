using ASME_Materials, GLMakie, Printf

# User Inputs
spec_no = "SA-723"
type_grade = "3"
class_condition_temper = "2"
KM620_coefficients_table_material_category = "Ferritic steel"
output_folder = raw"S:\Material Properties\Excel Material Data\AIP Q&T Steels"

# Function Inputs
material_string = string(spec_no,'-',type_grade,'-',class_condition_temper)
material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
output_file_path = joinpath(output_folder, material_string*".xlsx")
plot_folder = joinpath(output_folder, "Plots")
user_input = (spec_no = spec_no,
                type_grade = type_grade,
                class_condition_temper = class_condition_temper,
                KM620_coefficients_table_material_category = KM620_coefficients_table_material_category,
                num_output_stress_points = 50,
                overwrite_yield = true,
                proportional_limit = 2.0e-5,
                input_file_path = "S:\\Material Properties\\Section II-D Tables.xlsx",
                output_file_path = output_file_path,
                output_folder = output_folder,
                plot_folder = plot_folder,
                material_string = material_string,
                material_dict = material_dict)

# Function Call
data = main(user_input)

σ = vcat(0, first(data.ANSYS_tables["Stress-Strain"].σ_t)[1:5])
ϵ = vcat(0, first(data.ANSYS_tables["Stress-Strain"].ϵ_ts)[1:5])
ϵp = vcat(0, first(data.ANSYS_tables["Stress-Strain"].γ_total)[1:5])
E = diff(σ) ./ diff(ϵ)
Ep = diff(σ) ./ diff(ϵp)

fig = Figure()
axis = Axis(fig[1,1],
            title = "Stress-Strain Curve of $material_string",
            xlabel = "ϵ (in/in)",
            ylabel = "σ (psi)")
scatterlines!(ϵ, σ, label = "Elastic + Plastic")
annotations!([@sprintf("E = %8.2e", i) for i in E], Point.(ϵ, σ .- 500)[begin+1:end], textsize = 20)
scatterlines!(ϵp, σ, label = "Plastic")
annotations!([@sprintf("E = %8.2e", i) for i in Ep], Point.(ϵp, σ .- 500)[begin+1:end], textsize = 20)
Legend(fig[1,2], axis, "Strain Type")
display(fig)