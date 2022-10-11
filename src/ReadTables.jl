"""
    table::DataFrame = readtable(filepath::String, sheetname::String)

Read table from given Excel file and sheet name.
"""
function readtable(filepath::String, sheetname::String)
    DataFrame(XLSX.readtable(filepath, sheetname, first_row = 2, infer_eltypes=true))
end

"""
    group::String = findgroup(df::DataFrame, value)

Find table group from key table.
"""
function findgroup(df::DataFrame, value)
    for group in names(df)
        if first(df[:, group]) === missing
            continue
        end
        if value in df[:, group]
            return group
        end
    end
end

"""
    ASME_tables, ASME_groups = read_ASME_tables(filepath::String, material_dict::Dict)

Make a dictionary of tables and groups read from sheets in the input Excel file located at `filepath`
using `material_dict` to filter the resulting DataFrame to the selected material.
"""
function read_ASME_tables(filepath::String, material_dict::Dict)

    # Read Independent Tables
    tables = Dict{String, DataFrame}()
    tables["Y"] = readtable(filepath, "Table Y-1")
    tables["U"] = readtable(filepath, "Table U")
    tables["TMkey"] = readtable(filepath, "Table TM-1 - Key")
    tables["PRDkey"] = readtable(filepath, "Table PRD - Key")
    tables["TEkey"] = readtable(filepath, "Table TE-1 - Key")
    tables["TCDkey"] = readtable(filepath, "Table TCD - Key")
    tables["TM"] = readtable(filepath, "Table TM-1")
    tables["PRD"] = readtable(filepath, "Table PRD")

    # Ensure Identifier Columns Contain Only Strings
    transform!(tables["Y"], "Type/Grade" => ByRow(string), renamecols=false)
    transform!(tables["Y"], "Class/Condition/Temper" => ByRow(string), renamecols=false)
    transform!(tables["U"], "Type/Grade" => ByRow(string), renamecols=false)
    transform!(tables["U"], "Class/Condition/Temper" => ByRow(string), renamecols=false)

    # Find Chemical Composition
    nomcomp = subset(tables["Y"], material_dict...)."Nominal Composition" |> only
    groups = Dict{String, String}()
    groups["TM"] = findgroup(tables["TMkey"], nomcomp)
    groups["PRD"] = findgroup(tables["PRDkey"], nomcomp)
    groups["TE"] = findgroup(tables["TEkey"], nomcomp)
    groups["TCD"] = findgroup(tables["TCDkey"], nomcomp)

    # Read Key-Dependent Tables
    tables["TE"] = readtable(filepath, "Table TE-1 - " * groups["TE"])
    tables["TCD"] = readtable(filepath, "Table TCD - " * groups["TCD"])

    return tables, groups
end

"""
    ASME_tables, ASME_groups = read_ASME_tables(user_input::NamedTuple)

Make a dictionary of tables and groups read from the `user_input` information.
Fieldnames `input_file_path` and `material_dict` are required to be in `user_input`.
"""
function read_ASME_tables(user_input::NamedTuple)
    filepath = user_input.input_file_path
    material_dict = user_input.material_dict
    read_ASME_tables(filepath::String, material_dict::Dict)
end

"""
    ASME_tables, ASME_groups = read_ASME_tables(filepath, spec_no, type_grade, class_condition_temper)

Make a dictionary of tables and groups read from from sheets in the input Excel file located at `filepath`.
`spec_no`, `type_grade`, and `class_condition_temper` define the material information to retrieve from the file.
"""
function read_ASME_tables(filepath, spec_no, type_grade, class_condition_temper)
    material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
    read_ASME_tables(filepath::String, material_dict::Dict)
end

"""
    ASME_tables, ASME_groups = read_ASME_tables(; filepath, spec_no, type_grade, class_condition_temper, _...)

Make a dictionary of tables and groups read from from sheets in the input Excel file located at `filepath`.
`spec_no`, `type_grade`, and `class_condition_temper` define the material information to retrieve from the file.
"""
function read_ASME_tables(; input_file_path, spec_no, type_grade, class_condition_temper, _...)
    filepath = input_file_path
    material_dict = make_material_dict(spec_no, type_grade, class_condition_temper)
    read_ASME_tables(filepath::String, material_dict::Dict)
end