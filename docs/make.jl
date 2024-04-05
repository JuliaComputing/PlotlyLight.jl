using Documenter
using PlotlyLight

PlotlyLight.settings.use_iframe = true
PlotlyLight.settings.div.style = "max-width: 52rem;"

makedocs(
    sitename = "PlotlyLight",
    modules = [PlotlyLight],
    format = Documenter.HTML(
        assets = [asset(PlotlyLight.plotly.url)]
    )
)


deploydocs(
    repo = "https://github.com/juliacomputing/plotlylight.jl"
)
