using PlotlyLight
using PlotlyLight: settings
using Test
using Aqua

html(x) = repr("text/html", x)

#-----------------------------------------------------------------------------# Plot methods
@testset "Plot methods" begin
    p = Plot(Config(x = 1:10))
    @test p isa Plot
    @test Plot(; x=1:10) == p
    @test !occursin("Title", html(p))
    @test !occursin("displaylogo", html(p))

    p2 = Plot(Config(x = 1:10), Config(title="Title"))
    @test occursin("Title", html(p2))
    @test !occursin("displaylogo", html(p2))

    p3 = Plot(Config(x = 1:10), Config(title="Title"), Config(displaylogo=true))
    @test occursin("Title", html(p3))
    @test occursin("displaylogo", html(p3))

    p4 = Plot()
    @test isempty(only(p4.data))
    p4(Config(x=1:10,y=1:10))
    @test length(p4.data) == 2
    p4(;x=1:10, y=1:10)
    @test length(p4.data) == 3
    @test p4.data[2] == p4.data[3]
end

#-----------------------------------------------------------------------------# Aqua
Aqua.test_all(PlotlyLight,
    deps_compat=(; ignore =[:REPL, :Random], check_extras = (;ignore=[:Test])),
    persistent_tasks = false
)
