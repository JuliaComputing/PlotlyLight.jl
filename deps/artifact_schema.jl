using Pkg
Pkg.activate(@__DIR__)

using Downloads, Tar, ArtifactUtils, JSON3


#-----------------------------------------------------------------------------# cleanup
dir = joinpath(@__DIR__, "temp")
rm(dir, force=true, recursive=true)
mkdir(dir)

#-----------------------------------------------------------------------------# download from CDN
url = "https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27"
file = Downloads.download(url, joinpath(dir, "schema.json"))
sha1 = open(io -> JSON3.read(io), file).sha1

#-----------------------------------------------------------------------------# tar it up
tar = Tar.create(dir, joinpath(@__DIR__, "schema_$sha1.tar") )
run(`gzip $tar`)

#-----------------------------------------------------------------------------# make GitHub release
name = "plotly_schema_$sha1"
run(`gh release create $name $(joinpath(@__DIR__, "$name.tar.gz")) --title $name --notes ""`)

#-----------------------------------------------------------------------------# create Artifacts.toml entry
@info "Sleeping so artifacts are ready on GitHub..."
sleep(5)
add_artifact!(
    "Artifacts.toml",
    name,
    "https://github.com/joshday/PlotlyLight.jl/releases/download/$name/$name.tar.gz",
    force=true,
)
