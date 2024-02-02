using Pkg
Pkg.activate(@__DIR__)

using ArtifactUtils, JSON3

version = JSON3.read(download("https://api.github.com/repos/plotly/plotly.js/releases/latest")).name


#-----------------------------------------------------------------------------# get urls
plotly_url = "https://github.com/plotly/plotly.js/raw/$version/dist/plotly.min.js"

schema_url = "https://github.com/plotly/plotly.js/raw/$version/dist/plot-schema.json"

template_urls = Dict(
    t => "https://raw.githubusercontent.com/plotly/plotly.py/master/packages/python/plotly/plotly/package_data/templates/$t.json" for t in
        (:ggplot2, :gridon, :plotly, :plotly_dark, :plotly_white, :presentation, :seaborn, :simple_white, :xgridoff, :ygridoff)
)

#-----------------------------------------------------------------------------# make tempdir
dir = mktempdir()
mkdir(joinpath(dir, "templates"))

#-----------------------------------------------------------------------------# download
open(io -> println(io, version), joinpath(dir, "version.txt"), "w")
download(plotly_url, joinpath(dir, "plotly.min.js"))
download(schema_url, joinpath(dir, "plot-schema.json"))
for (k,v) in template_urls
    download(v, joinpath(dir, "templates", "$k.json"))
end

#-----------------------------------------------------------------------------# make artifact
artifact_id = artifact_from_directory(dir)
gist = upload_to_gist(artifact_id)
add_artifact!("Artifacts.toml", "plotly_artifacts", gist; force=true)
