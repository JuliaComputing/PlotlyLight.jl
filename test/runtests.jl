using PlotlyLight
using JSON3
using Test

@testset "sanity check" begin
    @test Plot(Config(x = 1:10)) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title")) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title"), Config(displaylogo=true)) isa Plot
end
@testset "src" begin
    p = Plot(Config(y=1:10))

    PlotlyLight.src!(:cdn)
    @test occursin("plotly-latest.min.js", repr("text/html", p))

    PlotlyLight.src!(:none)
    @test !occursin("plotly-latest.min.js", repr("text/html", p))

    PlotlyLight.src!(:standalone)
    @test length(repr("text/html", p)) > 1000

    PlotlyLight.src!(:local)
    @test occursin("artifacts", repr("text/html", p))
end
