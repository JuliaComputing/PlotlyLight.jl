using PlotlyLight
using PlotlyLight: settings
using Cobweb
using Cobweb: h
using JSON3: JSON3
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

    p5 = p(p2(p3(p4)))
    @test length(p5.data) == 6
end

@testset "plot" begin
    @test_warn "`scatter` does not have attribute `X`" plot.scatter(X=1:10);
    @test_nowarn plot.scatter(x=1:10);
    @test contains(JSON3.write(plot(y=1:10)), "scatter")
end

@testset "settings" begin
    @test PlotlyLight.settings.layout == Config()
    @test PlotlyLight.settings.config == Config(; responsive=true)
end

@testset "saving" begin
    dir = mktempdir()
    path1 = joinpath(dir, "test.html")
    path2 = joinpath(dir, "test2.html")
    p = Plot(Config(x = 1:10))
    PlotlyLight.save(p, path1)
    PlotlyLight.save(path2, p)
    @test isfile(path1)
    @test isfile(path2)
end

@testset "other" begin
    @test propertynames(Plot()) isa Vector{Symbol}
    @test all(x in propertynames(Plot()) for x in propertynames(plot))
    @test PlotlyLight.fix_matrix([1 2; 3 4]) == [[1, 2], [3, 4]]
    @test propertynames(JSON3.read(JSON3.write(Plot()))) == [:data, :layout, :config]
end

@testset "show/display" begin
    s = sprint((io, x) -> show(io, MIME("juliavscode/html"), x), Plot())
end

@testset "preset" begin
    for f in PlotlyLight.preset.template
        f()
    end
    for f in PlotlyLight.preset.source
        f()
    end
end

#-----------------------------------------------------------------------------# Aqua
Aqua.test_all(PlotlyLight,
    deps_compat=(; ignore =[:REPL, :Random], check_extras = (;ignore=[:Test])),
    persistent_tasks = false
)
