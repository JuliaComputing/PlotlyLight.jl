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
        "plotly_basics.md",
        "templates.md",
        "saving.md",
        "source.md",
        "settings.md",
    ]
)


deploydocs(
    repo = "https://github.com/JuliaComputing/PlotlyLight.jl"
)
