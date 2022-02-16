using PlotlyLight
using JSON3
using Test

#-----------------------------------------------------------------------------# simple checks
@testset "simple checks" begin
    @test Plot(Config(x = 1:10)) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title")) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title"), Config(displaylogo=true)) isa Plot
end
#-----------------------------------------------------------------------------# src
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
#-----------------------------------------------------------------------------# templates
@testset "templates" begin
    PlotlyLight.template!(:plotly_dark)
    p = Plot(Config(y=1:10))
    s = repr("text/html", p)

    PlotlyLight.template!(:plotly_white)
    p2 = Plot(Config(y=1:10))
    s2 = repr("text/html", p2)

    @test s != s2
end
