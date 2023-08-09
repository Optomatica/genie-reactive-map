module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
@genietools

global_data = DataFrame()

@app begin
  @in left_drawer_open = true
  @out trace = [
    scattergeo(
      lon=[],
      lat=[],
      locations="iso_alpha",
      size="pop",
      mode="markers",
      marker=attr(
        sizemode="area",
        sizemin=4,
        color="rgb(51, 153, 255)",
        line=attr(color="rgb(255, 255, 255)", width=0.5)
      ),
    )
  ]
  @out layout = PlotlyBase.Layout(
    title="World Map",
    showlegend=false,
    width="1800",
    geo=attr(
      showframe=false,
      showcoastlines=false,
      projection=attr(type="natural earth")
    ))

  @event uploaded begin
    trace = [
      scattergeo(
        lon=global_data[!, "Longitude"],
        lat=global_data[!, "Latitude"],
        locations="iso_alpha",
        size="pop",
        mode="markers",
        marker=attr(
          sizemode="area",
          sizemin=4,
          color="rgb(51, 153, 255)",
          line=attr(color="rgb(255, 255, 255)", width=0.5)
        ),
      )
    ]
  end

end




@page("/", "ui.jl")

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  global global_data = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
