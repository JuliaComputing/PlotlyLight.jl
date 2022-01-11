using PlotlyLight
using Test

@testset "history" begin
    PlotlyLight.set_history!(5)
    @test PlotlyLight.n_history[] == 5
    for _ in 1:6
        Plot(Config(; x = 1:10))
    end
    @test length(PlotlyLight.history()) == 5
end
