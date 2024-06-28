# Input.jl
@test make_material_string("a", "b", "c") == "a-b-c"
dict = make_material_dict("a", "b", "c")
@test keys(dict) |> collect == ["Spec. No.", "Type/Grade", "Class/Condition/Temper"]
@test values(dict) |> collect == ["a", "b", "c"]

# TransformTables.jl
table = DataFrame(
           first_name = ["John", "John", "Sarah"],
           last_name = ["Smith", "Glenn", "Jones"],
           age = [24, 37, 18],
       )
conditions = Dict(:first_name => "John", :last_name => "Glenn")
@test get_row_data(table, conditions, :age) == 37
