module PlotlyLight

using Random: randstring
using Downloads: download
using Scratch: get_scratch!

using JSON3
using EasyConfig
using Cobweb
using Cobweb: h
using StructTypes

#-----------------------------------------------------------------------------# exports
export Plot, Config, Preset, settings!

#-----------------------------------------------------------------------------# __init__()
const version = Ref(VersionNumber("0.0.0"))  # Version of Plotly.js currently in use by PlotlyLight
const cdn_url = Ref("")  # URL of Plotly.js currently in use by PlotlyLight
const scratch_dir = Ref("")  # PlotlyLight's scratchspace
const plotlyjs = Ref("")  # Local copy of Plotly.js
const plotlys_dir = Ref("")  # Directory containing local copies of Plotly.js
const templates_dir = Ref("")  # Directory containing local copies of templates
const schema = Ref{Config}() # Plotly schema
const TEMPLATES = [:ggplot2,:gridon,:plotly,:plotly_dark,:plotly_white,:presentation,:seaborn,:simple_white,:xgridoff,:ygridoff]


function __init__()
    scratch_dir[] = get_scratch!("PlotlyLight")
    plotlyjs[] = joinpath(scratch_dir[], "plotlys", "plotly.min.js")
    plotlys_dir[] = mkpath(joinpath(scratch_dir[], "plotlys"))
    templates_dir[] = mkpath(joinpath(scratch_dir[], "templates"))

    (isempty(readdir(plotlys_dir[])) || isempty(readdir(templates_dir[])) || isempty(readdir(scratch_dir[])) || !isfile(plotlyjs[])) && update!()

    version[] = get_semver(readuntil(plotlyjs[], "*/"))
    cdn_url[] = "https://cdn.plot.ly/plotly-$(version[]).min.js"

    Preset.PlotContainer.auto!()
end


#-----------------------------------------------------------------------------# "artifacts"
# PlotlyLight's scratchspace looks like:
# - <UUID>/PlotlyLight/plotlys/plotly-*.*.*.min.js (as well as plotly.min.js)
# - <UUID>/PlotlyLight/templates/*.json
# - <UUID>/PlotlyLight/plotly-schema.json

get_semver(x) = VersionNumber(match(r"v(\d+)\.(\d+)\.(\d+)", x).match[2:end])

function latest_plotlyjs_version()
    file = download("https://github.com/plotly/plotly.js/releases/latest")
    get_semver(read(file, String))
end

function download_plotly!(v::VersionNumber = latest_plotlyjs_version())
    @info "PlotlyLight: Downloading Plotly.js v$v"
    file = joinpath(scratch_dir[], "plotlys", "plotly-$v.min.js")
    !isfile(file) && download("https://cdn.plot.ly/plotly-$v.min.js", file)
    cp(file, joinpath(scratch_dir[], "plotlys", "plotly.min.js"); force=true)
    nothing
end

function download_templates!()
    for t in TEMPLATES
        @info "PlotlyLight: Downloading template - $t"
        url = "https://raw.githubusercontent.com/plotly/plotly.py/master/packages/python/plotly/plotly/package_data/templates/$t.json"
        download(url, joinpath(scratch_dir[], "templates", "$t.json"))
    end
    nothing
end

function download_schema!()
    @info "PlotlyLight: Downloading schema"
    download("https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27", joinpath(scratch_dir[], "plotly-schema.json"))
    nothing
end
function load_schema(force=false)
    if force || !isassigned(schema)
        schema[] = JSON3.read(open(joinpath(scratch_dir[], "plotly-schema.json"), "r"), Config)
    end
    return schema[]
end

function update!(v::VersionNumber = latest_plotlyjs_version())
    try
        download_plotly!(v)
        download_templates!()
        download_schema!()
        version[] = get_semver(readuntil(plotlyjs[], "*/"))
        cdn_url[] = "https://cdn.plot.ly/$version.min.js"
        nothing
    catch
        @warn "PlotlyLight.update! failed."
    end
end


