module PlotlyLight

using Random
using JSON3
using EasyConfig
using Cobweb
using Artifacts

export Plot, Config, collectrows

const cdn_url = "https://cdn.plot.ly/plotly-2.11.0.min.js"
const plotlyjs = joinpath(artifact"plotly.min.js", basename(cdn_url))
const templates_dir = artifact"plotly_templates"
const templates = map(x -> replace(x, ".json" => ""), readdir(templates_dir))


#-----------------------------------------------------------------------------# defaults
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
end

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
Base.@kwdef mutable struct Plot
    data::Vector{Config}    = Config[]
    layout::Config          = Defaults.layout[]
    config::Config          = Defaults.config[]
    id::String              = randstring(10)            # id of graphDiv
    js::Cobweb.Javascript   = Cobweb.Javascript("console.log('plot created!')")
end
function Plot(traces, layout=Defaults.layout[], config=Defaults.config[]; kw...)
    data = traces isa Config ? [traces] : traces
    Plot(; kw..., data,
        layout = merge(layout, Defaults.layout[]),
        config = merge(config, Defaults.config[])
    )
end

#-----------------------------------------------------------------------------# Display
Base.display(::Cobweb.CobwebDisplay, o::Plot) = display(Cobweb.CobwebDisplay(), Cobweb.Page(o))

function Base.show(io::IO, M::MIME"text/html", o::Plot)
    class, style = Defaults.class, Defaults.style
    parent_class, parent_style = Defaults.parent_class, Defaults.parent_style
    parent_style = if get(io, :is_pluto, false)
        s = replace(parent_style[], r"height.*;" => "")
        "height: 400px;" * s
    else
        parent_style[]
    end
    src = Defaults.src[]
    src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    println(io, "<div class=\"", parent_class[], "\" style=\"", parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", class[], "\" style=\"", style[], "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")

    if src === :cdn
        println(io, "<script src=$(repr(cdn_url))></script>")
    elseif src === :standalone
        print(io, "<script>")
        for line in eachline(plotlyjs)
            print(io, line)
        end
        println(io, "</script>")
    elseif src === :local
        println(io, "<script src=\"", plotlyjs, "\"></script>")
    else
        # :none
    end

    println(io, "<script>")
    print(io, "Plotly.newPlot(\"", o.id, "\", ")
    JSON3.write(io, o.data)
    print(io, ", ")
    JSON3.write(io, o.layout)
    print(io, ", ")
    JSON3.write(io, o.config)
    println(io, ");")
    show(io, MIME"text/javascript"(), o.js)
    print(io, "</script>\n")
end

#-----------------------------------------------------------------------------# vecvec
collectrows(x::AbstractMatrix) = collect.(eachrow(x))


end # module
