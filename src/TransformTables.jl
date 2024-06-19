"""
    transform_ASME_tables(ASME_tables, ASME_groups; kwargs...) -> ANSYS_tables
    transform_ASME_tables(ASME_tables, ASME_groups, user_input) -> ANSYS_tables

Create new tables in ANSYS format from `ASME_tables`, `ASME_groups`, and material information.

# Arguments
- `ASME_tables::Dict{String, DataFrame}`: tables from `read_ASME_tables` function
- `ASME_groups::Dict{String, String}`: groups from `read_ASME_tables` function
- `user_input::NamedTuple`: collection of keyword arguments from `get_user_input` function

# Keyword Arguments (Required)
- `material_dict::Dict`:
    dictionary for material DataFrame filtering from `make_material_dict` function.

- `KM620_coefficients_table_material_category::String`:
   material category from Section VIII Division 3 Table KM-620.

- `num_plastic_points::Int`:
   number of evenly-spaced stress-strain points to compute between yield and ultimate stress.

# Returns
- `ANSYS_tables::Dict{String, DataFrame}`: collection of tables for defining an ANSYS material

"""
function transform_ASME_tables(
    ASME_tables::Dict{String, DataFrame}, ASME_groups::Dict{String, String};
    material_dict::Dict,
    KM620_coefficients_table_material_category::String,
    num_plastic_points::Int,
    _...,  # _... picks up any extra arguments
    )

    ν, ρ = read_PRD(ASME_tables, ASME_groups)  # read constants
    ANSYS_tables = Dict{String, DataFrame}()   # create output table dictionary
    ANSYS_tables["Density"] = transform_density(ρ)
    ANSYS_tables["Thermal Conductivity"] = transform_thermal_conductivity(ASME_tables)
    ANSYS_tables["Thermal Expansion"] = transform_thermal_expansion(ASME_tables)
    ANSYS_tables["Elasticity"] = transform_elasticity(ASME_tables, ASME_groups, ν)
    ANSYS_tables["Yield Strength"] = transform_yield(ASME_tables, material_dict)
    ANSYS_tables["Ultimate Strength"] = transform_ultimate(ASME_tables, material_dict)
    ANSYS_tables["Temperature"] = transform_temperature(ANSYS_tables)
    master_table = create_master_table(
        ANSYS_tables,
        KM620_coefficients_table_material_category,
        num_plastic_points,
    )
    for row in eachrow(master_table)
        ANSYS_tables["Hardening $(row.T)°F"] = transform_plasticity(row)
    end
    ANSYS_tables["EPP"] = transform_plasticity_perfectly(ANSYS_tables["Yield Strength"])

    return ANSYS_tables
end
transform_ASME_tables(
    ASME_tables::Dict{String,DataFrame},
    ASME_groups::Dict{String,String},
    user_input::NamedTuple
) = transform_ASME_tables(
    ASME_tables::Dict{String,DataFrame},
    ASME_groups::Dict{String,String};
    user_input..., # Splat user_input into keyword arguments.
) # allows `user_input` to be passed without splatting it into keyword arguments

"""
    get_numeric_headers(table::DataFrame) -> numeric_headers::Vector{Int}

Return all `table` column headers that can can be converted to integers.
"""
function get_numeric_headers(table::DataFrame)
    numeric_headers = Int[]
    for col in names(table)
        try
            num = parse(Int, col)
            push!(numeric_headers, num)
        catch
            continue
        end
    end
    return numeric_headers
end

"""
    get_row_data(table::DataFrame, conditions::Dict) -> row_data::Vector
    get_row_data(table::DataFrame, conditions::Dict, returncolumns) -> row_data::Vector

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

"""
    find_proportional_limit(table) -> σ_p
    find_proportional_limit(table, searchrange) -> σ_p

Finds the stress value `σ_p` where true strain `ϵ_ts` becomes nonlinear
and plasticity begins (`γ_1 + γ_2 == ϵ_p`) for each temperature row in the input `table`.

