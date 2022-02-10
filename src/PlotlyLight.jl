module PlotlyLight

using Random
using JSON3
using EasyConfig
using Cobweb

export Plot, Config

function __init__()
    global plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-2.8.3.min.js")
    !(isfile(plotlyjs)) && @warn "Cannot find plotly.js. PlotlyLight should be built again."
end

#-----------------------------------------------------------------------------# defaults
module Defaults
using EasyConfig: Config

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

#-----------------------------------------------------------------------------# src
src_opts = [:cdn, :local, :standalone, :none]
"""
    src!(x::Symbol) # `x` must be one of: $src_opts

- `:cdn` → Use PlotlyJS CDN.
- `:local` → Use local artifact.
- `:standalone` → Write JS into the HTML file directly (can be shared and viewed offline).
- `:none` → For when inserting into a page with Plotly.js already included.
"""
src!(x::Symbol) = (x in src_opts || error("src must be one of: $src_opts"); Defaults.src[] = x)

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config)

- A Plotly.js plot with components `data`, `layout`, and `config`.
    - `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
    - `layout = Config()`.
    - `config = Config(displaylogo=false, responsive=true)`.
- Each of the three components are converted to JSON via `JSON3.write`.
- See the Plotly Javascript docs here: https://plotly.com/javascript/.

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
    Plot(; kw..., data, layout, config)
end

#-----------------------------------------------------------------------------# Display
Base.display(::Cobweb.CobwebDisplay, o::Plot) = display(Cobweb.CobwebDisplay(), Cobweb.Page(o))

function Base.show(io::IO, M::MIME"text/html", o::Plot)
    (; class, style, parent_class, parent_style) = Defaults
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
        println(io, "<script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>")
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

end # module
