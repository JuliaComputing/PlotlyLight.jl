module PlotlyLight

using Artifacts
using Downloads: download
using Random: randstring
using REPL

using JSON3, EasyConfig, Cobweb, StructTypes
using Cobweb: h, Node

#-----------------------------------------------------------------------------# exports
export Plot, Config, Preset, preset, trace

#-----------------------------------------------------------------------------# artifacts
_version = VersionNumber(read(joinpath(artifact"plotly_artifacts", "version.txt"), String))

const plotly = (;
    version = _version,
    url = "https://cdn.plot.ly/plotly-$_version.min.js",
    path = joinpath(artifact"plotly_artifacts", "plotly.min.js"),
    schema = JSON3.read(read(joinpath(artifact"plotly_artifacts", "plot-schema.json"))),
    templates_path = joinpath(artifact"plotly_artifacts", "templates"),
)

#-----------------------------------------------------------------------------# Settings
Base.@kwdef mutable struct Settings
    src::Cobweb.Node    = h.script(src="https://cdn.plot.ly/plotly-$(plotly.version).min.js", charset="utf-8")
    div::Cobweb.Node    = h.div(; style="height:100%;width:100%;")
    layout::Config      = Config()
    config::Config      = Config(responsive=true)
    reuse_preview::Bool = true
end

settings::Settings = Settings()

#-----------------------------------------------------------------------------# utils
fix_matrix(x::Config) = Config(k => fix_matrix(v) for (k,v) in pairs(x))
fix_matrix(x) = x
fix_matrix(x::AbstractMatrix) = eachrow(x)

attributes(t::Symbol) = schema.traces[t].attributes
check_attribute(trace::Symbol, attr::Symbol) = haskey(attributes(trace), attr) || @warn("`\$trace` does not have attribute `\$attr`")
check_attributes(trace::Symbol; kw...) = foreach(k -> check_attribute(trace, k), keys(kw))

#-----------------------------------------------------------------------------# Schema
struct Schema end
Base.propertynames(::Schema) = collect(keys(plotly.schema))
Base.getproperty(::Schema, x::Symbol) = plotly.schema[x]
schema = Schema()

#-----------------------------------------------------------------------------# Plot
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    id::String  # for html script: Plotly.newPlot("id", data, layout, config)
    Plot(data::Vector{Config}, layout::Config = Config(), config::Config = Config(), id::String = randstring(10)) =
    new(data, Config(layout), Config(config), id)
end

Plot(data::Config, layout::Config = Config(), config::Config = Config()) = Plot([data], layout, config)
Plot(; layout=Config(), config=Config(), kw...) = Plot(Config(kw), Config(layout), Config(config))
(p::Plot)(; kw...) = p(Config(kw))
(p::Plot)(data::Config) = (push!(p.data, data); return p)
(p::Plot)(p2::Plot) = (append!(p.data, p2.data); merge!(p.layout, p2.layout); merge!(p.config, p2.config); p)

StructTypes.StructType(::Plot) = StructTypes.Struct()
Base.:(==)(a::Plot, b::Plot) = all(getfield(a,f) == getfield(b,f) for f in setdiff(fieldnames(Plot), [:id]))

#-----------------------------------------------------------------------------# display/show
function html_div(o::Plot)
    id = o.id
    data = JSON3.write(fix_matrix.(o.data); allow_inf=true)
    layout = JSON3.write(merge(settings.layout, o.layout); allow_inf=true)
    config = JSON3.write(merge(settings.config, o.config); allow_inf=true)
    h.div(class="plotlylight-jl-parent-div",
        settings.src,
        settings.div(; id, class="PlotlyLightjl-plot-div"),
        h.script("Plotly.newPlot(\"$id\", $data, $layout, $config)")
    )
end

html_page(o::Plot) =
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

html_iframe(o::Plot; kw...) = IFrame(html_page(o); height="450px", width="700px", style="resize:both; display:block; border:none;", kw...)

Base.show(io::IO, ::MIME"juliavscode/html", o::Plot) = show(io, MIME"text/html"(), o)

function Base.show(io::IO, M::MIME"text/html", o::Plot; kw...)
    !isempty(kw) && Base.depwarn("Keyword arguments for `show`-ing `Plot` are deprecated and will be ignored.", :show; force=true)
    # Jupyter does weird stuff.  We'll use an iframe to sandbox our html.
    use_iframe = (isdefined(Main, :VSCodeServer) && stdout isa Main.VSCodeServer.IJuliaCore.IJuliaStdio) ||
        (isdefined(Main, :IJulia) && stdout isa Main.IJulia.IJuliaStdio)
    out = use_iframe ? html_iframe(o) : html_div(o)
    show(io, M, out)
end

Base.display(::REPL.REPLDisplay, o::Plot) = Cobweb.preview(html_page(o), reuse=settings.reuse_preview)


#-----------------------------------------------------------------------------# preset
function set_template!(t)
    settings.layout.template =
        JSON3.read(read(joinpath(plotly.templates_path, string(t) * ".json")))
    nothing
end

preset = (
    template = (
        none!           = () -> haskey(settings.layout, :template) && delete!(settings.layout, :template),
        ggplot2!        = () -> set_template!(:ggplot2),
        gridon!         = () -> set_template!(:gridon),
        plotly!         = () -> set_template!(:plotly),
        plotly_dark!    = () -> set_template!(:plotly_dark),
        plotly_white!   = () -> set_template!(:plotly_white),
        presentation!   = () -> set_template!(:presentation),
        seaborn!        = () -> set_template!(:seaborn),
        simple_white!   = () -> set_template!(:simple_white),
        xgridoff!       = () -> set_template!(:xgridoff),
        ygridoff!       = () -> set_template!(:ygridoff),
    ),
    source = (
        none!       = () -> (settings.src = h.div("No script due to `PlotlyLight.src_none!`", style="display:none;"); nothing),
        cdn!        = () -> (settings.src = h.script(src=plotly.url, charset="utf-8"); nothing),
        local!      = () -> (settings.src = h.script(src=plotly.path, charset="utf-8"); nothing),
        standalone! = () -> (settings.src = h.script(read(plotly.path, String), charset="utf-8"); nothing),
    )
)

# deprecated stuff
struct PresetDeprecated end
Base.propertynames(::PresetDeprecated) = (:Template, :Source, :PlotContainer)
function Base.getproperty(::PresetDeprecated, x::Symbol)
    Base.depwarn("Preset has been deprecated.  Use the const NamedTuple `PlotlyLight.preset` instead.", :Preset; force=true)
    x == :PlotContainer && error("PlotlyLight has changed its display mechanism.  `PlotContainer` is no longer used.")
    x == :Template && return preset.template
    x == :Source && return preset.source
end
const Preset = PresetDeprecated()

#-----------------------------------------------------------------------------# Traces
include("trace.jl")

end  # PlotlyLight module
