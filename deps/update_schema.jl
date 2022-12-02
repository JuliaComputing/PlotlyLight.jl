using Pkg
Pkg.activate(@__DIR__)

using Downloads, ArtifactUtils

dir = mkpath(joinpath(@__DIR__, "temp"))

#-----------------------------------------------------------------------------# download
url = "https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27"
file = Downloads.download(url, touch(joinpath(dir, "plotly-schema.json")))

#-----------------------------------------------------------------------------# make artifact
id = artifact_from_directory(dir)
gist = upload_to_gist(id)
add_artifact!(joinpath(@__DIR__, "..", "Artifacts.toml"), "plotly-schema", gist)

#-----------------------------------------------------------------------------# cleanup
rm(dir, recursive=true)
