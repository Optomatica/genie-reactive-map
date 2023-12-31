module Constants
using Dates, GenieFramework, PlotlyBase, DataFrames


const current_year = Dates.year(now())
const COLOR_SCALE_OPTIONS = ["Blackbody", "Bluered", "Blues", "Cividis", "Earth", "Electric", "Greens", "Greys", "Hot", "Jet", "Picnic", "Portland", "Rainbow", "RdBu", "Reds", "Viridis", "YlGnBu", "YlOrRd"]
const MAPBOX_STYLES = ["white-bg", "open-street-map", "carto-positron", "carto-darkmatter", "stamen-terrain", "stamen-toner", "stamen-watercolor", "basic", "streets", "outdoors", "light", "dark", "satellite", "satellite-streets"]


Base.@kwdef struct ScatterModel
  plot_data::R{Dict{Symbol,Any}} = Dict(:lat => [], :lon => [])
  marker::R{PlotlyBase.PlotlyAttribute} = attr(
    colorscale="Blues",
    showscale=false
  )
end

Base.@kwdef struct LayoutModel
  showlegend::Bool = true
  margin::PlotlyBase.PlotlyAttribute = attr(l=0, r=0, t=0, b=0)
  mapbox::R{PlotlyBase.PlotlyAttribute} = attr(style="open-street-map", zoom=1.7)
end


Base.@kwdef struct DataModel
  _input::R{DataTable} = DataTable()
  _pagination::R{DataTablePagination} = DataTablePagination(rows_per_page=50)
  _show_dialog::R{Bool} = false
end

struct SampleData
  label::String
  value::String
end
Base.@kwdef struct SampleDataModel
  show_sample_data_dialog::R{Bool} = false
  sample_data::Vector{SampleData} = map(r -> SampleData(r, joinpath("./data", r)), readdir("./data"))
  choosen_sample_data::R{Union{String,Nothing}} = nothing
  confirm_choose_sample_data::R{Bool} = false
  confirm_cancel_sample_data::R{Bool} = false
end




mutable struct ConfigType
  mapboxAccessToken::String
end
end
