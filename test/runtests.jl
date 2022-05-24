using Test
using ASME_Materials
using ColorSchemes, DataFrames, GLMakie, Interpolations, Latexify, NativeFileDialog, PrettyTables, Term, XLSX

user_input = get_user_input()
ASME_tables, ASME_groups = read_ASME_tables(user_input.input_file_path)
tables = transform_ASME_tables(ASME_tables, ASME_groups)
write_output = write_ANSYS_tables(tables)
fig1, fig2, fig3, fig4 = plot_ANSYS_tables(tables)

# Check Table Output
"""
    check_table(table, column, value)

Obtain table row where `column` matches `value`,
then print the name and value in each column.
If the cell contains a collection,
then print the first and last element.
`table` - DataFrame to check
`column` - column name as a String or Symbol
`value` - cell value to look for in the `column` (any type)
"""
function check_table(table, column, value)
    for col in names(table)
        println("")
        println(col)
        data = only(table[table[:, column] .== value, col])
        if typeof(data) <: AbstractArray
            println(data[1])
            println(data[end])
        else
            println(data)
        end
    end
end
check_table(tables["Stress-Strain"], "T", 200)

# Built-In Plots
display(fig1)
display(fig2)
display(fig3)
display(fig4)

# Compare Stress-Strain Data to Michael's
σ_michael_200 = [125000
126000
127000
128000
129000
130000
130300
131000
132000
133000
134000
135000
135100
136000
137000
138000
139000
139300
140000
141000
142000
142700
143000
144000
145000
145727
146000
147000
148000
149000
150000
151000
151704
152000
153000
154000
154285
155000
156000
156682
157000
157511
]

ϵ_michael_200 = [0.001936769
0.002519284
0.00329659
0.00432703
0.005630837
0.007112586
0.007560789
0.008561405
0.009821935
0.010913902
0.01194655
0.013012404
0.013123087
0.014162773
0.015421618
0.016800388
0.018306288
0.018783822
0.019945922
0.021726634
0.023656903
0.025102198
0.025746374
0.028005793
0.030446936
0.032342971
0.033082564
0.035926405
0.038993152
0.042298492
0.045859138
0.049692872
0.052565796
0.0538186
0.058256406
0.063027614
0.064451581
0.068154855
0.073662138
0.077649075
0.079574921
0.082761556
]

fig5 = Figure()
axis5 = Axis(fig5[1,1], title = "SA-723 Grade 3 Class 2a at 200°F", xlabel = "Plastic Strain (in in^-1)", ylabel = "Stress (psi)")
scatterlines!(tables["Hardening 200°F"]."Plastic Strain (in in^-1)", tables["Hardening 200°F"]."Stress (psi)", label = "Nathan")
scatterlines!(ϵ_michael_200, σ_michael_200, label = "Michael")
Legend(fig5[1,2], axis5, "Author")
display(fig5)
save(joinpath(user_input.output_folder,"verification.png"), fig5)

# Show Master Table at Yield Stress
master_table_yield = DataFrame()
for col in names(tables["Stress-Strain"])
    master_table_yield[:,col] = first.(tables["Stress-Strain"][:,col])
end
pretty_table(master_table_yield, nosubheader=true, crop=:horizontal)
XLSX.writetable(joinpath(user_input.output_folder,"Yield_Data.xlsx"), master_table_yield)

# Show Master Table at Ultimate Stress
master_table_ultimate = DataFrame()
for col in names(tables["Stress-Strain"])
    master_table_ultimate[:,col] = last.(tables["Stress-Strain"][:,col])
end
pretty_table(master_table_ultimate, nosubheader=true, crop=:horizontal)
XLSX.writetable(joinpath(user_input.output_folder,"Ultimate_Data.xlsx"), master_table_ultimate)


# Pretty Print DataFrames
pretty_table(tables["Density"], nosubheader=true, crop=:horizontal)
pretty_table(tables["Thermal Expansion"], nosubheader=true, crop=:horizontal)
pretty_table(tables["Elasticity"], nosubheader=true, crop=:horizontal)
pretty_table(tables["Stress-Strain"], nosubheader=true, crop=:horizontal)