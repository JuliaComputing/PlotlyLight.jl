using Documenter
using PlotlyLight

makedocs(
    sitename = "PlotlyLight",
    modules = [PlotlyLight],
    format = Documenter.HTML(
        assets = [asset(PlotlyLight.plotly.url)]
    ),
    pages = [
        "index.md",
        "templates.md"
    ]
)


deploydocs(
    repo = "https://github.com/JuliaComputing/PlotlyLight.jl"
)
