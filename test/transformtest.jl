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

check_table(ANSYS_tables["Stress-Strain"], "T", 200)