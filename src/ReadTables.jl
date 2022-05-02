# Read Tables
function readtable(filepath, sheetname)
    DataFrame(XLSX.readtable(filepath, sheetname, first_row = 2, infer_eltypes=true)...)
end
tableY = readtable(inputfilepath, "Table Y-1")
tableU = readtable(inputfilepath, "Table U")
tableTMkey = readtable(inputfilepath, "Table TM-1 - Key")
tablePRDkey = readtable(inputfilepath, "Table PRD - Key")
tableTEkey = readtable(inputfilepath, "Table TE-1 - Key")
tableTCDkey = readtable(inputfilepath, "Table TCD - Key")
tableTM = readtable(inputfilepath, "Table TM-1")
tablePRD = readtable(inputfilepath, "Table PRD")

# Find Chemical Composition
nomcomp = only(tableY[
                (tableY."Spec. No." .== specno) .&
                (tableY."Type/Grade" .== type_grade) .&
                (tableY."Class/Condition/Temper" .== class_condition_temper)
                , "Nominal Composition"])

# Find Groups
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
TMgroup = findgroup(tableTMkey, nomcomp)
PRDgroup = findgroup(tablePRDkey, nomcomp)
TEgroup = findgroup(tableTEkey, nomcomp)
TCDgroup = findgroup(tableTCDkey, nomcomp)

# Read Key-Dependent Tables
tableTE = readtable(inputfilepath, "Table TE-1 - " * TEgroup)
tableTCD = readtable(inputfilepath, "Table TCD - " * TCDgroup)
