using ASME_Materials

# User Inputs
spec_no = "SA-723"
type_grade = "3"
class_condition_temper = "2a"
tableKM620_material_category = "Ferritic steel"
output_folder = raw"S:\Material Properties\Excel Material Data\AIP Q&T Steels"

# Function Inputs
material_string = string(spec_no,'-',type_grade,'-',class_condition_temper)
material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
output_file_path = joinpath(output_folder, material_string*".xlsx")
plot_folder = joinpath(output_folder, "Plots")
user_input = (spec_no = spec_no,
                type_grade = type_grade,
                class_condition_temper = class_condition_temper,
                tableKM620_material_category = tableKM620_material_category,
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
main(user_input)