using Pkg
Pkg.activate(@__DIR__)

using Downloads, Tar, ArtifactUtils, Artifacts, Dates

v = "2.8.3"

#-----------------------------------------------------------------------------# build artifacts
file = "plotly-$v.min.js"
url = "https://cdn.plot.ly/$file"
dir = mkpath(joinpath(@__DIR__, "artifacts"))
tar = joinpath(@__DIR__, "PlotlyLightArtifacts.tar")
rm(tar, force=true)
rm(tar * ".gz", force=true)
artifacts_today = "artifacts_$(today())"

Downloads.download(url, joinpath(dir, "plotly.min.js"))

run(`gzip $(Tar.create(dir, tar))`)

#-----------------------------------------------------------------------------# upload
try
    run(`gh release create $artifacts_today $tar.gz --title $artifacts_today --notes ""`)
catch
    @warn "Error (probably the release already exists).  Attempting to clobber artifact."
    run(`gh release upload $artifacts_today $tar.gz --clobber`)
end

#-----------------------------------------------------------------------------# update Artifacts.toml
@info "Sleeping so artifact is ready on GitHub..."
sleep(10)

add_artifact!(
    "Artifacts.toml",
    "plotly.min.js",
    "https://github.com/joshday/PlotlyLight.jl/releases/download/$artifacts_today/PlotlyLightArtifacts.tar.gz",
    force=true,
)
