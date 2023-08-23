# Genie Reactive Map
## Description
This is a simple app that visualizes geographical data build on the top of GenieFramework, PlotlyBase, DataFrames, and mapbox.

## How to run
Inside your terminal, run the following commands:
```console
> git clone --depth 1 https://github.com/Optomatica/genie-reactive-map.git
> cd genie-reactive-map
> julia --project

```
Julia REPL should be opened now. Run the following commands:
```julia
> using Pkg; Pkg.instantiate()
> using GenieFramework
> Genie.loadapp()
> up()

```
After that the app should be running on http://127.0.0.1:8000
## FAQ
### Are there sample data files?
Yes, you can find them by clicking on `Show sample data`.
### What's the supported file format?
CSV file with the following columns:
1. Latitude (Required)
2. Longitude (Required)
3. Date (Optional)
4. Any other numerical column could be used as marker size & color (Optional)
### Satellite view is not working.
For satellite view you need to get a [free mapbox token](https://plotly.com/javascript/mapbox-layers/). After having the token you can replace `your token` with the real token in `app.jl`.
