module PlotlyLight

using Random: randstring
using Downloads: download
using Scratch: get_scratch!

using JSON3
using EasyConfig
using Cobweb
using StructTypes

#-----------------------------------------------------------------------------# exports
export Plot, Config, defaults!, collectrows

#-----------------------------------------------------------------------------# __init__()
const version = Ref("")  # Version of Plotly.js currently in use by PlotlyLight
const cdn_url = Ref("")  # URL of Plotly.js currently in use by PlotlyLight
const scratch_dir = Ref("")  # PlotlyLight's scratchspace
const plotlyjs = Ref("")  # Local copy of Plotly.js
const plotlys_dir = Ref("")  # Directory containing local copies of Plotly.js
const templates_dir = Ref("")  # Directory containing local copies of templates
const TEMPLATES = [:ggplot2, :gridon, :plotly, :plotly_dark, :plotly_white, :presentation, :seaborn, :simple_white, :xgridoff, :ygridoff]

function __init__()
    scratch_dir[] = get_scratch!("PlotlyLight")
    plotlyjs[] = joinpath(scratch_dir[], "plotlys", "plotly-latest.min.js")
    plotlys_dir[] = mkpath(joinpath(scratch_dir[], "plotlys"))
    templates_dir[] = mkpath(joinpath(scratch_dir[], "templates"))
    DEFAULTS[] = Defaults()

    isempty(readdir(plotlys_dir[])) || isempty(readdir(templates_dir[])) || isempty(readdir(scratch_dir[])) && update!()

    version[] = get_semver(readuntil(plotlyjs[], "*/"))
    cdn_url[] = "https://cdn.plot.ly/plotly-$(version[]).min.js"

    @info """
    Attention: PlotlyLight 0.7 has breaking changes:

    1. No more artifacts.  PlotlyLight now downloads the latest version of Plotly.js and templates at your request.
      - Use `PlotlyLight.update!()` to update Plotly and the templates.

    2. `Defaults` is now a struct rather than a module.  No more messing around with `Ref`s.  Change defaults with `defaults!(reset::Bool; kw...)`.
        - See `?Defaults` and `?defaults!` for more info.
    """
end


#-----------------------------------------------------------------------------# "artifacts"
get_semver(x) = match(r"v(\d+)\.(\d+)\.(\d+)", x).match[2:end]

function latest_plotlyjs_version()
    content = read(download("https://github.com/plotly/plotly.js/tags"), String)
    return get_semver(content)
end

function download_plotly!(v::String = latest_plotlyjs_version())
    @info "Downloading Plotly.js v$v"
    file = joinpath(scratch_dir[], "plotlys", "plotly-$v.min.js")
    !isfile(file) && download("https://cdn.plot.ly/plotly-$v.min.js", file)
    cp(file, joinpath(scratch_dir[], "plotlys", "plotly-latest.min.js"); force=true)
    nothing
end

function download_templates!()
    for t in TEMPLATES
        @info "Downloading template: $t"
        url = "https://raw.githubusercontent.com/plotly/plotly.py/master/packages/python/plotly/plotly/package_data/templates/$t.json"
        download(url, joinpath(scratch_dir[], "templates", "$t.json"))
    end
    nothing
end

function download_schema!()
    @info "Downloading schema"
    download("https://api.plot.ly/v2/plot-schema?format=json&sha1=%27%27", joinpath(scratch_dir[], "plotly-schema.json"))
    nothing
end

function update!()
    download_plotly!()
    download_templates!()
    download_schema!()
    version[] = get_semver(readuntil(plotlyjs[], "*/"))
    cdn_url[] = "https://cdn.plot.ly/$version.min.js"
    nothing
end

# PlotlyLight's scratchspace looks like:
# - PlotlyLight/plotlys/plotly-*.*.*.min.js (as well as plotly-latest.min.js)
# - PlotlyLight/templates/*.json
# - PlotlyLight/plotly-schema.json

#-----------------------------------------------------------------------------# Defaults
"""
    Defaults(; kw...)

- `src`: one of `:cdn`, `:local`, `:standalone`, `:none`, `:custom`.
- `class`, `style`, `parent_class`, `parent_style`: Classes and styles of HTML divs:

```html
<!-- HTML -->
<div class="\$parent_class" style="\$parent_style">
    <div class="\$class" style="\$style" id="plot_is_placed_here"></div>
</div>
```

- `config` and `layout`: `Config`s for the Plotly.js `config` and `layout` arguments.

- `custom_src`: Code injection to load the Plotly.js library.  Used if `src == :custom`.  E.g.

```julia
custom_src = "<script src='https://cdn.plot.ly/plotly-2.23.2.js' charset='utf-8'></script>"
```
"""
mutable struct Defaults
    src::Symbol
    class::String
    style::String
    parent_class::String
    parent_style::String
    config::Config
    layout::Config
    custom_src::String

    function Defaults(; src::Symbol = :cdn, class::String = "", style::String = "",
            parent_class::String = "", parent_style::String = "",
            config::Config = Config(), layout::Config = Config(),
            custom_src::String = "")

        src in [:cdn, :local, :standalone, :none, :custom] || throw(ArgumentError("src must be one of: :cdn, :local, :standalone, :none, :custom."))
        new(src, class, style, parent_class, parent_style, config, layout, custom_src)
    end

