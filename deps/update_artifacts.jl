using Pkg
Pkg.activate(@__DIR__)

using Downloads, ArtifactUtils, JSON3, Conda

dir = mkpath(joinpath(@__DIR__, "temp"))
include(joinpath(@__DIR__, "..", "src", "version.jl"))  # get `version`

#---------------------------------------------------------------------------# Artifact 1: plotly.js
url = "https://cdn.plot.ly/$version.min.js"
Downloads.download(url, joinpath(dir, basename(url)))

#---------------------------------------------------------------------------# Artifact 2: schema
url = "https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27"
Downloads.download(url, joinpath(dir, "plotly-schema.json"))

#---------------------------------------------------------------------------# Artifact 3: Templates
# Need to install plotly.py in order to get themes because they are generated in python
conda = Conda.CONDA_EXE
run(`$conda env remove -n _plotly_artifacts`) # start from scratch
run(`$conda create -n _plotly_artifacts -y`)  # create env
run(`$conda install -y plotly -n _plotly_artifacts`)

# get path of `_plotly_artifacts` env
io = IOBuffer()
run(pipeline(`conda list -n _plotly_artifacts --json`; stdout=io))
pkgs = JSON3.read(String(take!(io)))
metadata = only(filter(x -> x.name == "plotly", pkgs))
template_dir = "/opt/homebrew/Caskroom/miniconda/base/pkgs/$(metadata.dist_name)/lib/python3.10/site-packages/plotly/package_data/templates/"
mkdir(joinpath(dir, "templates"))
for file in readdir(template_dir)
    cp(joinpath(template_dir, file), joinpath(dir, "templates", file))
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
