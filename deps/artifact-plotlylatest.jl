using Pkg
Pkg.activate(@__DIR__)

using Downloads, Tar, ArtifactUtils

#-----------------------------------------------------------------------------# change this
plotly_version = "2.16.1"

#-----------------------------------------------------------------------------# cleanup
dir = joinpath(@__DIR__, "temp")
rm(dir, force=true, recursive=true)
mkdir(dir)

#-----------------------------------------------------------------------------# download from CDN
plotly = "plotly-$plotly_version"
url = "https://cdn.plot.ly/$plotly.min.js"
file = Downloads.download(url, joinpath(dir, basename(url)))

#-----------------------------------------------------------------------------# tar it up
tar = Tar.create(dir, joinpath(@__DIR__, "$plotly.tar") )
run(`gzip $tar`)

#-----------------------------------------------------------------------------# make GitHub release
run(`gh release create $plotly $(joinpath(@__DIR__, "$plotly.tar.gz")) --title $plotly --notes ""`)

#-----------------------------------------------------------------------------# create Artifacts.toml entry
@info "Sleeping so artifacts are ready on GitHub..."
sleep(5)
add_artifact!(
    joinpath(@__DIR__, "..", "Artifacts.toml"),
    plotly,
    "https://github.com/joshday/PlotlyLight.jl/releases/download/$plotly/$plotly.tar.gz",
    force=true,
)
