module PlotlyLight

using Random: randstring
using Downloads: download
using Scratch: get_scratch!

using JSON3
using EasyConfig
using Cobweb
using StructTypes

#-----------------------------------------------------------------------------# exports
export Plot, Config, settings!, collectrows

#-----------------------------------------------------------------------------# __init__
const version = Ref("")
const cdn_url = Ref("")

function __init__()
    global DIR = get_scratch!("PlotlyLight")
    global plotlyjs = joinpath(DIR, "plotlys", "plotly-latest.min.js")

    plotlys_dir = mkpath(joinpath(DIR, "plotlys"))
    isempty(readdir(plotlys_dir)) && download_plotly!!()

    global templates_dir = mkpath(joinpath(DIR, "templates"))
    isempty(readdir(templates_dir)) && download_templates!!()

    version[] = get_semver(readuntil(plotlyjs, "*/"))
    cdn_url[] = "https://cdn.plot.ly/plotly-$(version[]).min.js"
end

# PlotlyLight's scratchspace looks like:
# - PlotlyLight/plotlys/plotly-*.*.*.min.js (as well as plotly-latest.min.js)
# - PlotlyLight/templates/*.json
# - PlotlyLight/plotly-schema.json

#-----------------------------------------------------------------------------# Settings
"""
    Settings(; kw...)

- `src`: one of `:cdn`, `:local`, `:standalone`, `:none`, `:custom`.
- `class`, `style`, `parent_class`, `parent_style`: Classes and styles of HTML divs:

```html
<!-- HTML -->
<div class="\$parent_class" style="\$parent_style">
    <div class="\$class" style="\$style" id="plot_is_placed_here"></div>
</div>
```

- `config` and `layout`: `Config`s for the Plotly.js `config` and `layout` arguments.

```javascript
// Javascript
Plotly.newPlot("plot_is_placed_here", data, layout, config);
```

- `custom_src`: A custom source (code injection) to load the for the Plotly.js library.  Only used if `src` is `:custom`.  E.g.

```julia
custom_src = "<script src='https://cdn.plot.ly/plotly-2.23.2.js' charset='utf-8'></script>"
```
"""
Base.@kwdef mutable struct Settings
    src::Symbol = :cdn
    class::String = ""
    style::String = ""
    parent_class::String = ""
    parent_style::String = ""
    config::Config = Config()
    layout::Config = Config()
    custom_src::String = ""
    iframe::Bool = false
end
function Base.show(io::IO, o::Settings)
    println(io, "PlotlyLight.Settings:")
    for name in fieldnames(Settings)
        println(io, "  ", name, ' ' ^ (13 - length(string(name))), "= ", repr(getfield(o, name)))
    end
end
Base.copy(o::Settings) = Settings(; (name => getfield(o, name) for name in fieldnames(Settings))...)

const default_settings = Ref(Settings())

"""
    settings!(; kw...)
    settings!(reset::Bool; kw...)

Update the default settings for PlotlyLight plots, optionally resetting to the default settings.

    See `Settings` for available keyword arguments.
"""
function settings!(reset::Bool; kw...)
    reset && (default_settings[] = Settings())
    settings!(; kw...)
end
settings!(; kw...) = (foreach(x -> setfield!(default_settings[], x...), kw); default_settings[])

function settings(; kw...)
    out = copy(default_settings[])
    foreach(x -> setfield!(out, x...), kw)
    return out
end

fullscreen!() = settings!(true; config=Config(responsive=true), style="height:100%;", parent_style="height:100vh;")
responsive!() = settings!(true; config=Config(responsive=true), style="height:100%;", parent_style="height:100%;")
notebook!() = settings!(true, config=Config(height="450px", width="750px"))
jupyter!() = settings!(true, config=Config(height="450px", width="100%", responsive=true), iframe=true)

const TEMPLATES = ["ggplot2", "gridon", "plotly", "plotly_dark", "plotly_white", "presentation", "seaborn", "simple_white", "xgridoff", "ygridoff"]

"""
    template!(::String)

Set the default template, one of:
```
$(join(repr.(TEMPLATES), ", ")).
```
"""
function template!(t)
    templ = open(io -> JSON3.read(io, Config), joinpath(templates_dir, string(t) * ".json"))
    default_settings[].layout.template = templ
end

#-----------------------------------------------------------------------------# "artifacts"
get_semver(x) = match(r"v(\d+)\.(\d+)\.(\d+)", x).match[2:end]

function latest_plotlyjs_version()
    content = read(download("https://github.com/plotly/plotly.js/tags"), String)
    return get_semver(content)
end

