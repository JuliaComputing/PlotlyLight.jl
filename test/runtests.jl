using PlotlyLight
using Test

@test Plot(Config(; x = 1:10)) isa Plot
