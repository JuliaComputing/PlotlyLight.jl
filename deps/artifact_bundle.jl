using Pkg
Pkg.activate(@__DIR__)

using Downloads, Tar, ArtifactUtils, Artifacts, Dates, Pkg

#-----------------------------------------------------------------------------# Start from scratch
for file in readdir(@__DIR__)
    if endswith(file, ".tar") || endswith(file, ".gz")
        rm(joinpath(@__DIR__, file), force=true)
    end
end

#-----------------------------------------------------------------------------# Templates
# Need to install plotly.py in order to get themes because they are generated in python
# run(`conda create -n conda_jl python conda`)
# ENV["CONDA_JL_HOME"] = "/opt/homebrew/Caskroom/miniconda/base/envs/conda_jl"
# Pkg.build("Conda")
# using Conda
# Conda.add("plotly")

dir = "/opt/homebrew/Caskroom/miniconda/base/envs/conda_jl/pkgs"
templates = joinpath(dir, filter(x -> startswith(x, "plotly"), readdir(dir))[1], "site-packages/plotly/package_data/templates")


run(`gzip $(Tar.create(templates, joinpath(@__DIR__, "templates.tar")))`)


#-----------------------------------------------------------------------------# Plotly.js
url = "https://cdn.plot.ly/plotly-2.11.0.min.js"
file = basename(url)
dir = mkpath(joinpath(@__DIR__, "plotlyjs"))
Downloads.download(url, joinpath(dir, file))

run(`gzip $(Tar.create(dir, joinpath(@__DIR__, "plotly.tar")))`)

#-----------------------------------------------------------------------------# upload
try
    artifacts_today = "artifacts_$(today())"

    run(`gh release create $artifacts_today $(joinpath(@__DIR__, "templates.tar.gz")) $(joinpath(@__DIR__, "plotly.tar.gz")) --title $artifacts_today --notes ""`)

    @info "Sleeping so artifacts are ready on GitHub..."
    sleep(10)
    add_artifact!(
        "Artifacts.toml",
        "plotly.min.js",
        "https://github.com/joshday/PlotlyLight.jl/releases/download/$artifacts_today/plotly.tar.gz",
        force=true,
    )
    add_artifact!(
        "Artifacts.toml",
        "plotly_templates",
        "https://github.com/joshday/PlotlyLight.jl/releases/download/$artifacts_today/templates.tar.gz",
        force=true,
    )
catch ex
    @error "Error (probably the release already exists): $ex"
end
