using PlotlyLight
using Test

@testset "history" begin
    for i in 1:6
        Plot(Config(; x = 1:10))
        @test Plot(i) isa Plot
        @test Plot(i).data[1].x == 1:10
    end
end
