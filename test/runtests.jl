using PlotlyLight
using Test

@testset "PlotlyLight.jl" begin
    plot(trace(x=1:10, y=randn(10)))
end