function download_plotly!!()
    v = latest_plotlyjs_version()
    @info "Downloading Plotly.js v$v"
    js = download("https://cdn.plot.ly/plotly-$v.min.js", joinpath(DIR, "plotlys", "plotly-$v.min.js"))
    cp(js, joinpath(DIR, "plotlys", "plotly-latest.min.js"); force=true)
    nothing
end

function download_templates!!()
    for t in TEMPLATES
        @info "Downloading template: $t"
        url = "https://raw.githubusercontent.com/plotly/plotly.py/master/packages/python/plotly/plotly/package_data/templates/$t.json"
        download(url, joinpath(DIR, "templates", "$t.json"))
    end
    nothing
end

function download_schema!!()
    @info "Downloading schema"
    download("https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27", joinpath(DIR, "plotly-schema.json"))
    nothing
end

function update!!()
    download_plotly!!()
    download_templates!!()
    download_schema!!()
    version[] = get_semver(readuntil(plotlyjs, "*/"))
    cdn_url[] = "https://cdn.plot.ly/$version.min.js"
    nothing
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config; id, js)

- A Plotly.js plot with components `data`, `layout`, and `config`.
  - `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
  - `layout = Config()`.
  - `config = Config(displaylogo=false, responsive=true)`.
- Each of the three components are converted to JSON via `JSON3.write`.
- See the Plotly Javascript docs here: https://plotly.com/javascript/.
- Keyword Args:
  - `id`: The `id` of the `<div>` the plot will be created in.  Default: `randstring(10)`.
  - `js`:  `Cobweb.Javascript` to add after the creation of the plot.  Default:
    - `Cobweb.Javascript("console.log('plot created!')")`

### Example

    p = Plot(Config(x=1:10, y=randn(10)))
    p.layout.title.text = "My Title!"
    p
"""
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    id::String  # id of graphDiv
    js::Cobweb.Javascript

    function Plot(
            data::Union{Config, Vector{Config}},
            layout::Config = Config(),
            config::Config = Config();
            # kw
            id::AbstractString = randstring(10),
            js::Cobweb.Javascript = Cobweb.Javascript("console.log(\"plot created!\")")
        )
        layout = merge(default_settings[].layout, layout)
        config = merge(default_settings[].config, config)
        new(data isa Config ? [data] : data, layout, config, string(id), js)
    end
end
Plot(; kw...) = Plot(Config(kw))
(p::Plot)(; kw...) = (push!(p.data, Config(kw)); return p)
(p::Plot)(data::Config) = (push!(p.data, data); return p)

StructTypes.StructType(::Plot) = StructTypes.Struct()

#-----------------------------------------------------------------------------# Display
function page(o::Plot; remove_margins=false)
    h = Cobweb.h
    return Cobweb.Page(h.html(
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

function write_plot_div(io::IO, o::Plot)
    (;class, style, parent_class, parent_style) = default_settings[]
    println(io, "<div class=\"", parent_class, "\" style=\"", parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", class, "\" style=\"", style, "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")
end

src_opts = [:cdn, :local, :standalone, :custom, :none]

function write_load_plotly(io)
    src = default_settings[].src
    src in src_opts || error("`src` must be one of: $src_opts")
    src == :cdn ? println(io, "<script src=\"", cdn_url[], "\" charset=\"utf-8\" ></script>") :
        src == :standalone ? write(io, "<script>", read(plotlyjs), "</script>\n") :
        src == :local ? println(io, "<script src=\"", plotlyjs, "\" charset=\"utf-8\"></script>") :
        src == :custom ? println(io, default_settings[].custom_src) : nothing
end

function write_newplot(io::IO, o::Plot)
    print(io, "Plotly.newPlot(\"", o.id, "\", ")
    JSON3.write(io, o.data)
    print(io, ", ")
    JSON3.write(io, o.layout)
    print(io, ", ")
    JSON3.write(io, o.config)
    println(io, ");")
end

function Base.show(io::IO, M::MIME"text/html", o::Plot)
    if :jupyter in keys(io)
        height = haskey(default_settings[].config, :height) ? default_settings[].config.height : "450px"
        width = haskey(default_settings[].config, :width) ? default_settings[].config.width : "100%"
        write(io, "<iframe")
        write(io, " style='display:block; border:none; position:relative; resize:both; width:$width; height:$height;'")
        write(io, " name='PlotlyLight Plot'")
        write(io, " srcdoc='", repr("text/html", page(o)), "'")
        write(io, " />")
    else
        write_plot_div(io, o)
        write_load_plotly(io)
        println(io, "<script>")
        write_newplot(io, o)
        show(io, MIME"text/javascript"(), o.js)
        print(io, "</script>\n")
    end
end

#-----------------------------------------------------------------------------# collectrows
collectrows(x::AbstractMatrix) = collect.(eachrow(x))


end # module
