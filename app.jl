module App
using PlotlyBase
using GenieFramework
using DataFrames
using CSV
include("./ui.jl")
include("./constants.jl")
include("./utils.jl")
using .Constants: current_year, ScatterModel, LayoutModel, COLOR_SCALE_OPTIONS, ConfigType, MAPBOX_STYLES, DataModel, SampleDataModel, FeatureModel
using .Utils: scale_array, map_fields
@genietools

@app Model begin
  @in left_drawer_open = true
  @in year_range::RangeData{Int} = RangeData(0:current_year)
  @in tab_m::R{String} = "styles"
  @in color_scale = "Greens"
  @in animate = false
  @in mapbox_style = "open-street-map"

  @mixin data::DataModel
  @mixin ScatterModel
  @mixin LayoutModel
  @mixin SampleDataModel
  @mixin FeatureModel

  @out color_scale_options = COLOR_SCALE_OPTIONS
  @out mapbox_styles = MAPBOX_STYLES
  @out min_year = 0
  @out max_year = current_year
  @out trace = [scattermapbox()]
  @out layout = PlotlyBase.Layout(margin=attr(l=0, r=0, t=0, b=0), mapbox=attr(style="open-street-map", zoom=1.7))
  @out config = ConfigType(
    "***REMOVED***"
  )

  @onchange data_input begin
    selected_size_feature = nothing
    selected_color_feature = nothing
    data_processed = data_input.data

    df_without_basics = data_processed[!, filter(r -> r ∉ ["Date", "Longitude", "Latitude", "tooltip_text"], names(data_processed))]
    features = names(df_without_basics)
    numerical_indicies = df_without_basics |> eachcol .|> eltype .<: Number
    scalar_features = features[findall(numerical_indicies)]
    categorical_features = features[findall(.!numerical_indicies)]


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
    year_range = RangeData(min_year:max_year)
  end

  @onchange color_scale begin
    marker = attr(
      size=marker.size,
      color=marker.color,
      colorscale=color_scale,
      showscale=true
    )
  end

  @onchange year_range begin
    data_processed = data_input.data
    filtered_data = filter_data(data_processed)

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
        showscale=true
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
      first_year = year_range.range[1] + 1
      last_year = year_range.range[end] + 1
      years_diff = last_year - first_year

      if last_year > max_year
        first_year = min_year
        last_year = min_year + years_diff
      end

      model.year_range[] = RangeData(first_year:last_year)
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

  @onchange selected_filter_feature begin
    if (!isnothing(selected_filter_feature))
      if (selected_filter_feature in categorical_features)
        filter_values = unique(data_input.data[!, selected_filter_feature])
      else
        df = data_input.data[!, [selected_filter_feature]] |> dropmissing
        min_range_value = minimum(df[!, selected_filter_feature])
        max_range_value = maximum(df[!, selected_filter_feature])
        filter_range = RangeData{Float64}(min_range_value:max_range_value)
      end
    end
  end

  @onchange selected_filter_value begin
    if (!isnothing(selected_filter_value))
      data_processed = data_input.data


      filtered_data = filter_data(data_processed)

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
          showscale=true
        )
      end
    end
  end

  @onchange filter_range begin
    data_processed = data_input.data
    filtered_data = filter_data(data_processed)

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
        showscale=true
      )
    end
  end
end

function filter_data(data::DataFrame)
  year_range = model.year_range[]
  selected_filter_feature = model.selected_filter_feature[]
  selected_filter_value = model.selected_filter_value[]
  # filter_range = model.filter_range[]
  filter(i ->
      i.Date >= first(year_range.range) && i.Date <= last(year_range.range) &&
        isnothing(selected_filter_value) ? true : i[selected_filter_feature] === selected_filter_value,
    # (isnothing(filter_range) ? true : i -> i[selected_filter_feature] >= first(filter_range.range) && i[selected_filter_feature] <= last(filter_range.range)),
    data)
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