end
function Base.show(io::IO, o::Defaults)
    println(io, "PlotlyLight.Defaults:")
    for name in fieldnames(Defaults)
        println(io, "  ", name, ' ' ^ (13 - length(string(name))), "= ", repr(getfield(o, name)))
    end
end
Base.copy(o::Defaults) = Defaults(; (name => getfield(o, name) for name in fieldnames(Defaults))...)

function template(x::String)
    return open(io -> JSON3.read(io, Config), joinpath(templates_dir[], string(x) * ".json"))
end
Base.getproperty(::typeof(template), x) = template(string(x))
Base.propertynames(::typeof(template)) = TEMPLATES


const DEFAULTS = Ref(Defaults())

function with_defaults(f; kw...)
    old_defaults = copy(DEFAULTS[])
    try
        defaults!(; kw...)
        return f()
    finally
        DEFAULTS[] = old_defaults
    end
end

"""
    defaults!(; kw...)
    defaults!(reset::Bool; kw...)

Update the default settings for PlotlyLight plots.  Optionally, you can `reset` the defaults to the original settings.

`kw` options: `$(fieldnames(Defaults))`

Some built-in defaults are also provided:

- `fillwindow!()`: Plot will fill a browser window.  This is the initial setting.
- `responsive!()`: Plot will fill its parent container.
- `pluto!()`: Sensible defaults for Pluto.
- `jupyter!()`: Sensible defaults for Jupyter.
"""
function defaults!(reset::Bool; kw...)
    reset && (DEFAULTS[] = Defaults())
    defaults!(; kw...)
end
defaults!(; kw...) = (foreach(x -> setfield!(DEFAULTS[], x...), kw); DEFAULTS[])

function defaults(; kw...)
    out = copy(DEFAULTS[])
    foreach(x -> setfield!(out, x...), kw)
    return out
end

fillwindow!(; kw...) = defaults!(true; parent_style = "height:100vh;", style="height:100%;", config=Config(responsive=true), kw...)
responsive!(; kw...) = defaults!(true; config=Config(responsive=true), style="height:100%;", parent_style="height:100%;", kw...)
pluto!(; kw...) = defaults!(true, config=Config(height="450px", width="750px"), parent_style="", kw...)
jupyter!(; kw...) = defaults!(true, config=Config(height="450px", width="100%", responsive=true), kw...)


"""
    template!(::String)

Set the default template, one of:
```
$(join(repr.(TEMPLATES), ", ")).
```
"""
function template!(t)
    t in TEMPLATES || throw(ArgumentError("template must be one of: $(join(TEMPLATES, ", "))."))
    file = joinpath(templates_dir[], string(t) * ".json")
    !isfile(file) && try
        download_templates!()
    catch
        error("Template $t was not locally available and could not be downloaded with `PlotlyLight.download_templates!()`.")
    end
    DEFAULTS[].layout.template = open(io -> JSON3.read(io, Config), file)
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
        layout = merge(DEFAULTS[].layout, layout)
        config = merge(DEFAULTS[].config, config)
        new(data isa Config ? [data] : data, layout, config, string(id), js)
    end
end
Plot(; @nospecialize(kw...)) = Plot(Config(kw))
(p::Plot)(; @nospecialize(kw...)) = (push!(p.data, Config(kw)); return p)
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
    (;class, style, parent_class, parent_style) = DEFAULTS[]
    println(io, "<div class=\"", parent_class, "\" style=\"", parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", class, "\" style=\"", style, "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")
end

src_opts = [:cdn, :local, :standalone, :custom, :none]

function write_load_plotly(io)
    src = DEFAULTS[].src
    src == :cdn ? println(io, "<script src=\"", cdn_url[], "\" charset=\"utf-8\" ></script>") :
        src == :standalone ? write(io, "<script>", read(plotlyjs[]), "</script>\n") :
        src == :local ? println(io, "<script src=\"", plotlyjs[], "\" charset=\"utf-8\"></script>") :
        src == :custom ? println(io, DEFAULTS[].custom_src) :
        nothing
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
        height = haskey(DEFAULTS[].config, :height) ? DEFAULTS[].config.height : "450px"
        width = haskey(DEFAULTS[].config, :width) ? DEFAULTS[].config.width : "100%"
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
