module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
@genietools

global_data = DataFrame()

function myplot(color) 

  return scattermapbox(
    lon=global_data[!, "Longitude"],
    lat=global_data[!, "Latitude"],
    locations="iso_alpha",
    size="pop",
    mode="markers",
    marker=attr(
      size= (global_data[!,"Magnitude"] .^ 3) ./ 20,
      color= color,
      line=attr(color="rgb(255, 255, 255)", width=0.5)
    ),
  )
end

@app begin
  @in left_drawer_open = true
  @in selected_color = "rgb(51, 153, 255)"
  @out trace = [
    scattermapbox(
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
    mapbox=attr(
      style="open-street-map",
    ),
    geo=attr(
      showframe=false,
      showcoastlines=false,
      projection=attr(type="natural earth")
    ))

  @event uploaded begin
    trace = [
      scattermapbox(
        lon=global_data[!, "Longitude"],
        lat=global_data[!, "Latitude"],
        locations="iso_alpha",
        size="pop",
        mode="markers",
        marker=attr(
          size= (global_data[!,"Magnitude"] .^ 3) ./ 20,
          color="rgb(51, 153, 255)",
          line=attr(color="rgb(255, 255, 255)", width=0.5)
        ),
      )
    ]
  end

  @onchange selected_color begin
    trace = [
      myplot(selected_color)
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
