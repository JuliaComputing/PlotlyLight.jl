module PlotlyLight

using Random
using JSON3
using EasyConfig
using Cobweb
using StructTypes
using Artifacts

export Plot, Config, collectrows

include("version.jl")

const cdn_url = "https://cdn.plot.ly/$version.min.js"
const plotlyjs = joinpath(artifact"PlotlyLight", basename(cdn_url))
const schema = joinpath(artifact"PlotlyLight", "plotly-schema.json")
const templates_dir = joinpath(artifact"PlotlyLight", "templates")
const templates = map(x -> replace(x, ".json" => ""), readdir(templates_dir))

load_schema() = open(io -> JSON3.read(io), schema).schema



#-----------------------------------------------------------------------------# Defaults
module Defaults
using EasyConfig: Config
using JSON3
export src, class, style, parent_class, parent_style, config, layout

src             = Ref(:cdn)
class           = Ref("")
style           = Ref("height: 100%;")
parent_class    = Ref("")
parent_style    = Ref("height: 100vh;")
config          = Ref(Config(displaylogo=false, responsive=true))
layout          = Ref(Config())

function reset!()
    src[]           = :cdn
    class[]         = ""
    style[]         = "height: 100%;"
    parent_class[]  = ""
    parent_style[]  = "height: 100vh;"
    config[]        = Config(displaylogo=false, responsive=true)
    layout[]        = Config()
end
end # Defaults module

#-----------------------------------------------------------------------------# src!
src_opts = [:cdn, :local, :standalone, :none]
"""
    src!(x::Symbol) # `x` must be one of: $src_opts

- `:cdn` → Use PlotlyJS CDN.
- `:local` → Use local artifact.
- `:standalone` → Write JS into the HTML file directly (can be shared and viewed offline).
- `:none` → For when inserting into a page with Plotly.js already included.
"""
src!(x::Symbol) = (x in src_opts || error("src must be one of: $src_opts"); Defaults.src[] = x)

#-----------------------------------------------------------------------------# template!
"""
    template(t)

Load the template `t`, which must be one of:

```
$(join(templates, "\n"))
```
"""
function template(t)
    string(t) in templates || error("$t not found.  Options are one of: $(join(templates, ", ")).")
    open(io -> JSON3.read(io, Config), joinpath(templates_dir, string(t) * ".json"))
end

"""
    template!(t)

Replace the `template` key of the default layout with `t`.  See also : `PlotlyLight.template`.
"""
function template!(t)
    Defaults.layout[].template = template(t)
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
            layout::Config = Defaults.layout[],
            config::Config = Defaults.config[];
            # kw
            id::AbstractString = randstring(10),
            js::Cobweb.Javascript = Cobweb.Javascript("console.log('plot created!')")
        )
        new(data isa Config ? [data] : data, layout, config, string(id), js)
    end
end
Plot(; kw...) = Plot(Config(kw))
(p::Plot)(; kw...) = (push!(p.data, Config(kw)); return p)
(p::Plot)(data::Config) = (push!(p.data, data); return p)

StructTypes.StructType(::Plot) = StructTypes.Struct()

#-----------------------------------------------------------------------------# Display
Base.display(::Cobweb.CobwebDisplay, o::Plot) = display(Cobweb.CobwebDisplay(), Cobweb.Page(o))

Base.show(io::IO, ::MIME"juliavscode/html", o::Plot) = show(io, MIME"text/html"(), o)

function Base.show(io::IO, ::MIME"application/vnd.plotly.v1+json", p::Plot)
    JSON3.write(io, Config(; data=p.data, layout=p.layout, config=p.config))
end

function write_plot_div(io::IO, o::Plot)
    class, style = Defaults.class, Defaults.style
    parent_class, parent_style = Defaults.parent_class, Defaults.parent_style
    parent_style = get(io, :is_pluto, false) || get(io, :jupyter, false) ?
        "height:400px;" * parent_style[] :
        parent_style[]
    println(io, "<div class=\"", parent_class[], "\" style=\"", parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", class[], "\" style=\"", style[], "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")
end

function write_load_plotly(io)
    src = Defaults.src[]
    src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")

    if src === :cdn
        println(io, "<script src=", repr(cdn_url), "></script>")
    elseif src === :standalone
        print(io, "<script>")
        for line in eachline(plotlyjs)
            print(io, line)
        end
        println(io, "</script>")
    elseif src === :local
        println(io, "<script src=\"", plotlyjs, "\"></script>")
    end
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

function write_require_config(io)
    write(io, """
    <script type="text/javascript">
        if (typeof require !== 'undefined') {
            require.undef("plotly");
            requirejs.config({
                paths: {
                    'plotly': '$(cdn_url[7:end-3])'
                }
            });
            require(['plotly'], function(Plotly) {
                window._Plotly = Plotly;
            });
        }
    </script>
    """)
end

function Base.show(io::IO, M::MIME"text/html", o::Plot)
    write_plot_div(io, o)

    if :jupyter in keys(io)
        write_require_config(io)
        println(io, "<script>")
        write(io, "require([\"plotly\"], function(Plotly) {\n")
        write_newplot(io, o)
        show(io, MIME"text/javascript"(), o.js)
        write(io, "});")
        println(io, "</script>")
    else
        # write_plot_div(io, o)
        write_load_plotly(io)
        println(io, "<script>")
        write_newplot(io, o)
        show(io, MIME"text/javascript"(), o.js)
        print(io, "</script>\n")
    end
end

#-----------------------------------------------------------------------------# vecvec
collectrows(x::AbstractMatrix) = collect.(eachrow(x))


end # module
