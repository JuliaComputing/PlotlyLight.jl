module PlotlyLight

using Random
using JSON3
using EasyConfig

export Plot, Config

const plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js")

function __init__() 
    isfile(plotlyjs) || error("Can't find plotly.js.  Try building PlotlyLight again.")
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config; src = :cdn, class="")

A Plotly.js plot with components `data`, `layout`, and `config`.  Each of the three components are 
directly converted to JSON.  See the Plotly Javascript docs here: https://plotly.com/javascript/.

### Example 

    Plot(Config(x=1:10, y=randn(10)))

    data = [
        Config(y = randn(10)),
        Config(y = randn(10))
    ]
    layout = Config()
    layout.title.text = "My Title!"
    Plot(data, layout)
"""
struct Plot
    data::Vector{Config}
    layout::Config 
    config::Config
    src::Symbol
    class::String
    function Plot(data = Config[], layout=Config(), config=Config(displaylogo=false); src = :cdn, class="")
        new(data isa Vector ? data : [data], layout, config, src, class)
    end
end

function Base.show(io::IO, ::MIME"text/plain", o::Plot)
    println(io, "Plot")
    printstyled(io, "  Data\n", color=isempty(o.data) ? :light_black : :default)
    for (i,trace) in enumerate(o.data)
        printstyled(io, "     trace $i: ", color=:cyan)
        :type in keys(trace) && printstyled(io, "($(trace.type)) ", color=:light_green)
        printstyled(io, keys(trace), color=:light_green)
        
        println(io)
    end
    printstyled(io, "  Layout\n", color=isempty(o.layout) ? :light_black : :default)
    for (k,v) in pairs(o.layout)
        printstyled(io, "     ", k, ": ", color=:cyan)
        printstyled(io, v, color=:light_green)
        println(io)
    end
    printstyled(io,   "  Config", color=isempty(o.config) ? :light_black : :default)
    for (k,v) in pairs(o.config)
        printstyled(io, "\n     ", k, ": ", color=:cyan)
        printstyled(io, v, color=:light_green)
    end
end

#-----------------------------------------------------------------------------# Show text/html
function Base.show(io::IO, ::MIME"text/html", o::Plot)
    o.src in [:cdn, :standalone, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    id = randstring(20)
    print(io, """<div class="$(o.class)" id="$id"></div>\n""")

    if o.src === :cdn 
        write(io, "  <script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>")
    elseif o.src === :standalone 
        write(io, "  <script>")
        for line in readlines(plotlyjs)
            write(io, line)
        end
        write(io, "  </script>")
    elseif o.src === :none 
        # No script added
    else # :local
        write(io, "  <script src=\"$plotlyjs\"></script>")
    end

    print(io, "<script>\n  var data=")
    JSON3.write(io, o.data)
    print(io, "\n  var layout = ")
    JSON3.write(io, o.layout)
    print(io, "\n  var config = ")
    JSON3.write(io, o.config)
    print(io, """\n  Plotly.newPlot("$id", data, layout, config)\n""")
    print(io, "</script>\n")
end

#-----------------------------------------------------------------------------# HTML
function html(p::Plot)
    io = IOBuffer()
    write(io, "<!DOCTYPE html>\n<html>\n  <head>\n  <title>PlotlyLight Viz</title>\n")
    write(io,"\n  </head>\n  <body>\n")
    show(io, MIME"text/html"(), p)
    write(io, "\n  </body>\n  </html>")
    String(take!(io))
end

end # module
