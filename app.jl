module App
using PlotlyBase
using GenieFramework, GenieFramework.StipplePlotly
using DataFrames
using CSV
using TidierDates
include("./ui.jl")
@genietools


Base.@kwdef struct ScatterModel
  lat::R{Vector{Float64}} = []
  lon::R{Vector{Float64}} = []
  marker::R{PlotlyBase.PlotlyAttribute} = attr(
    size=[],
    color=[],
    colorscale="Greens"
  )
end



const min_radius = 4
const max_radius = 30
const current_year = Dates.year(now())

function get_date_ranges(dates::Vector)
  parsed_dates = dmy.(dates)
  parsed_dates[isnothing.(parsed_dates)] = dates[isnothing.(parsed_dates)] .|> ymd
  years = parsed_dates .|> Dates.year
  model.data[][!, "Date"] = years
  min_year, max_year = minimum(years), maximum(years)
  model.min_year[] = min_year
  model.max_year[] = max_year
  model.filter_range[].range = min_year:max_year
end

function map_values(x::Vector)
  min = minimum(x)
  max = maximum(x)
  return (x .- min) ./ (max - min) .* (max_radius - min_radius) .+ min_radius
end

function mapFields()

  input_cols = names(model.input_data[])
  df = model.input_data[]

  latInd = findfirst(x -> occursin("lat", lowercase(x)), input_cols)
  lonInd = findfirst(x -> occursin("lon", lowercase(x)), input_cols)
  dateInd = findfirst(x -> occursin("date", lowercase(x)), input_cols)
  new_data = copy(df)
  new_data[!, [:Latitude, :Longitude, :Date]] = df[:, [latInd, lonInd, dateInd]]
  model.data[] = new_data
end

@app Model begin
  @in left_drawer_open = true
  @in filter_range::RangeData{Int} = RangeData(0:current_year)
  @in selected_feature::Union{Nothing,String} = nothing
  @in color_scale = "Greens"
  @in animate = false

  @mixin ScatterModel

  @out color_scale_options = ["Blackbody", "Bluered", "Blues", "Cividis", "Earth", "Electric", "Greens", "Greys", "Hot", "Jet", "Picnic", "Portland", "Rainbow", "RdBu", "Reds", "Viridis", "YlGnBu", "YlOrRd"]
  @out input_data = DataFrame()
  @out min_year = 0
  @out max_year = current_year
  @out features::Array{String} = []
  @out data = DataFrame()
  @out trace = [scattermapbox()]
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
    mapFields()
    get_date_ranges(data[!, :Date])
    features = names(data)
    selected_feature = features[1]
    lon = data[!, "Longitude"]
    lat = data[!, "Latitude"]
  end

  @onchange selected_feature begin
    marker = attr(
      size=map_values(data[!, selected_feature]),
      color=data[!, selected_feature],
      colorscale="Greens"
    )
  end

  @onchange color_scale begin
    marker = attr(
      size=marker.size,
      color=marker.color,
      colorscale=color_scale
    )
  end

  @onchange filter_range begin
    filtered_data = filter(i -> i.Date >= first(filter_range.range) && i.Date <= last(filter_range.range), data)
    marker = attr(
      size=map_values(filtered_data[!, selected_feature]),
      color=filtered_data[!, selected_feature],
      colorscale=marker.colorscale
    )
    lon = filtered_data[!, "Longitude"],
    lat = filtered_data[!, "Latitude"]
  end

  @onchange lon, lat, marker begin
    trace = [
      scattermapbox(; lon=lon, lat=lat, marker=marker)]
  end

  @onchange animate begin
    if animate
      first_year = model.filter_range[].range[1]
      last_year = model.filter_range[].range[end]
      years_diff = last_year - first_year
      for i in first_year:(model.max_year[]-years_diff)
        model.filter_range[] = RangeData(i:i+years_diff)
        sleep(0.5)
      end
    end
  end

end


route("/") do
  global model = Model |> init |> handlers
  return page(model, ui())
end

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  model.input_data[] = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
