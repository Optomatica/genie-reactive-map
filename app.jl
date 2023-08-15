module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
include("./ui.jl")
include("./constants.jl")
include("./utils.jl")
using .Constants: current_year, ScatterModel, LayoutModel, COLOR_SCALE_OPTIONS, ConfigType, MAPBOX_STYLES, DataModel, SampleDataModel
using .Utils: scale_array, map_fields
@genietools

@app Model begin
  @in left_drawer_open = true
  @in filter_range::RangeData{Int} = RangeData(0:current_year)
  @in selected_feature::Union{Nothing,String} = nothing
  @in color_scale = "Greens"
  @in animate = false
  @in mapbox_style = "open-street-map"

  @mixin data::DataModel
  @mixin ScatterModel
  @mixin LayoutModel
  @mixin SampleDataModel

  @out color_scale_options = COLOR_SCALE_OPTIONS
  @out mapbox_styles = MAPBOX_STYLES
  @out min_year = 0
  @out max_year = current_year
  @out features::Array{String} = []
  @out trace = [scattermapbox()]
  @out layout = PlotlyBase.Layout(margin=attr(l=0, r=0, t=0, b=0))
  @out config = ConfigType(
    "***REMOVED***"
  )

  @onchange data_input begin
    data_processed = map_fields(data_input)
    data_view = DataTable(DataFrame(data_input), DataTableOptions(columns=map(col -> Column(col), names(data_input))))
  end

  @onchange data_processed begin
    features = names(data_processed)
    scalar_features = findall(data_processed |> eachcol .|> eltype .<: Number)
    selected_feature = features[scalar_features[1]]

    min_year = minimum(data_processed[!, "Date"])
    max_year = maximum(data_processed[!, "Date"])

    lon = data_processed[!, "Longitude"]
    lat = data_processed[!, "Latitude"]

    marker = attr(
      size=scale_array(data_processed[!, selected_feature]),
      color=data_processed[!, selected_feature],
      colorscale=marker.colorscale
    )
  end

  @onchange selected_feature begin
    marker = attr(
      size=scale_array(data_processed[!, selected_feature]),
      color=data_processed[!, selected_feature],
      colorscale=marker.colorscale
    )
  end

  @onchange min_year, max_year begin
    filter_range = RangeData(min_year:max_year)
  end

  @onchange color_scale begin
    marker = attr(
      size=marker.size,
      color=marker.color,
      colorscale=color_scale
    )
  end

  @onchange filter_range begin
    filtered_data = filter(i -> i.Date >= first(filter_range.range) && i.Date <= last(filter_range.range), data_processed)
    marker = attr(
      size=scale_array(filtered_data[!, selected_feature]),
      color=filtered_data[!, selected_feature],
      colorscale=marker.colorscale
    )
  end

  @onchange lon, lat, marker begin
    trace = [scattermapbox(
      lat=lat,
      lon=lon,
      marker=marker
    )]
  end

  @onchange mapbox begin
    layout = PlotlyBase.Layout(
      showlegend=showlegend,
      margin=margin,
      mapbox=mapbox,
      geo=geo
    )
  end

  @onchange animate begin

    if animate

      function cb(_)
        first_year = model.filter_range[].range[1] + 1
        last_year = model.filter_range[].range[end] + 1
        years_diff = last_year - first_year

        if last_year > model.max_year[]
          first_year = model.min_year[]
          last_year = model.min_year[] + years_diff
        end

        model.filter_range[] = RangeData(first_year:last_year)
      end

      global t = Timer(cb, 0.1, interval=0.5)
      wait(t)
    else
      close(t)
    end
  end

  @onchange mapbox_style begin
    mapbox = attr(
      style=mapbox_style
    )
  end

  @onbutton confirm_choose_sample_data begin
    show_sample_data_dialog = false
    model.data_input[] = CSV.read(choosen_sample_data, DataFrame)
  end

  @onbutton confirm_cancel_sample_data begin
    show_sample_data_dialog = false
  end
end


route("/") do
  global model = Model |> init |> handlers
  return page(model, ui())
end

route("/", method=POST) do
  files = Genie.Requests.filespayload()
  f = first(files)
  model.data_input[] = CSV.read(f[2].data, DataFrame)
  return "Perfecto!"
end

end
