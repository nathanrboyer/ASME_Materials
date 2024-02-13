"""
    transform_ASME_tables(ASME_tables, ASME_groups; kwargs...)

Create new tables in ANSYS format from `ASME_tables` and `ASME_groups`.

# Arguments
- `ASME_tables::Dict{String, DataFrame}`: tables from `read_ASME_tables` function
- `ASME_groups::Dict{String, String}`: groups from `read_ASME_tables` function

# Keyword Arguments (Required)
- `material_dict::Dict`:
   Dictionary for material DataFrame filtering.
   Call `make_material_dict(spec_no, type_grade, class_condition_temper)` to make.
- `KM620_coefficients_table_material_category::String`:
   Material Category from Section VIII Division 3 Table KM-620.
- `num_output_stress_points::Int`:
   Number of evenly-spaced stress-strain points
   to compute on curve between yield and ultimate stress.

# Returns
- `ANSYS_tables::Dict{String, DataFrame}`:
   collection of tables for defining an ANSYS material

"""
function transform_ASME_tables(
    ASME_tables::Dict{String, DataFrame}, ASME_groups::Dict{String, String};
    material_dict::Dict,
    KM620_coefficients_table_material_category::String,
    num_output_stress_points::Int,
    _...,  # _... picks up any extra arguments
    )

    # Read Constants
    PRDgdf = groupby(ASME_tables["PRD"], "Material") # PRD table grouped by material
    PRDrow = PRDgdf[(ASME_groups["PRD"],)] |> only   # Relevant PRD table row for material
    ρ = PRDrow."Density (lb/inch^3)"
    ν = PRDrow."Poisson's Ratio"

    # Create Output Table dictionary
    tables = Dict{String, DataFrame}()

    # Density
    tables["Density"] = DataFrame(
        "Temperature (°F)" => [""],
        "Density (lb in^-3)" => [ρ]
    )

    # Isotropic Instantaneous Coefficient of Thermal Expansion
    tables["Thermal Expansion"] = select(
        ASME_tables["TE"],
        "Temperature (°F)",
        "A (10^-6 inch/inch/°F)" => ByRow(x -> x*10^-6) =>
            "Coefficient of Thermal Expansion (°F^-1)"
    ) |> dropmissing

    # Isotropic Elasticity
    tables["Elasticity"] = DataFrame(
        "Temperature (°F)" => get_numeric_headers(ASME_tables["TM"]),
        "Young's Modulus (psi)" => get_row_data(
            ASME_tables["TM"],
            Dict("Materials" => x -> x .== ASME_groups["TM"]),
            get_numeric_headers(ASME_tables["TM"])
        ) .* 10^6,
        "Poisson's Ratio" => fill(ν, ncol(ASME_tables["TM"]) - 1)
    ) |> dropmissing

    # Multilinear Kinematic Hardening
    ## Yield and Ultimate Strength Data
    yield_temps = get_numeric_headers(ASME_tables["Y"])
    yield_data = get_row_data(
        ASME_tables["Y"],
        material_dict,
        yield_temps
    ) .* 1000
    yield_table =  DataFrame(T = yield_temps, σ_ys = yield_data) |> dropmissing
    ultimate_temps = get_numeric_headers(ASME_tables["U"])
    ultimate_data = get_row_data(
        ASME_tables["U"],
        material_dict,
        ultimate_temps
    ) .* 1000
    ultimate_table =  DataFrame(T = ultimate_temps, σ_uts = ultimate_data) |> dropmissing

    ## Interpolation
    yield_interp = linear_interpolation(
        yield_table.T,
        yield_table.σ_ys,
        extrapolation_bc=Line()
    )
    ultimate_interp = linear_interpolation(
        ultimate_table.T,
        ultimate_table.σ_uts,
        extrapolation_bc=Line()
    )
    elasticity_interp = linear_interpolation(
        tables["Elasticity"]."Temperature (°F)",
        tables["Elasticity"]."Young's Modulus (psi)",
        extrapolation_bc=Line()
    )
    poisson_interp = linear_interpolation(
        tables["Elasticity"]."Temperature (°F)",
        tables["Elasticity"]."Poisson's Ratio",
        extrapolation_bc=Line()
    )

    ## Build Stress-Strain Table with Interpolated Data
    tables["Stress-Strain"] = outerjoin(yield_table, ultimate_table, on = :T) |> sort
    ss = tables["Stress-Strain"] # user shorter name for subsequent calculations
    ss.σ_ys = yield_interp.(ss.T)
    ss.σ_uts = ultimate_interp.(ss.T)
    ss.E_y = elasticity_interp.(ss.T)
    ss.ν = poisson_interp.(ss.T)

    ## Apply KM-620 to Stress-Strain Table
        #=
        True stress σ_t is a vector of equally-spaced points between the proportional limit
        and the true ultimate tensile stress for every temperature.
        True total strain ϵ_t is calculated from σ_t using the equations in KM-620.
        =#
    KM620_gdf = groupby(KM620.coefficients_table, "Material")
    KM620_table_row = KM620_gdf[(KM620_coefficients_table_material_category,)] |> only
    ss.R = KM620.R.(ss.σ_ys, ss.σ_uts)
    ss.K = KM620.K.(ss.R)
    ss.ϵ_ys = fill(KM620.ϵ_ys(), nrow(ss))
    ss.ϵ_p = fill(KM620_table_row."ϵₚ", nrow(ss))
    ss.m_1 = KM620.m_1.(ss.R, ss.ϵ_p, ss.ϵ_ys)
    ss.m_2 = KM620_table_row."m₂".(ss.R)
    ss.A_1 = KM620.A_1.(ss.σ_ys, ss.ϵ_ys, ss.m_1)
    ss.A_2 = KM620.A_2.(ss.σ_uts, ss.m_2)
    ss.σ_utst = KM620.σ_utst.(ss.σ_uts, ss.m_2)

    ss.σ_p = find_proportional_limit(ss) # TODO: Switch to NonlinearSolve.jl for root finding.

    rowiterator = 1:nrow(ss)
    ss.σ_t = [range(
        start = ss.σ_p[i],
        stop = ss.σ_utst[i],
        length = num_output_stress_points,
    ) for i in rowiterator]
    ss.H = [KM620.H.(ss.σ_t[i], ss.σ_ys[i], ss.σ_uts[i], ss.K[i]) for i in rowiterator]
    ss.ϵ_1 = [KM620.ϵ_1.(ss.σ_t[i], ss.A_1[i], ss.m_1[i]) for i in rowiterator]
    ss.ϵ_2 = [KM620.ϵ_2.(ss.σ_t[i], ss.A_2[i], ss.m_2[i]) for i in rowiterator]
    ss.γ_1 = [KM620.γ_1.(ss.ϵ_1[i], ss.H[i]) for i in rowiterator]
    ss.γ_2 = [KM620.γ_2.(ss.ϵ_2[i], ss.H[i]) for i in rowiterator]
    ss.γ_total = ss.γ_1 .+ ss.γ_2
    ss.ϵ_ts = [KM620.ϵ_ts.(ss.σ_t[i], ss.E_y[i], ss.γ_1[i], ss.γ_2[i], ss.ϵ_p[i]) for i in rowiterator]

    ## Build Temperature Table from Stress-Strain Table
    tables["Temperature"] = DataFrame("Temperature (°F)" => tables["Stress-Strain"].T)

    ## Build Hardening Tables from Stress-Strain Table
        #=
        The first plastic data point (at the proportional limit) is shifted
        according to KM-620.2 such that the total plastic strain there is identically zero.
        Zero plastic strain at the first data point is also an ANSYS material requirement.
        =#
    for (i, temp) in enumerate(tables["Stress-Strain"].T)
        tables["Hardening $(temp)°F"] = DataFrame(
            "Plastic Strain (in in^-1)" => tables["Stress-Strain"][i,"γ_total"],
            "Stress (psi)" => tables["Stress-Strain"][i,"σ_t"],
        )
        tables["Hardening $(temp)°F"]."Plastic Strain (in in^-1)"[begin] = 0
    end

    # Yield Strength
    tables["Yield Strength"] = select(
        yield_table, :T => "Temperature (°F)", :σ_ys => "Yield Strength (psi)",
    )

    # Ultimate Strength
    tables["Ultimate Strength"] = select(
        ultimate_table, :T => "Temperature (°F)", :σ_uts => "Tensile Ultimate Strength (psi)",
    )

    # Isotropic Thermal Conductivity
    tables["Thermal Conductivity"] = select(
        ASME_tables["TCD"],
        "Temperature (°F)",
        "TC (Btu/hr-ft-°F)" => ByRow(x -> x / 3600 / 12) => "TC (Btu s^-1 in ^-1 °F^-1)",
    ) |> dropmissing

    # Elastic Perfectly Plastic Multilinear Kinematic Hardening
        #=
        Trilinear material model with nearly perfectly plastic hardening.
        Maximum stabilization allowed by ASME BPVC.VIII.3 KM-610 is used.
        Slopes are (E_y, E_t, 0), respectively.
        The second datapont can be deleted to implement a true perfectly plastic material.
        =#
    tables["EPP"] = DataFrame(
        "Temperature (°F)" => Vector{Union{Int, Missing}}(missing, 3*nrow(yield_table)),
        "Plastic Strain (in in^-1)" => Vector{Union{Float64, Missing}}(missing, 3*nrow(yield_table)),
        "Stress (psi)" => Vector{Union{Float64, Missing}}(missing, 3*nrow(yield_table))
    )   # Allocate DataFrame with `missing` values.
    for i in 1:nrow(yield_table)
        local j = 3 * (i - 1) + 1
        tables["EPP"][j, "Temperature (°F)"] = yield_table.T[i]
        tables["EPP"][j, "Plastic Strain (in in^-1)"] = 0.0
        tables["EPP"][j, "Stress (psi)"] = yield_table.σ_ys[i]

        tables["EPP"][j+1, "Plastic Strain (in in^-1)"] = increase_in_plastic_strain
        tables["EPP"][j+1, "Stress (psi)"] = yield_table.σ_ys[i] * (1 + increase_in_strength)
    end

    return tables