#-----------------------------------------------------------------------------# Settings
Base.@kwdef mutable struct Settings
    verbose::Bool       = false  # currently unused
    fix_matrix::Bool    = true
    load_plotlyjs       = () -> Cobweb.h.script(src=cdn_url[], charset="utf-8")
    make_container      = (id) -> Cobweb.h.div(; id)
    layout::Config      = Config()
    config::Config      = Config()
    iframe::Union{Nothing, Cobweb.IFrame} = nothing
    display_object::Union{Type{Cobweb.Page}, Type{Cobweb.Tab}} = Cobweb.Page
end
function Base.show(io::IO, o::Settings)
    println(io, "PlotlyLight.Settings:")
    printstyled(io, "  • verbose:\n", color=:light_cyan);
    printstyled(io, "      ", o.verbose, '\n', color=:light_black)
    printstyled(io, "  • fix_matrix:\n", color=:light_cyan);
    printstyled(io, "      ", o.fix_matrix, '\n', color=:light_black)
    printstyled(io, "  • load_plotlyjs: () -> \n", color=:light_cyan)
    printstyled(io, Cobweb.pretty(o.load_plotlyjs(); depth=2), '\n', color=:light_black)
    printstyled(io, "  • make_container: (id) -> \n", color=:light_cyan)
    printstyled(io, Cobweb.pretty(o.make_container("[id]"); depth=2), '\n', color=:light_black)
    printstyled(io, "  • layout: \n", color=:light_cyan)
    printstyled(io, "      Config with keys: $(join(repr.(keys(o.layout)), ", "))", '\n', color=:light_black)
    printstyled(io, "  • config: \n", color=:light_cyan)
    printstyled(io, "      Config with keys: $(join(repr.(keys(o.config)), ", "))", '\n', color=:light_black)
    printstyled(io, "  • iframe: \n", color=:light_cyan)
    printstyled(io, "      ", repr(o.iframe), '\n', color=:light_black)
    printstyled(io, "  • display_object: \n", color=:light_cyan)
    printstyled(io, "      ", repr(o.display_object), '\n', color=:light_black)
end

const SETTINGS = Settings()
const DEFAULT_SETTINGS = SETTINGS
Base.@deprecate_binding DEFAULT_SETTINGS SETTINGS

reset!(s::Settings = SETTINGS) = foreach(x -> setfield!(s, x, getfield(Settings(), x)), fieldnames(Settings))

function settings!(r::Bool = true, s::Settings = SETTINGS; kw...)
    r && reset!(s)
    foreach(kv -> setfield!(s, kv...), kw)
    return s
end

function with_setting(f, setting=SETTINGS; kw...)
    old = deepcopy(setting)
    try
        settings!(; kw...)
        f()
    finally
        foreach(x -> setfield!(setting, x, getfield(old, x)), fieldnames(Settings))
    end
end

#-----------------------------------------------------------------------------# Presets
module Preset
    module Template
        using JSON3, EasyConfig
        import ...SETTINGS, ...templates_dir, ...TEMPLATES
        none!() = (delete!(SETTINGS.layout, :template); SETTINGS)
        for t in TEMPLATES
            f = Symbol("$(t)!")
            @eval begin
                export $f
                function $f()
                    file = joinpath(templates_dir[], $(string(t)) * ".json")
                    SETTINGS.layout.template = open(io -> JSON3.read(io, Config), file)
                    return SETTINGS
                end
            end
        end
    end

    module Source
        using Cobweb: h
        import ...settings!, ...cdn_url, ...plotlyjs
        cdn!() = settings!(; load_plotlyjs = () -> h.script(src=cdn_url[], charset="utf-8"))
        local!() = settings!(; load_plotlyjs = () -> h.script(src=plotlyjs[], charset="utf-8"))
        standalone!() = settings!(; load_plotlyjs = () -> h.script(read(plotlyjs[], String), charset="utf-8"))
        none!() = settings!(; load_plotlyjs = () -> HTML(""))
    end

    module PlotContainer
        using EasyConfig
        using Cobweb: Cobweb, h
        import ...settings!, ...reset!

        fillwindow!(r = true) = settings!(r;
                make_container = id -> h.div(; style="height:100vh;width:100vw;", id),
                config = Config(responsive=true)
            )

        responsive!(r = true) = settings!(r;
                make_container = id -> h.div(style="height:100%;", h.div(; id, style="height:100%;")),
                config=Config(responsive=true, height="100%", width="100%")
            )

        function iframe!(r = true; height="450px", width="700px", style="resize:both; display:block;", kw...)
            fillwindow!(r)
            settings!(false; iframe=Cobweb.IFrame(; height, width, style, kw...))
        end

        pluto!(r = true) = settings!(r, config=Config(height="100%", width="100%"))

        function auto!(r = true, io::IO = stdout)
            :pluto in keys(io) ? pluto!(r) :
            :jupyter in keys(io) ? iframe!(r) :
            isinteractive() ? fillwindow!(r) :
            nothing
        end
    end
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout=Config(), config=Config())
    Plot(layout=Config(), config=Config(); kw...)

