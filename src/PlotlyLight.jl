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
end
function Plot(data::Config, layout::Config = Config(), conf::Config = Config(displaylogo=false)) 
    Plot([data], layout, conf)
end

#-----------------------------------------------------------------------------# Show text/html
function Base.show(io::IO, ::MIME"text/html", o::Plot)
    id = randstring(20)
    print(io, """<div id="$id"></div>""")
    print(io, "<script>var data=")
    JSON3.write(io, o.data)
    print(io, "\nvar layout = ")
    JSON3.write(io, o.layout)
    print(io, "\nvar config = ")
    JSON3.write(io, o.config)
    print(io, """\nPlotly.newPlot("$id", data, layout, {displaylogo:false})""")
    print(io, "</script>\n")
end

#-----------------------------------------------------------------------------# HTML
function html(p::Plot, src=:cdn)
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
  
    write(io, MIME"text/html"(), p)
    write(io, "\n  </body>\n  </html>")
    String(take!(io))
end

end # module