end

"""
    transform_ASME_tables(ASME_tables, ASME_groups, user_input) -> ANSYS_tables

Create new tables in ANSYS format from `ASME_tables`, `ASME_groups`, and `user_input`.

# Arguments
- `ASME_tables::Dict{String, DataFrame}`:
   collection of tables read from the `read_ASME_tables` function
- `ASME_groups::Dict{String, String}`:
   collection of table groups read from the `read_ASME_tables` function
- `user_input::NamedTuple`:
   user input from the `get_user_input` function
- `ANSYS_tables::Dict{String, DataFrame}`:
   collection of tables which define an ANSYS material
"""
function transform_ASME_tables(
    ASME_tables::Dict{String, DataFrame},
    ASME_groups::Dict{String, String},
    user_input::NamedTuple
    )
    transform_ASME_tables(
        ASME_tables::Dict{String, DataFrame},
        ASME_groups::Dict{String, String};
        user_input..., # Splat user_input into keyword arguments.
    )
end

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
    find_proportional_limit(table::DataFrame) -> σ_p::Vector

Calulates the stress `σ_p` at the stress-strain proportional limit `ϵ_p`
for every temperature in the `table`.
"""
function find_proportional_limit(table::DataFrame)
    local numpoints = nrow(table) # Number of discrete temperature points.
    local σ_increment = 0.1 # Stress increment (resolution) for the while loop (psi).
    local σ_p = fill(0.0, numpoints) # Initialize output vector.
    for i in 1:numpoints
        local σ_ys = table.σ_ys[i]
        local σ_uts = table.σ_uts[i]
        local K = table.K[i]
        local m_1 = table.m_1[i]
        local m_2 = table.m_2[i]
        local A_1 = table.A_1[i]
        local A_2 = table.A_2[i]
        local ϵ_p = table.ϵ_p[i]
        local σ_t = 0.0
        local γ_total = 0.0
        while γ_total <= ϵ_p
            σ_t += σ_increment
            local H = KM620.H.(σ_t, σ_ys, σ_uts, K)
            local ϵ_1 = KM620.ϵ_1.(σ_t, A_1, m_1)
            local ϵ_2 = KM620.ϵ_2.(σ_t, A_2, m_2)
            local γ_1 = KM620.γ_1.(ϵ_1, H)
            local γ_2 = KM620.γ_2.(ϵ_2, H)
            γ_total = γ_1 + γ_2
        end
        σ_p[i] = σ_t - σ_increment
    end
    return σ_p
end
