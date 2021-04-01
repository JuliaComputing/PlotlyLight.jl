using PlotlyLight
using Test

@testset "PlotlyLight.jl" begin
    p = Plot(Config())

    p.data[1].x = 1:10
    p.data[1].y = randn(10)
end