This is done by finding the root of the function `KM620.plasticity` with NonlinearSolve.jl.

# Arguments
- `table::DataFrame`: material data table
    - rows: material temperature
    - columns: material parameters
- `searchrange::Tuple{T, T} where T<:Number`: optional argument to change the search range for `σ_p`.
    Defaults to `(1.0, 1e6)`.

# Results
- `σ_p::Vector{Float64}`: stress values at the proportional limit for each input material temperature
"""
function find_proportional_limit(table::DataFrame, searchrange::Tuple=(1.0, 1e6))
    @assert(
        (length(searchrange) == 2) && (typeof(first(searchrange)) == typeof(last(searchrange))),
        "`searchrange` must be a `Tuple{T,T} where T<:Number` (two elements of the same type)"
    )
    σ_p = Float64[]
    problem = IntervalNonlinearProblem(KM620.plasticity, searchrange)
    for row in eachrow(table)
        problem = remake(problem, p=row)
        solution = solve(problem)
        push!(σ_p, solution.u)
    end
    return σ_p
end

"""
    read_PRD(ASME_tables, ASME_groups)

Return material Poisson's ratio ν (PR) and density ρ (D) from Section II-D Table PRD.
"""
function read_PRD(ASME_tables, ASME_groups)
    PRDgdf = groupby(ASME_tables["PRD"], "Material") # PRD table grouped by material
    PRDrow = PRDgdf[(ASME_groups["PRD"],)] |> only   # Relevant PRD table row for material
    ρ = PRDrow."Density (lb/inch^3)"
    ν = PRDrow."Poisson's Ratio"
    return ν, ρ
end
export read_PRD

"""
    transfrom_density(ρ)

Create density table for ANSYS material definition.

ANSYS expects a temperature dependency on ρ, which is why there is a table.
However, ASME only provides a single density value for all temperatures.
"""
function transform_density(ρ)
    DataFrame(
        "Temperature (°F)" => [""],
        "Density (lb in^-3)" => [ρ]
    )
end
export transform_density

"""
    transform_thermal_conductivity(ASME_tables)

Create isotropic thermal conductivity table for ANSYS material definition.

Uses Section II-D Table TCD to provide ANSYS with the material thermal conductivity in Btu/s/in/°F.
"""
function transform_thermal_conductivity(ASME_tables)
    select(
        ASME_tables["TCD"],
        "Temperature (°F)",
        "TC (Btu/hr-ft-°F)" => ByRow(x -> x / 3600 / 12) => "TC (Btu s^-1 in^-1 °F^-1)",
    ) |> dropmissing
end
export transform_thermal_conductivity

"""
    transform_thermal_expansion(ASME_tables)

Create isotropic instantaneous thermal expansion coefficient table for ANSYS material definition.

Uses Section II-D Table TE-1 to provide ANSYS with the material
coefficient of thermal expansion in 1/°F.
"""
function transform_thermal_expansion(ASME_tables)
    select(
        ASME_tables["TE"],
        "Temperature (°F)",
        "A (10^-6 inch/inch/°F)" => ByRow(x -> x * 10^-6) =>
            "Coefficient of Thermal Expansion (°F^-1)"
    ) |> dropmissing
end
export transform_thermal_expansion

"""
    transform_elasticity(ANSYS_tables, ASME_tables, ASME_groups)

Create isotropic elasticity table for ANSYS material definition.

Uses Section II-D Table TM-1 and Table PRD to provide ANSYS with the material
isotropic modulus of elasticity in psi and non-dimensional Poisson's ratio.
"""
function transform_elasticity(ASME_tables, ASME_groups, ν)
    DataFrame(
        "Temperature (°F)" => get_numeric_headers(ASME_tables["TM"]),
        "Young's Modulus (psi)" => get_row_data(
            ASME_tables["TM"],
            Dict("Materials" => x -> x .== ASME_groups["TM"]),
            get_numeric_headers(ASME_tables["TM"])
        ) .* 10^6,
        "Poisson's Ratio" => fill(ν, ncol(ASME_tables["TM"]) - 1)
    ) |> dropmissing
end
export transform_elasticity

"""
    transform_yield(ASME_tables, material_dict)

