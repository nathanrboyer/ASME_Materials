"""
    readtable(filepath::String, sheetname::String) -> table::DataFrame

Read table from given Excel file and sheet name.
"""
function readtable(filepath::String, sheetname::String)
    DataFrame(XLSX.readtable(filepath, sheetname, first_row = 2, infer_eltypes=true))
end
export readtable

"""
    findgroup(df::DataFrame, value) -> group::String

Find table group from key table.
"""
function findgroup(df::DataFrame, value)
    for group in names(df)
        if value in skipmissing(df[:, group])
            return group
        end
    end
end
export findgroup

"""
    read_ASME_tables(user_input) -> ASME_tables, ASME_groups
    read_ASME_tables(filepath, material_dict) -> ASME_tables, ASME_groups
    read_ASME_tables(filepath, spec_no, type_grade, class_condition_temper) -> ASME_tables, ASME_groups

Create dictionaries containing all `ASME_tables` and `ASME_groups`
by reading an input Excel file and filtering it to a specific material.

The material specifications can be passed separately, inside `user_input`, or inside `material_dict`.
Returned table keys match the table names in Section II-D.

# Arguments
- `user_input::NamedTuple`: output from the `get_user_input` function
- `filepath::String`: location of the input Excel file "Section II-D Tables.xlsx"
- `material_dict::LittleDict{String,String}`: output from the `make_material_dict` function
- `spec_no::String`: material specification number from Section II-D
- `type_grade::String`: material type or grade from Section II-D
- `class_condition_temper::String`: material class, condition, or temper from Section II-D

# Returns
- `ASME_table::LittleDict{String,DataFrame}`:
    collection of tables for defining an ASME material from Section II-D

- `ASME_groups::LittleDict{String,String}`:
    collection of ASME material groupings which define which Section II-D tables to read

#Examples
```julia
julia> ASME_tables, ASME_groups = read_ASME_tables(
           "S:\\Material Properties\\Excel Material Data\\Section II-D Tables.xlsx",
           "SA-723",
           "3",
           "2",
       )

julia> ASME_tables
LittleDict{String, DataFrames.DataFrame, Vector{String}, Vector{DataFrames.DataFrame}} with 10 entries:
  "PRD"    => 13×3 DataFrame…
  "PRDkey" => 2×13 DataFrame…
  "TCD"    => 31×3 DataFrame…
  "TCDkey" => 2×12 DataFrame…
  "TE"     => 30×4 DataFrame…
  "TEkey"  => 3×4 DataFrame…
  "TM"     => 19×19 DataFrame…
  "TMkey"  => 3×19 DataFrame…
  "U"      => 12×20 DataFrame…
  "Y"      => 12×25 DataFrame…

julia> ASME_groups
LittleDict{String, String, Vector{String}, Vector{String}} with 4 entries:
  "PRD" => "Low alloy steels"
  "TCD" => "Group C"
  "TE"  => "Group 1"
  "TM"  => "Material Group B"
```
"""
function read_ASME_tables(filepath::String, material_dict::AbstractDict)

    # Read Independent Tables
    tables = LittleDict{String, DataFrame}()
    tables["Y"] = readtable(filepath, "Table Y-1")
    tables["U"] = readtable(filepath, "Table U")
    tables["TMkey"] = readtable(filepath, "Table TM-1 - Key")
    tables["PRDkey"] = readtable(filepath, "Table PRD - Key")
    tables["TEkey"] = readtable(filepath, "Table TE-1 - Key")
    tables["TCDkey"] = readtable(filepath, "Table TCD - Key")
    tables["TM"] = readtable(filepath, "Table TM-1")
    tables["PRD"] = readtable(filepath, "Table PRD")

    # Ensure Identifier Columns Contain Only Strings (Change Empty Identifier Cells to Underscores)
    function clean_identifiers(column)
        replace!(column, missing => "_")
        column = string.(column)
    end
    transform!(tables["Y"], "Type/Grade" => clean_identifiers, renamecols=false)
    transform!(tables["Y"], "Class/Condition/Temper" => clean_identifiers, renamecols=false)
    transform!(tables["U"], "Type/Grade" => clean_identifiers, renamecols=false)
    transform!(tables["U"], "Class/Condition/Temper" => clean_identifiers, renamecols=false)

    # Ensure All Dashes are Normal Hypens
    dash_to_hyphen(x) = eltype(x)<:AbstractString ? replace.(x, '–'=>'-', '—'=>'-') : x
    for df in values(tables)
        mapcols!(dash_to_hyphen, df)
    end

    # Find Chemical Composition
    grouped_table = groupby(tables["Y"], collect(keys(material_dict)))
    grouped_table_row = grouped_table[material_dict] |> only
    nomcomp = grouped_table_row."Nominal Composition"
    alloy = grouped_table_row."Alloy Desig./UNS No."
    groups = LittleDict{String, String}()
    if nomcomp == "Carbon steel"  # Carbon steel has two different groups in table TM, so must categorize by alloy designation instead.
        groups["TM"] = findgroup(tables["TMkey"], alloy)
    else
        groups["TM"] = findgroup(tables["TMkey"], nomcomp)
    end
    groups["PRD"] = findgroup(tables["PRDkey"], nomcomp)
    groups["TE"] = findgroup(tables["TEkey"], nomcomp)
    groups["TCD"] = findgroup(tables["TCDkey"], nomcomp)

    # Read Key-Dependent Tables
    tables["TE"] = readtable(filepath, "Table TE-1 - " * groups["TE"])
    tables["TCD"] = readtable(filepath, "Table TCD - " * groups["TCD"])

    return sort(tables), sort(groups)  # Change to `sort!` function if that becomes available in later versions
end
function read_ASME_tables(user_input::NamedTuple)
    filepath = user_input.input_file_path
    material_dict = user_input.material_dict
    read_ASME_tables(filepath, material_dict)
end
function read_ASME_tables(filepath, spec_no, type_grade, class_condition_temper)
    material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
    read_ASME_tables(filepath, material_dict)
end
export read_ASME_tables