Create a Plotly plot with the given `data` (`Config` or `Vector{Config}`), `layout`, and `config`.
Alternatively, you can create a plot with a single trace by providing the `data` as keyword arguments.

For more info, read the Plotly.js docs: [https://plotly.com/javascript/](https://plotly.com/javascript/).

### Examples

    p = Plot(Config(x=1:10, y=randn(10)))

    p = Plot(; x=1:10, y=randn(10))
"""
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    Plot(data::Vector{Config}, layout::Config=Config(), config::Config=Config()) = new(data, layout, config)
end
Plot(data::Config, layout::Config = Config(), config::Config = Config()) = Plot([data], layout, config)
Plot(; layout=Config(), config=Config(), @nospecialize(kw...)) = Plot(Config(kw), Config(layout), Config(config))
(p::Plot)(; @nospecialize(kw...)) = p(Config(kw))
(p::Plot)(data::Config) = (push!(p.data, data); return p)

StructTypes.StructType(::Plot) = StructTypes.Struct()

Base.:(==)(a::Plot, b::Plot) = a.data == b.data && a.layout == b.layout && a.config == b.config

#-----------------------------------------------------------------------------# Display
function page(o::Plot; remove_margins=false)
    return SETTINGS.display_object(h.html(
        h.head(
            h.meta(charset="utf-8"),
            h.meta(name="viewport", content="width=device-width, initial-scale=1"),
            h.meta(name="description", content="PlotlyLight.jl with Plotly $(version[])"),
            h.title("PlotlyLight.jl with Plotly $(version[])"),
            h.style("body { margin: 0px; }")  # removes scrollbar when in iframe
        ),
        o
    ))
end

Base.display(::Cobweb.CobwebDisplay, o::Plot) = display(Cobweb.CobwebDisplay(), page(o))

Base.show(io::IO, ::MIME"juliavscode/html", o::Plot) = show(io, MIME"text/html"(), o)

function Base.show(io::IO, M::MIME"text/html", o::Plot; setting::Settings = SETTINGS, id=randstring(10))
    if isnothing(setting.iframe)
        data = o.data
        layout = o.layout
        config = o.config
        layout = merge(setting.layout, layout)
        config = merge(setting.config, config)
        setting.fix_matrix && (data = fix_matrix.(data))
        show(io, M, setting.load_plotlyjs())
        show(io, M, setting.make_container(id))
        print(io, "<script>Plotly.newPlot(", repr(id), ", ")
        foreach(x -> (JSON3.write(io, x); print(io, ", ")), (data, layout, config))
        print(io, ")</script>")
    else
        iframe = setting.iframe
        with_setting(setting; iframe=nothing) do
            buf = IOBuffer()
            show(buf, M, o; id)
            show(io, M, Cobweb.IFrame(HTML(String(take!(buf))); iframe.kw...))
        end
    end
end

#-----------------------------------------------------------------------------# utils
fix_matrix(x::Config) = Config(k => fix_matrix(v) for (k,v) in pairs(x))
fix_matrix(x) = x
fix_matrix(x::AbstractMatrix) = collect.(eachrow(x))

function check_schema(p::Plot)
    s = load_schema()
    out = true
    all(isempty, p.data) && return out
    for (i, trace) in enumerate(p.data)
        type = trace.type
        if haskey(s.schema.traces, type)
            strace = s.chema.traces[type]
            for key in keys(trace)
                if !haskey(strace, key)
                    @warn "Trace $i (type=:$type) has key :$key, which is not in the Plotly.js schema."
                    out = false
                end
            end
        else
            @warn "Trace $i has type :$type, which is not in the Plotly.js schema."
            out = false
        end
    end
    return out
end

end # module
