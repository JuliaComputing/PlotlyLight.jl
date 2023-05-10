using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Downloads, ArtifactUtils, JSON3

dir = mkdir(joinpath(@__DIR__, "temp"))

include(joinpath(@__DIR__, "..", "src", "version.jl"))  # get `version`

#---------------------------------------------------------------------------# Artifact 1: plotly.js
url = "https://cdn.plot.ly/$version.min.js"
Downloads.download(url, joinpath(dir, basename(url)))

#---------------------------------------------------------------------------# Artifact 2: schema
Downloads.download("https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27", joinpath(dir, "plotly-schema.json"))

#---------------------------------------------------------------------------# Artifact 3: Templates
mkdir(joinpath(dir, "templates"))

for temp = ["ggplot2", "gridon", "plotly", "plotly_dark", "plotly_white", "presentation", "seaborn", "simple_white", "xgridoff", "ygridoff"]
    local url = "https://raw.githubusercontent.com/plotly/plotly.py/master/packages/python/plotly/plotly/package_data/templates/$temp.json"
    Downloads.download(url, joinpath(dir, "templates", "$temp.json"))
end

#-----------------------------------------------------------------------------# make artifact
id = artifact_from_directory(dir)
gist = upload_to_gist(id)
add_artifact!(joinpath(@__DIR__, "..", "Artifacts.toml"), "PlotlyLight", gist; force=true)

#-----------------------------------------------------------------------------# cleanup
rm(dir, recursive=true)

#-----------------------------------------------------------------------------# instantiate local
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()
