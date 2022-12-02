using Pkg
Pkg.activate(@__DIR__)

using Downloads, Tar, ArtifactUtils, Artifacts, Dates, JSON3

#-----------------------------------------------------------------------------# Start from scratch
function cleanup()
    rm(joinpath(@__DIR__, "plotly_artifacts.tar.gz"), force=true)
    rm(joinpath(@__DIR__, "plotly_artifacts"), force=true, recursive=true)
end

cleanup()

dir = mkpath(joinpath(@__DIR__, "plotly_artifacts"))

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

#-----------------------------------------------------------------------------# plotly.min.js
url = "https://cdn.plot.ly/plotly-2.16.1.min.js"
file = basename(url)
Downloads.download(url, joinpath(dir, file))

#-----------------------------------------------------------------------------# schema
schema_url = "https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27"
Downloads.download(schema_url, joinpath(dir, "schema.json"))

#-----------------------------------------------------------------------------# tar it up
run(`gzip $(Tar.create(dir, joinpath(@__DIR__, "plotly_artifacts.tar")))`)

#-----------------------------------------------------------------------------# upload
try
    artifacts_today = "artifacts_$(today())"

    run(`gh release create $artifacts_today $(joinpath(@__DIR__, "plotly_artifacts.tar.gz")) --title $artifacts_today --notes ""`)

    @info "Sleeping so artifacts are ready on GitHub..."
    sleep(10)
    add_artifact!(
        "Artifacts.toml",
        "plotlylight",
        "https://github.com/joshday/PlotlyLight.jl/releases/download/$artifacts_today/plotly_artifacts.tar.gz",
        force=true,
    )
catch ex
    @error "Error (probably the release already exists): $ex"
end


cleanup()
