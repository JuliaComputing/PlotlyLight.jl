using Documenter, PlotlyLight

makedocs(;
    modules=[PlotlyLight],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/joshday/PlotlyLight.jl/blob/{commit}{path}#L{line}",
    sitename="PlotlyLight.jl",
    authors="joshday <emailjoshday@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/joshday/PlotlyLight.jl",
)