Create yield strength table for informational purposes and downstream processing.

Uses Section II-D Table Y-1.
"""
function transform_yield(ASME_tables, material_dict)
    yield_temps = get_numeric_headers(ASME_tables["Y"])
    yield_data = get_row_data(
        ASME_tables["Y"],
        material_dict,
        yield_temps
    ) .* 1000  # convert to psi
    DataFrame(
        "Temperature (°F)" => yield_temps,
        "Yield Strength (psi)" => yield_data,
    ) |> dropmissing
end
export transform_yield

"""
    transform_ultimate(ASME_tables, material_dict)

Create tensile ultimate strength table for informational purposes and downstream processing.

Uses Section II-D Table U.
"""
function transform_ultimate(ASME_tables, material_dict)
    ultimate_temps = get_numeric_headers(ASME_tables["U"])
    ultimate_data = get_row_data(
        ASME_tables["U"],
        material_dict,
        ultimate_temps
    ) .* 1000  # convert to psi
    DataFrame(
        "Temperature (°F)" => ultimate_temps,
        "Tensile Ultimate Strength (psi)" => ultimate_data,
    ) |> dropmissing
end
export transform_ultimate

"""
    transform_temperature(yield_table, ultimate_table)
    transform_temperature(ANSYS_tables)

Create temperature table for ANSYS plastic strain hardening data.

Temperatures are any that exist in either Section II-D Table Y-1 or Table U.
Uses output from the `transform_yield` and `transfrom_ultimate` functions.
"""
function transform_temperature(yield_table, ultimate_table)
    df = outerjoin(
        yield_table,
        ultimate_table,
        on = "Temperature (°F)",
    ) |> sort!
    select!(df, 1)
end
transform_temperature(ANSYS_tables::Dict) = transform_temperature(
    ANSYS_tables["Yield Strength"],
    ANSYS_tables["Ultimate Strength"],
)
export transform_temperature

"""
    create_interpolation_functions(ANSYS_tables::Dict)

Creates the interpolation functions required for the `create_master_table` function
and returns them in a `NamedTuple`.

Allows for calculation of interpolated values between those provided in the tables below:
    - `ANSYS_tables["Yield Strength"]`
    - `ANSYS_tables["Ultimate Strength"]`
    - `ANSYS_tables["Elasticity"]`

The input temperatures listed in each table may not match, so interpolation must be used.
"""
function create_interpolation_functions(ANSYS_tables::Dict)
    yield_interp = linear_interpolation(
        ANSYS_tables["Yield Strength"]."Temperature (°F)",
        ANSYS_tables["Yield Strength"]."Yield Strength (psi)",
        extrapolation_bc=Line(),
    )
    ultimate_interp = linear_interpolation(
        ANSYS_tables["Ultimate Strength"]."Temperature (°F)",
        ANSYS_tables["Ultimate Strength"]."Tensile Ultimate Strength (psi)",
        extrapolation_bc=Line(),
    )
    elasticity_interp = linear_interpolation(
        ANSYS_tables["Elasticity"]."Temperature (°F)",
        ANSYS_tables["Elasticity"]."Young's Modulus (psi)",
        extrapolation_bc=Line(),
    )
    poisson_interp = linear_interpolation(
        ANSYS_tables["Elasticity"]."Temperature (°F)",
        ANSYS_tables["Elasticity"]."Poisson's Ratio",
        extrapolation_bc=Line(),
    )
    return (; yield_interp, ultimate_interp, elasticity_interp, poisson_interp)
end
export create_interpolation_functions

"""
    create_master_table(ANSYS_tables, user_input)
    create_master_table(temperatures, interpolants, material_category, num_plastic_points)

