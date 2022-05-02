# using Test
# using ASME_Materials
# using DataFrames, Interpolations, Latexify, PrettyTables, XLSX
# using Gadfly
# using WGLMakie
using GLMakie

# df = DataFrame(x=[1,2,3])

# # Gadfly
# plot(Guide.xlabel(T), Guide.ylabel("Strength (psi)"),
#     #layer(x=master_table_raw.T, y=master_table_raw.σ_ys, color=["Raw Yield Strength (psi)"]),
#     #layer(x=master_table_raw.T, y=master_table_raw.σ_uts, color=["Raw Ultimate Strength (psi)"]),
#     layer(x=master_table.T, y=master_table.σ_ys, color=["Yield Strength (psi)"]),
#     layer(x=master_table.T, y=master_table.σ_uts, color=["Ultimate Strength (psi)"])
# )

# Makie
fig1 = Figure()
axis1 = Axis(fig1[1,1], title = "Stress-Strain Curves by Temperature", xlabel = "Plastic Strain (in in^-1)", ylabel = "Stress (psi)")
for i in 1:length(hardening_tables)
    scatterlines!(hardening_tables[i]."Plastic Strain (in in^-1)", hardening_tables[i]."Stress (psi)", label = string(master_table.T[i],"°F"))
end
Legend(fig1[1,2], axis1, "Temperature")
display(fig1)

fig2 = Figure()
axis2 = Axis(fig2[1,1], title = "Stress Values by Temperature", xlabel = "Linear Mapping", ylabel = "Stress (psi)")
for i in 1:length(hardening_tables)
    scatterlines!(1:length(hardening_tables[i]."Stress (psi)"), hardening_tables[i]."Stress (psi)", label = string(master_table.T[i],"°F"))
end
Legend(fig2[1,2], axis2, "Temperature")
display(fig2)

# Compare with Michael
σ_michael_200 = [115000
116000
117000
118000
119000
120000
121000
121300
122000
123000
124000
125000
125800
126000
127000
128000
129000
129700
130000
131000
132000
132900
133000
134000
135000
136000
136184.8
137000
138000
139000
140000
141000
141730.9
142000
143000
144000
144306.8
145000
146000
146615.7
147000
147418.4
]

ϵ_michael_200 = [0.001848525
0.002412426
0.003166029
0.004172365
0.005475177
0.007027458
0.008645285
0.009109282
0.010121002
0.011398001
0.012562164
0.013723228
0.014700565
0.014954711
0.016294928
0.017762564
0.01936802
0.020578097
0.021119218
0.02302411
0.025091593
0.027099671
0.027331773
0.029755972
0.03237667
0.035207457
0.035754738
0.038262993
0.041559005
0.045112292
0.048940762
0.053063463
0.056274472
0.057500638
0.062273782
0.067405697
0.069055779
0.072920568
0.078844024
0.082706035
0.085203222
0.088000029
]

fig3 = Figure()
axis3 = Axis(fig3[1,1], title = "SA-723 Grade 3 Class 2 at 200°F", xlabel = "Plastic Strain (in in^-1)", ylabel = "Stress (psi)")
scatterlines!(hardening_tables[3]."Plastic Strain (in in^-1)", hardening_tables[3]."Stress (psi)", label = "Nathan")
scatterlines!(ϵ_michael_200, σ_michael_200, label = "Michael")
Legend(fig3[1,2], axis3, "Author")
display(fig3)
