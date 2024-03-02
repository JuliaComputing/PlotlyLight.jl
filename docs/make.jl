using Documenter
using PlotlyLight

makedocs(
    sitename = "PlotlyLight",
    format = Documenter.HTML(),
    modules = [PlotlyLight]
)


deploydocs(
    repo = "https://github.com/juliacomputing/plotlylight.jl"
)
