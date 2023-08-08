module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
@genietools

global_data = DataFrame()


@app begin
  @in uploaded = false
  @out trace = []
  @out layout = PlotlyBase.Layout(
    title="World Map",
    showlegend=false,
    geo=attr(
      showframe=false,
      showcoastlines=false,
      projection=attr(type="natural earth")
    ))



  @onbutton uploaded begin
    data = global_data |> names
    trace = [
      scattergeo(
        # locationmode="ISO-3",
        lon=global_data[!, "Longitude"],
        lat=global_data[!, "Latitude"],
        # text=["London", "New York"],
        textposition="bottom right",
        textfont=attr(family="Arial Black", size=18, color="blue"),
        mode="markers+text",
        marker=attr(size=10, color="blue"),
        name="Cities")
    ]
  end

end




@page("/", "app.jl.html")

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  global global_data = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
