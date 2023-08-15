module Constants
using Dates, GenieFramework, PlotlyBase, DataFrames


const current_year = Dates.year(now())
const COLOR_SCALE_OPTIONS = ["Blackbody", "Bluered", "Blues", "Cividis", "Earth", "Electric", "Greens", "Greys", "Hot", "Jet", "Picnic", "Portland", "Rainbow", "RdBu", "Reds", "Viridis", "YlGnBu", "YlOrRd"]
const MAPBOX_STYLES = ["white-bg", "open-street-map", "carto-positron", "carto-darkmatter", "stamen-terrain", "stamen-toner", "stamen-watercolor", "basic", "streets", "outdoors", "light", "dark", "satellite", "satellite-streets"]


Base.@kwdef struct ScatterModel
  lat::R{Vector{Float64}} = []
  lon::R{Vector{Float64}} = []
  marker::R{PlotlyBase.PlotlyAttribute} = attr(
    size=[],
    color=[],
    colorscale="Greens"
  )
end

Base.@kwdef struct DataModel
  _input::R{DataFrame} = DataFrame()
  _processed::R{DataFrame} = DataFrame()
  _view::R{DataTable} = DataTable()
  _pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
  _show_dialog::R{Bool} = false
end

mutable struct ConfigType
  mapboxAccessToken::String
end
end
