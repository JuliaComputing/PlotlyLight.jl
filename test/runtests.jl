using PlotlyLight
using Test

@test Plot(Config(x = 1:10)) isa Plot

@test Plot(Config(x = 1:10), Config(title="Title")) isa Plot

@test Plot(Config(x = 1:10), Config(title="Title"), Config(displaylogo=true)) isa Plot
