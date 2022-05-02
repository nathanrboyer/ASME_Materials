# Function Definitions
"""
    get_numeric_headers(table::DataFrame)

Return all `table` column headers that can can be converted to integers.
"""
function get_numeric_headers(table::DataFrame)
    temps = Int[]
    for col in names(table)
        try
            temp = parse(Int, col)
            push!(temps, temp)
        catch
            continue
        end
    end
    return temps
end

"""
    get_row_data(table::DataFrame, conditions::Dict, [returncolumns])

Returns the `table` row that meets all the provided `conditions`.
`conditions` is a `Dict` which maps column names to filtering functions
e.g. Dict("Column Name" => (x -> x .== cellvalue)).
`returncolumns` can optionally be provided to return only certain columns of the DataFrame.
`returncolumns` may be a single column index or a vector of column indices.
"""
function get_row_data(table::DataFrame, conditions::Dict, returncolumns)
    subset(table, conditions...)[:,string.(returncolumns)] |> only |> Vector
end
function get_row_data(table::DataFrame, conditions::Dict)
    subset(table, conditions...) |> only |> Vector
end

# Combine Material Information from Inputs
material = Dict("Spec. No." => x -> x .== specno,
            "Type/Grade" => x -> x .== type_grade,
            "Class/Condition/Temper" => x -> x .== class_condition_temper)

# Isotropic Thermal Conductivity
conductivity_table = select(tableTCD, "Temperature (°F)", "TC (Btu/hr-ft-°F)" => ByRow(x -> x / 3600 / 12) => "TC (Btu s^-1 in ^-1 °F^-1)") |> dropmissing

# Density
ρ = tablePRD[tablePRD."Material" .== PRDgroup, "Density (lb/inch^3)"] |> only
density_table = DataFrame("Temperature (°F)" => [""], "Density (lbm in^-3)" => [ρ])
pretty_table(density_table, nosubheader=true, crop=:horizontal)

# Isotropic Instantaneous Coefficient of Thermal Expansion
expansion_table = select(tableTE, "Temperature (°F)", "A (10^-6 inch/inch/°F)" => ByRow(x -> x*10^-6) => "Coefficient of Thermal Expansion (°F^-1)") |> dropmissing
pretty_table(expansion_table, nosubheader=true, crop=:horizontal)

# Isotropic Elasticity
ν = tablePRD[tablePRD."Material" .== PRDgroup, "Poisson's Ratio"] |> only
elasticity_table = DataFrame(
                    "Temperature (°F)" => get_numeric_headers(tableTM),
                    "Young's Modulus (psi)" => get_row_data(tableTM, Dict("Materials" => x -> x.==TMgroup), get_numeric_headers(tableTM)) .* 10^6,
                    "Poisson's Ratio" => fill(ν, ncol(tableTM) - 1)
                    ) |> dropmissing
pretty_table(elasticity_table, nosubheader=true, crop=:horizontal)

# Multilinear Kinematic Hardening
## Yield and Ultimate Strength Data
yield_temps = get_numeric_headers(tableY)
yield_data = get_row_data(tableY, material, yield_temps) .* 1000
yield_table =  DataFrame(T = yield_temps, σ_ys = yield_data) |> dropmissing
ultimate_temps = get_numeric_headers(tableU)
ultimate_data = get_row_data(tableU, material, ultimate_temps) .* 1000
ultimate_table =  DataFrame(T = ultimate_temps, σ_uts = ultimate_data) |> dropmissing

## Interpolation
yield_interp = LinearInterpolation(yield_table.T, yield_table.σ_ys, extrapolation_bc=Line())
ultimate_interp = LinearInterpolation(ultimate_table.T, ultimate_table.σ_uts, extrapolation_bc=Line())
elasticity_interp = LinearInterpolation(elasticity_table."Temperature (°F)", elasticity_table."Young's Modulus (psi)", extrapolation_bc=Line())
poisson_interp = LinearInterpolation(elasticity_table."Temperature (°F)", elasticity_table."Poisson's Ratio", extrapolation_bc=Line())

## Build Master Table with Interpolated Data
master_table = outerjoin(yield_table, ultimate_table, on = :T) |> sort
master_table.σ_ys = yield_interp.(master_table.T)
master_table.σ_uts = ultimate_interp.(master_table.T)
master_table.E_y = elasticity_interp.(master_table.T)
master_table.ν = poisson_interp.(master_table.T)

## Apply KM620 to Master Table
master_table.R = R.(master_table.σ_ys, master_table.σ_uts)
master_table.K = K.(master_table.R)
master_table.ϵ_ys = fill(ϵ_ys(), nrow(master_table))
master_table.ϵ_p = fill(only(tableKM620[tableKM620."Material" .== tableKM620_material_category, "ϵₚ"]), nrow(master_table))
master_table.m_1 = m_1.(master_table.R, master_table.ϵ_p, master_table.ϵ_ys)
master_table.m_2 = only(tableKM620[tableKM620."Material" .== tableKM620_material_category, "m₂"]).(master_table.R)
master_table.A_1 = A_1.(master_table.σ_ys, master_table.ϵ_ys, master_table.m_1)
master_table.A_2 = A_2.(master_table.σ_uts, master_table.m_2)
master_table.σ_utst = σ_utst.(master_table.σ_uts, master_table.m_2)
master_table.σ_t = [range(start = master_table.σ_ys[i], stop = master_table.σ_utst[i], length = num_output_stress_points) for i in 1:nrow(master_table)]
master_table.H = H.(master_table.σ_t, master_table.σ_ys, master_table.σ_uts, master_table.K)
master_table.ϵ_1 = ϵ_1.(master_table.σ_t, master_table.A_1, master_table.m_1)
master_table.ϵ_2 = ϵ_2.(master_table.σ_t, master_table.A_2, master_table.m_2)
master_table.γ_1 = γ_1.(master_table.ϵ_1, master_table.H)
master_table.γ_2 = γ_2.(master_table.ϵ_2, master_table.H)
master_table.γ_total = master_table.γ_1 .+ master_table.γ_2
master_table.ϵ_ts = ϵ_ts.(master_table.σ_t, master_table.E_y, master_table.γ_1, master_table.γ_2)
pretty_table(master_table, nosubheader=true, crop=:horizontal)

## Build Temperature Table from Master Table
temp_table = DataFrame("Temperature (°F)" => master_table.T)

## Build Hardening Tables from Master Table
hardening_tables = [DataFrame() for i in 1:nrow(master_table)]
for i in 1:nrow(master_table)
    hardening_tables[i]."Plastic Strain (in in^-1)" = master_table[i,"γ_total"]
    hardening_tables[i]."Stress (psi)" = master_table[i,"σ_t"]
end
