using PlotlyLight
using PlotlyLight: DEFAULTS
using JSON3
using Test

#-----------------------------------------------------------------------------# simple checks
@testset "simple checks" begin
    @test Plot(Config(x = 1:10)) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title")) isa Plot
    @test Plot(Config(x = 1:10), Config(title="Title"), Config(displaylogo=true)) isa Plot
    p = Plot()
    @test isempty(only(p.data))
    p(Config(x=1:10,y=rand(10)))
    @test length(p.data) == 2
end
#-----------------------------------------------------------------------------# defaults
@testset "defaults" begin
    old_layout_default = copy(DEFAULTS[].layout)
    old_config_default = copy(DEFAULTS[].config)
    p = Plot()
    p.layout.xaxis.showgrid = false
    p.config.editable = true
    # make sure that mutation of layout and config of one plot has no effect on
    # global defaults
    @test DEFAULTS[].layout == old_layout_default
    @test DEFAULTS[].config == old_config_default
end
#-----------------------------------------------------------------------------# src
@testset "src" begin
    p = Plot(Config(y=1:10))

    defaults!(src = :cdn)
    @test occursin("cdn", repr("text/html", p))

    defaults!(src = :none)
    @test !occursin("cdn", repr("text/html", p))

    defaults!(src = :standalone)
    @test length(repr("text/html", p)) > 1000

    defaults!(src = :local)
    @test occursin("scratchspaces", repr("text/html", p))

    defaults!(src = :custom, custom_src = "T E S T")
    @test occursin("T E S T", repr("text/html", p))
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
#-----------------------------------------------------------------------------# vecvec
@testset "collectrows" begin
    x = rand(3, 2)
    v = collectrows(x)
    @test v[1] == x[1, :]
    @test v[2] == x[2, :]
    @test v[3] == x[3, :]
end
