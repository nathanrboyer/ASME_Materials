"""
    table::DataFrame = readtable(filepath::String, sheetname::String)

Read table from given Excel file and sheet name.
"""
function readtable(filepath, sheetname)
    DataFrame(XLSX.readtable(filepath, sheetname, first_row = 2, infer_eltypes=true)...)
end

"""
    group::String = findgroup(df::DataFrame, value)

Find table group from key table.
"""
function findgroup(df, value)
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
    ASME_tables, ASME_groups = read_ASME_tables(filepath::String)

Make a dictionary of tables read from sheets in the input Excel file.
"""
function read_ASME_tables(filepath)
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

    # Find Chemical Composition
    nomcomp = only(tables["Y"][
                    (tables["Y"]."Spec. No." .== specno) .&
                    (tables["Y"]."Type/Grade" .== type_grade) .&
                    (tables["Y"]."Class/Condition/Temper" .== class_condition_temper)
                    , "Nominal Composition"])

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
