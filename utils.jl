module Utils
using TidierDates
using DataFrames

const min_radius = 4
const max_radius = 30

function scale_array(x::Vector{<:Number})
  min = minimum(x)
  max = maximum(x)
  (x .- min) ./ (max - min) .* (max_radius - min_radius) .+ min_radius
end

function get_date_ranges(dates::Vector)
  parsed_dates = dmy.(dates)
  parsed_dates[isnothing.(parsed_dates)] = dates[isnothing.(parsed_dates)] .|> ymd
  parsed_dates .|> Dates.year
end

function map_fields(df::DataFrame)
  input_cols = names(df)
  latInd = findfirst(x -> occursin("lat", lowercase(x)), input_cols)
  lonInd = findfirst(x -> occursin("lon", lowercase(x)), input_cols)
  dateInd = findfirst(x -> occursin("date", lowercase(x)), input_cols)
  years = get_date_ranges(df[!, dateInd])
  new_data = copy(df)
  new_data[!, [:Latitude, :Longitude, :Date]] = df[:, [latInd, lonInd, dateInd]]
  new_data[!, :Date] = years
  new_data
end

end
