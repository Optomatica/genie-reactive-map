module App
using PlotlyBase
using GenieFramework
@genietools

@app begin
    @out trace = [
        scattergeo(
            locationmode="ISO-3",
            lon=[-0.12, -74],
            lat=[51.50, 40.71],
            text=["London", "New York"],
            textposition="bottom right",
            textfont=attr(family="Arial Black", size=18, color="blue"),
            mode="markers+text",
            marker=attr(size=10, color="blue"),
            name="Cities"),
        scattergeo(
            locationmode="ISO-3",
            lon=[-0.12, -74],
            lat=[51.50, 40.71],
            mode="lines",
            line=attr(width=2, color="red"),
            name="Route")
                 ]
    @out layout = PlotlyBase.Layout(
            title = "World Map",
            showlegend = false,
            geo = attr(
                showframe = false,
                showcoastlines = false,
                projection = attr(type = "natural earth")
            ))
    @in data_click = Dict{String, Any}()  # data from map click event
    @in data_cursor = Dict{String, Any}()

    @onchange data_click begin
        @show data_click
        @show data_cursor
    end
end

@mounted watchplots()

@page("/", "app.jl.html")
end