Uses Section VIII Division 3 Paragraph KM-620 to compute the true plastic stress-strain relationship
of the provided material (`σ_t`,`ϵ_ts`) as well as other intermediate material properties.

True stress `σ_t` is a vector of equally-spaced points between the proportional limit `σ_p`
(at `ϵ_p`) and the true ultimate tensile stress `σ_utst` for every temperature.
True total strain `ϵ_ts` is calculated from `σ_t` using the equations in KM-620.

Output is a `DataFrame` containing all calculated quantites.
Some cells contain vector quantites and some contain scalar quantities.

# Arguments
- `ANSYS_tables::Dict{String, DataFrame}`:
    collection of tables to define ANSYS material model
- `material_category::AbstractString`:
    `KM620_coefficients_table_material_category` from `get_user_input`
- `num_plastic_points::Int`:
    number of plastic data points to calculate between yield and ultimate stress
- `temperatures::AbstractVector{<:Real}`:
    vector of material temperatures on which to compute stress-strain curves
- `interpolants::NamedTuple`:
    collection of interpolation functions used to look up `σ_ys`, `σ_uts`, `E_y`, and `ν`
    by temperature. See `create_interpolation_functions` for details.
"""
function create_master_table(
        temperatures::AbstractVector,
        interpolants::NamedTuple,
        material_category::AbstractString,
        num_plastic_points::Int,
    )

    # Build Stress-Strain Table with Interpolated Data
    df = DataFrame(T = temperatures)
    df.σ_ys = interpolants.yield_interp.(df.T)
    df.σ_uts = interpolants.ultimate_interp.(df.T)
    df.E_y = interpolants.elasticity_interp.(df.T)
    df.ν = interpolants.poisson_interp.(df.T)

    # KM-620 Scalar Quantities
    KM620_gdf = groupby(KM620.coefficients_table, "Material")
    KM620_table_row = KM620_gdf[(material_category,)] |> only
    df.R = KM620.R.(df.σ_ys, df.σ_uts)
    df.K = KM620.K.(df.R)
    df.ϵ_ys = fill(KM620.ϵ_ys(), nrow(df))
    df.ϵ_p = fill(KM620_table_row."ϵₚ", nrow(df))
    df.m_1 = KM620.m_1.(df.R, df.ϵ_p, df.ϵ_ys)
    df.m_2 = KM620_table_row."m₂".(df.R)
    df.A_1 = KM620.A_1.(df.σ_ys, df.ϵ_ys, df.m_1)
    df.A_2 = KM620.A_2.(df.σ_uts, df.m_2)
    df.σ_utst = KM620.σ_utst.(df.σ_uts, df.m_2)
    # df.σ_p = find_proportional_limit(df)  # FIX THIS
    df.σ_p = df.σ_ys                        # DELETE THIS

    # KM-620 Vector Quantities
    rowiterator = 1:nrow(df)
    df.σ_t = [range(
        start = df.σ_p[i],
        stop = df.σ_utst[i],
        length = num_plastic_points,
    ) for i in rowiterator]
    df.H = [KM620.H.(df.σ_t[i], df.σ_ys[i], df.σ_uts[i], df.K[i]) for i in rowiterator]
    df.ϵ_1 = [KM620.ϵ_1.(df.σ_t[i], df.A_1[i], df.m_1[i]) for i in rowiterator]
    df.ϵ_2 = [KM620.ϵ_2.(df.σ_t[i], df.A_2[i], df.m_2[i]) for i in rowiterator]
    df.γ_1 = [KM620.γ_1.(df.ϵ_1[i], df.H[i]) for i in rowiterator]
    df.γ_2 = [KM620.γ_2.(df.ϵ_2[i], df.H[i]) for i in rowiterator]
    df.γ_total = df.γ_1 .+ df.γ_2
    df.ϵ_ts = [KM620.ϵ_ts.(df.σ_t[i], df.E_y[i], df.γ_1[i], df.γ_2[i], df.ϵ_p[i]) for i in rowiterator]

    return df
end
create_master_table(
    ANSYS_tables::Dict,
    material_category::AbstractString,
    num_plastic_points::Int,
) = create_master_table(
    ANSYS_tables["Temperature"]."Temperature (°F)",
    create_interpolation_functions(ANSYS_tables),
    material_category,
    num_plastic_points,
)
export create_master_table

"""
    transform_plasticity(row::DataFrameRow)
    transform_plasticity(master_table::DataFrame)

