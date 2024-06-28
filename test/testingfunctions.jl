"""
    check_table(table, column, value)

Obtain table row where `column` matches `value`,
then print the name and value in each column.
If the cell contains a collection,
then print the first and last element.

# Arguments
- `table`: DataFrame to check
- `column`: column name as a String or Symbol
- `value`: cell value to look for in the `column` (any type)
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


"""
    compare_slopes(data::ASME_Materials_Data)

Create a plot showing the slopes of the first few plastic and total stress-strain segments.
"""
function compare_slopes(data::ASME_Materials_Data)
    σ = vcat(0, first(data.master_table.σ_t)[1:5])
    ϵ = vcat(0, first(data.master_table.ϵ_ts)[1:5])
    ϵp = vcat(0, first(data.master_table.γ_total)[1:5])
    E = diff(σ) ./ diff(ϵ)
    Ep = diff(σ) ./ diff(ϵp)

    fig = Figure()
    axis = Axis(fig[1,1],
                title = "Stress-Strain Curve of $(data.user_input.material_string)",
                xlabel = "ϵ (in/in)",
                ylabel = "σ (psi)")
    scatterlines!(ϵ, σ, label = "Elastic + Plastic")
    annotations!([@sprintf("E = %8.2e", i) for i in E], Point.(ϵ, σ .- 500)[begin+1:end])
    scatterlines!(ϵp, σ, label = "Plastic")
    annotations!([@sprintf("E = %8.2e", i) for i in Ep], Point.(ϵp, σ .- 500)[begin+1:end])
    Legend(fig[1,2], axis, "Strain Type")
    display(fig)
    return fig
end
