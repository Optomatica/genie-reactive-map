module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
using TidierDates
include("./ui.jl")
@genietools

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


function myplot(args::Dict=Dict())
  scattermapbox(; args...)
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

@app begin
  @in left_drawer_open = true
  @in filter_range::RangeData{Int} = RangeData(0:current_year)
  @in selected_feature::Union{Nothing,String} = nothing
  @in color_scale = "Greens"
  @in animate = false

  @out color_scale_options = ["Blackbody", "Bluered", "Blues", "Cividis", "Earth", "Electric", "Greens", "Greys", "Hot", "Jet", "Picnic", "Portland", "Rainbow", "RdBu", "Reds", "Viridis", "YlGnBu", "YlOrRd"]
  @out input_data = DataFrame()
  @out min_year = 0
  @out max_year = current_year
  @out features::Array{String} = []
  @out data = DataFrame()
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
    mapFields()
    get_date_ranges(model.data[][!, :Date])
    features = names(model.data[])
    selected_feature = features[1]

    trace = [myplot(
      Dict(
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"],
      )
    )]
  end

  @onchange selected_feature, color_scale begin
    trace = [
      myplot(Dict(
        :marker => attr(
          size=map_values(data[!, selected_feature]),
          color=data[!, selected_feature],
          colorscale=color_scale
        ),
        :lon => data[!, "Longitude"],
        :lat => data[!, "Latitude"]
      ))
    ]
  end

  @onchange filter_range begin
    filtered_data = filter(i -> i.Date >= first(filter_range.range) && i.Date <= last(filter_range.range), data)
    trace = [
      myplot(Dict(
        :marker => attr(
          size=map_values(data[!, selected_feature]),
          color=data[!, selected_feature],
          colorscale=color_scale
        ),
        :lon => filtered_data[!, "Longitude"],
        :lat => filtered_data[!, "Latitude"]
      ))
    ]
  end

  @onchange animate begin
    if animate
      for i in model.min_year[]:model.max_year[]
        println(i, " ", model.min_year[], " ", model.max_year[])

        filter_range.range[] = model.min_year[]:i

        println(filter_range.range)
        sleep(0.1)
      end
    end
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
  return "Perfecto!"
end

end