Create multilinear kinematic hardening tables for ANSYS from the data in `master_table`.

If a single row from `master_table` is passed,
then a single hardening table `DataFrame` is returned for the temperature value defined in the row.
If the entire `master_table` is passed,
then a `Dict{String,DataFrame}` containing the hardening tables for every temperature is returned.

The first plastic data point (at the proportional limit) is shifted
according to KM-620.2 such that the total plastic strain there is identically zero.
Zero plastic strain at the first data point is also an ANSYS material requirement.
"""
function transform_plasticity(row::DataFrameRow)
    pstrain = row."γ_total"
    pstrain[1] = 0  # ANSYS requires first point to be precisely zero plastic strain
    stress = row."σ_t"
    DataFrame(
        "Plastic Strain (in in^-1)" => pstrain,
        "Stress (psi)" => stress,
    )
end
transform_plasticity(master_table::DataFrame) = Dict(
    "Hardening $(row.T)°F" => transform_plasticity(row) for row in eachrow(master_table)
)
export transform_plasticity

"""
    transform_plasticity_perfectly(yield_table)

Create elastic perfectly plastic (EPP) trilinear kinematic hardening tables for ANSYS
from the data in `yield_table`.

A tri-linear material model with the small amount of stabilizing hardening allowed by
ASME BPVC.VIII.3 KM-610 is used before finally becoming perfectly-plastic with no hardening.
The hardening is defined by the constants `increase_in_strength` and `increase_in_plastic_strain`.

The slopes in the three segments are thus (E_y, E_t, 0),
where E_y is the slope in the elastic region,
E_t is the slope in the stabilized portion of the plastic region,
and 0 is the slope in the unstabilized portion of the plastic region.
The second datapont can be deleted to implement a true perfectly plastic material model.
"""
function transform_plasticity_perfectly(yield_table)

    # Extract data from `yield_table`.
    T = yield_table."Temperature (°F)"      # Temperature Values
    S = yield_table."Yield Strength (psi)"  # Yield Strength Values
    N = length(T)                           # Number of Temperature Data Points

    # Allocate DataFrame with `missing` values.
    df = DataFrame(
        "Temperature (°F)" => Vector{Union{Int, Missing}}(missing, 4N),
        "Plastic Strain (in in^-1)" => Vector{Union{Float64, Missing}}(missing, 4N),
        "Stress (psi)" => Vector{Union{Float64, Missing}}(missing, 4N)
    )

    # Fill DataFrame with stabilized EPP stress-strain data.
    for i in 1:N
        # Define Index in Output DataFrame (Four Rows per Temperature)
        j = 4 * (i - 1) + 1

        # First Point
        df[j, "Temperature (°F)"] = T[i]
        df[j, "Plastic Strain (in in^-1)"] = 0.0
        df[j, "Stress (psi)"] = S[i]

        # Second Point
        df[j+1, "Plastic Strain (in in^-1)"] = increase_in_plastic_strain
        df[j+1, "Stress (psi)"] = S[i] * (1 + increase_in_strength)

        # Third Point
        df[j+2, "Plastic Strain (in in^-1)"] = 2 * increase_in_plastic_strain
        df[j+2, "Stress (psi)"] = S[i] * (1 + increase_in_strength)

        # Blank Fourth Row
    end

    return df
end
export transform_plasticity_perfectly
