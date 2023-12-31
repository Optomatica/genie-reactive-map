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
  parsed_dates = []
  try
    parsed_dates = dmy.(dates)
  catch
    parsed_dates = mdy.(dates)
  end
  parsed_dates[isnothing.(parsed_dates)] = dates[isnothing.(parsed_dates)] .|> ymd
  parsed_dates .|> Dates.year
end

function map_fields(df::DataFrame)
  input_cols = names(df)
  latInd = findfirst(x -> occursin("lat", lowercase(x)), input_cols)
  lonInd = findfirst(x -> occursin(r"lon|lng", lowercase(x)), input_cols)
  dateInd = findfirst(x -> occursin("date", lowercase(x)), input_cols)


  dropmissing!(df, [latInd, lonInd])
  rename!(df, Symbol(input_cols[latInd]) => :Latitude, Symbol(input_cols[lonInd]) => :Longitude)

  if (!isnothing(dateInd))
    years = get_date_ranges(df[!, dateInd])
    df[!, :Date] = years
  else
    df[!, :Date] = repeat([Dates.year(Dates.now())], nrow(df))
  end
  df[!, :tooltip_text] = generate_tooltip_text(df)
  df
end

function generate_tooltip_text(df::DataFrame)
  col_names = filter(r -> r ∉ ["Date", "Longitude", "Latitude"], names(df))
  tooltip_text = []
  for (_, row) in enumerate(eachrow(df))
    push!(tooltip_text, join(["<b>$col</b>: $(row[col])<br>" for col in col_names]))
  end
  tooltip_text
end

end

