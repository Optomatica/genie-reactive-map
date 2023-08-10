module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
include("./ui.jl")
@genietools

default_scatter_args = Dict(
  :locations => "iso_alpha",
  :size => "pop",
  :mode => "markers",
  :marker => attr(
    color="rgb(51, 153, 255)",
    line=attr(color="rgb(255, 255, 255)", width=0.5)
  ),
)


function myplot(args::Dict=Dict())

  scattermapbox(; Dict(default_scatter_args..., args...)...)
end

@app begin
  @in left_drawer_open = true
  @in current_year = 2023
  @in selected_color = "rgb(51, 153, 255)"

  @out data = DataFrame(Longitude=[], Latitude=[], Magnitude=[])
  @out trace = [myplot()]
  @out layout = PlotlyBase.Layout(
    title="World Map",
    showlegend=false,
    width="1800",
    mapbox=attr(
      style="open-street-map",
    ),
    geo=attr(
      showframe=false,
      showcoastlines=false,
      projection=attr(type="natural earth")
    ))
  @onchange data begin
    trace = [myplot(
      Dict(
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"],
      )
    )]
  end

  @onchange selected_color begin
    trace = [
      myplot(Dict(
        :marker => attr(
          size=(data[!, "Magnitude"] .^ 3) ./ 20,
          color=selected_color,
          line=attr(color="rgb(255, 255, 255)", width=0.5)
        ),
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"]
      ))
    ]
  end

end


route("/") do
  global model = @init
  return page(model, ui())
end

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  model.data[] = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
