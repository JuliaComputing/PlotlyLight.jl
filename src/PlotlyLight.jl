module PlotlyLight

using Random
using JSON3
using EasyConfig

export Plot, Config

plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js")

function __init__() 
    isfile(plotlyjs) || error("Missing dependency.  Try calling `Pkg.build(\"PlotlyLight\")`.")
end

#-----------------------------------------------------------------------------# Plot 
struct Plot 
    data::Vector{Config}
    layout::Config 
    config::Config
    function Plot(data = Config[], layout=Config(), config=Config(displaylogo=false))
        new(data isa Vector ? data : [data], layout, config)
    end
end

function Base.show(io::IO, o::Plot)
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
    id = randstring(20)
    print(io, """<div id="$id"></div>\n""")
    print(io, "<script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>\n")
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
function html(p::Plot, src = :cdn)
    src in [:cdn, :standalone, :local] || error("`src` must be :cdn, :standalone, or :local")
    io = IOBuffer()
    write(io, "<!DOCTYPE html>\n<html>\n  <head>\n  <title>PlotlyLight Viz<title>\n")
    if src === :cdn 
        write(io, "  <script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>")
    elseif src === :standalone 
        write(io, "  <script>")
        for line in readlines(plotlyjs)
            write(io, line)
        end
        write(io, "  </script>")
    else 
        write(io, "  <script src=\"$plotlyjs\"></script>")
    end
    write(io,"  </head>\n  <body>")
    print(io, MIME"text/html"(), p)
    write(io, "\n  </body>\n  </html>")
    String(take!(io))
end

end # module
