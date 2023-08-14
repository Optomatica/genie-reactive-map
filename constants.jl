module Constants
using Dates, GenieFramework.Stipple, PlotlyBase


const current_year = Dates.year(now())
const COLOR_SCALE_OPTIONS = ["Blackbody", "Bluered", "Blues", "Cividis", "Earth", "Electric", "Greens", "Greys", "Hot", "Jet", "Picnic", "Portland", "Rainbow", "RdBu", "Reds", "Viridis", "YlGnBu", "YlOrRd"]


Base.@kwdef struct ScatterModel
  lat::R{Vector{Float64}} = []
  lon::R{Vector{Float64}} = []
  marker::R{PlotlyBase.PlotlyAttribute} = attr(
    size=[],
    color=[],
    colorscale="Greens"
  )
end

end
