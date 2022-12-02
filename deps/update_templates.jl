using Pkg
Pkg.activate(@__DIR__)

using Downloads, ArtifactUtils, JSON3

dir = mkpath(joinpath(@__DIR__, "temp"))

#-----------------------------------------------------------------------------# Templates
# Need to install plotly.py in order to get themes because they are generated in python
run(`conda env remove -n _plotly_artifacts`) # start from scratch
run(`conda create -n _plotly_artifacts -y`)  # create env
run(`conda install -y plotly -n _plotly_artifacts`)

# get path of `_plotly_artifacts` env
io = IOBuffer()
# run(pipeline(`conda info --json`, stdout=io))
run(pipeline(`conda list -n _plotly_artifacts --json`; stdout=io))
pkgs = JSON3.read(String(take!(io)))
metadata = only(filter(x -> x.name == "plotly", pkgs))
template_dir = "/opt/homebrew/Caskroom/miniconda/base/pkgs/$(metadata.dist_name)/lib/python3.10/site-packages/plotly/package_data/templates/"
for file in readdir(template_dir)
    cp(joinpath(template_dir, file), joinpath(dir, file))
end

#-----------------------------------------------------------------------------# make artifact
id = artifact_from_directory(dir)
gist = upload_to_gist(id)
add_artifact!(joinpath(@__DIR__, "..", "Artifacts.toml"), "plotly-templates", gist)

#-----------------------------------------------------------------------------# cleanup
rm(dir, recursive=true)
