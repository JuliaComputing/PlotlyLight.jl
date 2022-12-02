using Pkg
Pkg.activate(@__DIR__)

using Downloads, ArtifactUtils

dir = mkpath(joinpath(@__DIR__, "temp"))

#-----------------------------------------------------------------------------# change this to update
plotly_version = "2.16.1"

plotly = "plotly-$plotly_version"
url = "https://cdn.plot.ly/$plotly.min.js"
file = Downloads.download(url, joinpath(dir, basename(url)))


#-----------------------------------------------------------------------------# make artifact
id = artifact_from_directory(dir)
gist = upload_to_gist(id)
add_artifact!(joinpath(@__DIR__, "..", "Artifacts.toml"), plotly, gist)

#-----------------------------------------------------------------------------# cleanup
rm(dir, recursive=true)
