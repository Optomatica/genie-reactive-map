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
  @in selected_size_feature::Union{Nothing,String} = nothing
  @in selected_color_feature::Union{Nothing,String} = nothing
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
  @out layout = PlotlyBase.Layout(margin=attr(l=0, r=0, t=0, b=0), mapbox=attr(style="open-street-map", zoom=1.7))
  @out config = ConfigType(
    ENV["MAPBOX_KEY"]
  )

  @onchange data_input begin
    selected_size_feature = nothing
    selected_color_feature = nothing
    data_processed = data_input.data

    scalar_features = findall(data_processed |> eachcol .|> eltype .<: Number)
    features = filter(r -> r ∉ ["Date", "Longitude", "Latitude"], names(data_processed)[scalar_features])

    min_year = minimum(data_processed[!, "Date"])
    max_year = maximum(data_processed[!, "Date"])

    plot_data = Dict(:lat => data_processed[!, "Latitude"], :lon => data_processed[!, "Longitude"], :text => data_processed[!, "tooltip_text"])

  end

  @onchange selected_color_feature begin
    data_processed = data_input.data
    if (!isnothing(selected_color_feature))
      marker = attr(
        size=marker.size,
        color=data_processed[!, selected_color_feature],
        colorscale=marker.colorscale,
        showscale=true
      )

    else
      marker = attr(
        size=marker.size,
        showscale=false
      )
    end

  end

  @onchange selected_size_feature begin
    data_processed = data_input.data
    if (!isnothing(selected_size_feature))
      marker = attr(
        size=scale_array(data_processed[!, selected_size_feature]),
        color=marker.color,
        colorscale=marker.colorscale,
        showscale=marker.showscale
      )

    else
      marker = attr(
        color=marker.color,
        colorscale=marker.colorscale,
        showscale=marker.showscale
      )
    end

  end

  @onchange min_year, max_year begin
    filter_range = RangeData(min_year:max_year)
  end

  @onchange color_scale begin
    marker = attr(
      size=marker.size,
      color=marker.color,
      colorscale=color_scale,
      showscale=true
    )
  end

  @onchange filter_range begin
    data_processed = data_input.data
    filtered_data = filter(i -> i.Date >= first(filter_range.range) && i.Date <= last(filter_range.range), data_processed)
    plot_data = Dict(:lat => filtered_data[!, "Latitude"], :lon => filtered_data[!, "Longitude"], :text => filtered_data[!, "tooltip_text"])
    if (!isnothing(selected_size_feature))
      marker = attr(
        size=scale_array(filtered_data[!, selected_size_feature]),
        color=marker.color,
        colorscale=marker.colorscale
      )
    end

    if (!isnothing(selected_color_feature))
      marker = attr(
        size=marker.size,
        color=filtered_data[!, selected_color_feature],
        colorscale=marker.colorscale,
        showscale=false
      )
    end
  end

  @onchange plot_data, marker begin
    trace = [scattermapbox(
      plot_data;
      marker=marker
    )]
  end

  @onchange mapbox begin
    layout = PlotlyBase.Layout(
      showlegend=showlegend,
      margin=margin,
      mapbox=mapbox
    )
  end

  @onchange animate begin
    function cb(_)
      first_year = filter_range.range[1] + 1
      last_year = filter_range.range[end] + 1
      years_diff = last_year - first_year

      if last_year > max_year
        first_year = min_year
        last_year = min_year + years_diff
      end

      model.filter_range[] = RangeData(first_year:last_year)
    end

    if animate

      global t = Timer(cb, 0, interval=0.4)
      wait(t)
    else
      close(t)
    end
  end

  @onchange mapbox_style begin
    mapbox = attr(
      style=mapbox_style,
      zoom=mapbox.zoom
    )
  end

  @onbutton confirm_choose_sample_data begin
    show_sample_data_dialog = false
    df = CSV.read(choosen_sample_data, DataFrame) |> map_fields
    model.data_input[] = DataTable(df, DataTableOptions(columns=map(col -> Column(col), names(df))))
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
  df = CSV.read(f[2].data, DataFrame) |> map_fields
  model.data_input[] = DataTable(df, DataTableOptions(columns=map(col -> Column(col), names(df))))
  return "Perfecto!"
end

end
