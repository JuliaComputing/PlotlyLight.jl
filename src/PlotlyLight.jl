module PlotlyLight

using Artifacts: @artifact_str
using Downloads: download
using Random: randstring
using REPL: REPL

using JSON3: JSON3
using EasyConfig: Config
using StructTypes: StructTypes
using Cobweb: Cobweb, h, IFrame, Node

#-----------------------------------------------------------------------------# exports
export Plot, Config, preset, plot

#-----------------------------------------------------------------------------# PlotlyArtifacts
artifact(x...) = joinpath(artifact"plotly_artifacts", x...)

Base.@kwdef struct PlotlyArtifacts
    version::VersionNumber  = VersionNumber(read(artifact("version.txt"), String))
    url::String             = "https://cdn.plot.ly/plotly-$version.min.js"
    path::String            = artifact("plotly.min.js")
    schema::JSON3.Object    = JSON3.read(read(artifact("plot-schema.json"), String))
    templates::Dict{String,String} = Dict(t => artifact("templates", t) for t in readdir(artifact("templates")))
end
Base.show(io::IO, p::PlotlyArtifacts) = print(io, "PlotlyArtifacts: v$(p.version)")
plotly::PlotlyArtifacts = PlotlyArtifacts()

#-----------------------------------------------------------------------------# Settings
Base.@kwdef mutable struct Settings
    src::Node               = h.script(src="https://cdn.plot.ly/plotly-$(plotly.version).min.js", charset="utf-8")
    div::Node               = h.div(; style="height:100vh;width:100vw;")
    layout::Config          = Config()
    config::Config          = Config(responsive=true)
    reuse_preview::Bool     = true
    height::String          = "100%"
    width::String           = "100%"
    style::Dict{String,String} = Dict("display" => "block", "border" => "none", "min-height" => "350px", "min-width" => "350px")
end
settings::Settings = Settings()
set!(; kw...) = foreach(x -> setfield!(settings, x...), kw)

#-----------------------------------------------------------------------------# utils
fix_matrix(x::Config) = Config(k => fix_matrix(v) for (k,v) in pairs(x))
fix_matrix(x) = x
fix_matrix(x::AbstractMatrix) = eachrow(x)

attributes(t::Symbol) = plotly.schema.traces[t].attributes
check_attribute(trace, attr::Symbol) = haskey(attributes(Symbol(trace)), attr) || @warn("`$trace` does not have attribute `$attr`.")
check_attributes(trace; kw...) = foreach(k -> check_attribute(Symbol(trace), k), keys(kw))

#-----------------------------------------------------------------------------# Plot
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    Plot(data::Vector{Config}, layout::Config = Config(), config::Config = Config()) = new(data, Config(layout), Config(config))
end

Plot(data::Config, layout::Config = Config(), config::Config = Config()) = Plot([data], layout, config)
Plot(; layout=Config(), config=Config(), kw...) = Plot(Config(kw), Config(layout), Config(config))
(p::Plot)(; kw...) = p(Config(kw))
(p::Plot)(data::Config) = (push!(p.data, data); return p)
(p::Plot)(p2::Plot) = (append!(p.data, p2.data); merge!(p.layout, p2.layout); merge!(p.config, p2.config); p)

StructTypes.StructType(::Plot) = StructTypes.Struct()
Base.:(==)(a::Plot, b::Plot) = all(getfield(a,f) == getfield(b,f) for f in fieldnames(Plot))

Base.getproperty(p::Plot, x::Symbol) = x in fieldnames(Plot) ? getfield(p, x) : (; kw...) -> p(plot(; type=x, kw...))
Base.propertynames(p::Plot) = vcat(fieldnames(Plot)..., keys(plotly.schema.traces)...)

save(p::Plot, file::AbstractString) = open(io -> print(io, html_page(p)), file, "w")
save(file::AbstractString, p::Plot) = save(p, file)

#-----------------------------------------------------------------------------# plot
plot(; kw...) = plot(get(kw, :type, :scatter); kw...)
plot(trace; kw...) = (check_attributes(trace; kw...); Plot(; type=trace, kw...))
Base.propertynames(::typeof(plot)) = sort!(collect(keys(plotly.schema.traces)))
Base.getproperty(::typeof(plot), x::Symbol) = (; kw...) -> plot(x; kw...)

#-----------------------------------------------------------------------------# display/show
function html_div(o::Plot; id=randstring(10))
    data = JSON3.write(fix_matrix.(o.data); allow_inf=true)
    layout = JSON3.write(merge(settings.layout, o.layout); allow_inf=true)
    config = JSON3.write(merge(settings.config, o.config); allow_inf=true)
    h.div(class="plotlylight-parent-div",
        settings.src,
        settings.div(; id, class="plotlylight-plot-div"),
        h.script("Plotly.newPlot(\"$id\", $data, $layout, $config)")
    )
end
function html_page(o::Plot)
    h.html(
        h.head(
            h.meta(charset="utf-8"),
            h.meta(name="viewport", content="width=device-width, initial-scale=1"),
            h.meta(name="description", content="PlotlyLight.jl"),
            h.title("PlotlyLight.jl"),
            h.style("body { margin: 0px; } /* remove scrollbar in iframe */"),
        ),
        h.body(html_div(o))
    )
end
function html_iframe(o::Plot; height=settings.height, width=settings.width, style=settings.style)
    IFrame(html_page(o); height=height, width=width, style=join(["$k:$v" for (k,v) in style], ';'))
end
Base.show(io::IO, ::MIME"text/html", o::Plot) = show(io, MIME"text/html"(), html_iframe(o))
Base.show(io::IO, ::MIME"juliavscode/html", o::Plot) = show(io, MIME"text/html"(), o)

Base.display(::REPL.REPLDisplay, o::Plot) = Cobweb.preview(h.html(h.body(o, style="margin: 0px;")), reuse=settings.reuse_preview)

#-----------------------------------------------------------------------------# preset
# `preset_template_<X>` overwrites `settings.layout.template`
# `preset_src_<X>` overwrites `settings.src`
# `preset_display_<X>` overwrites `settings.config.responsive`, `settings.div`, `settings.layout.[width, height]`

template!(t) = (settings.layout.template = JSON3.read(read(plotly.templates["$t.json"])); nothing)

preset = (
    template = (
        none!           = () -> (haskey(settings.layout, :template) && delete!(settings.layout, :template); nothing),
        ggplot2!        = () -> template!(:ggplot2),
        gridon!         = () -> template!(:gridon),
        plotly!         = () -> template!(:plotly),
        plotly_dark!    = () -> template!(:plotly_dark),
        plotly_white!   = () -> template!(:plotly_white),
        presentation!   = () -> template!(:presentation),
        seaborn!        = () -> template!(:seaborn),
        simple_white!   = () -> template!(:simple_white),
        xgridoff!       = () -> template!(:xgridoff),
        ygridoff!       = () -> template!(:ygridoff)
    ),
    source = (
        none!       = () -> (settings.src = h.div("No script due to `PlotlyLight.src_none!`", style="display:none;"); nothing),
        cdn!        = () -> (settings.src = h.script(src=plotly.url, charset="utf-8"); nothing),
        local!      = () -> (settings.src = h.script(src=plotly.path, charset="utf-8"); nothing),
        standalone! = () -> (settings.src = h.script(read(plotly.path, String), charset="utf-8"); nothing)
    )
)

end  # PlotlyLight module
