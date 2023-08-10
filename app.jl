module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
using TidierDates
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

function get_date_ranges(dates::Vector)
  parsed_dates = dmy.(dates)
  parsed_dates[isnothing.(parsed_dates)] = dates[isnothing.(parsed_dates)] .|> ymd
  years = parsed_dates .|> Dates.year
  model.data[][!, "years"] = years
  model.min_year[] = minimum(years)
  model.max_year[] = maximum(years)
end


function myplot(args::Dict=Dict())
  scattermapbox(; Dict(default_scatter_args..., args...)...)
end

function mapFields(df::DataFrame)

  latInd = findfirst(x -> occursin("lat", lowercase(x)), names(df))
  lonInd = findfirst(x -> occursin("lon", lowercase(x)), names(df))

  return DataFrame(
    Longitude=df[!, lonInd],
    Latitude=df[!, latInd],
    Magnitude=fill(3, size(df, 1))
  )
end

@app begin
  @in left_drawer_open = true
  @in filter_range::RangeData{Int} = RangeData(1:10)
  @in selected_color = "rgb(51, 153, 255)"

  @out input_data = DataFrame()
  @out min_year = 0
  @out max_year = Dates.year(now())
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
  @onchange input_data begin
    model.data[] = mapFields(input_data)
    trace = [myplot(
      Dict(
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"],
      )
    )]
  end

  @onchange selected_color begin
    model.data[] = mapFields(input_data)

    trace = [
      myplot(Dict(
        :marker => attr(
          # size=(data[!, "Magnitude"] .^ 3) ./ 20,
          color=selected_color,
          line=attr(color="rgb(255, 255, 255)", width=0.5)
        ),
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"]
      ))
    ]
  end



  @onchange filter_range begin
    filtered_data = filter(i -> i.years >= first(filter_range.range) && i.years <= last(filter_range.range), data)
    @show size(filtered_data)
    trace = [
      myplot(Dict(
        :marker => attr(
          size=(data[!, "Magnitude"] .^ 3) ./ 20,
          color=selected_color,
          line=attr(color="rgb(255, 255, 255)", width=0.5)
        ),
        :lon => filtered_data[!, "Longitude"],
        :lat => filtered_data[!, "Latitude"]
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
  model.input_data[] = CSV.read(f[2].data, DataFrame)
  get_date_ranges(model.data[][!, :Date])
  return "Perfecto!"
end

end
