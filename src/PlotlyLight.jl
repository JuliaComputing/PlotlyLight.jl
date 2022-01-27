module PlotlyLight

using Random
using JSON3
using EasyConfig
using DefaultApplication
using Scratch

export Plot, Config

#-----------------------------------------------------------------------------# init/utils
const plotlyjs = abspath(joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js"))

current = ""  # path to current.html

plotlysrc = Ref(:cdn)  # :cdn, :local, :standalone, :none
src!(x::Symbol) = (plotlysrc[] = x)

struct Javascript
    x::String
end
Base.show(io::IO, ::MIME"text/javascript", j::Javascript) = print(io, j.x)

struct PlotlyLightDisplay <: AbstractDisplay end

function __init__()
    isfile(plotlyjs) || @warn("Can't find local plotly.js.  Try building PlotlyLight again.")
    global current = touch(joinpath(@get_scratch!("PlotlyLightHistory"), "current.html"))
    pushdisplay(PlotlyLightDisplay())
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config; kw...)

- A Plotly.js plot with components `data`, `layout`, and `config`.
- Each of the three components are converted to JSON via `JSON3.write`.
- See the Plotly Javascript docs here: https://plotly.com/javascript/.

### Arguments
- `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
- `layout = Config()`.
- `config = Config(displaylogo=false, responsive=true)`.

### Keyword Arguments

- Defaults are chosen so that the plot will responsively fill the page.

Keywords are best understood at looking at how the `Plot` gets written into HTML:

    {{before_plot (written with MIME"text/html")}}
    <div class={{parent_class}} style={{parent_style}} id="parent-of-{{id}}">
        <div class={{class}} style={{style}} id={{id}}></div>
    </div>
    {{after_plot (written with MIME"text/html")}}
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <script>
        Plotly.newPlot({{id}}, {{data}}, {{layout}}, {{config}})
        {{js (written with MIME"text/javascript; see PlotlyLight.Javascript)}}
    </script>

### Example

    p = Plot(Config(x=1:10, y=randn(10)))
    p.layout.title.text = "My Title!"
    p
"""
Base.@kwdef mutable struct Plot
    data::Vector{Config}    = Config[]
    layout::Config          = Config()
    config::Config          = Config(displaylogo=false, responsive=true)
    id::String              = randstring(10)    # id of graphDiv
    class::String           = ""                # class of graphDiv
    style::String           = "height: 100%"    # style of graphDiv
    parent_class::String    = ""                # class of graphDiv's parent div
    parent_style::String    = "height: 100vh"   # style of graphDiv's parent div
    pagetitle::String       = "PlotlyLight.jl"  # Used only in display(::Plot)
    pagecolor::String       = "#FFFFFF00"       # Used only in display(::Plot)
    before_plot             = HTML("")          # Added immediately before graphDiv (uses MIME"text/html")
    after_plot              = HTML("")          # Added immediately after graphDiv (uses MIME"text/html")
    js                      = Javascript("console.log('Plot made!')") # Additional javascript (uses MIME"text/javascript")
end
function Plot(traces, layout=Config(), config=Config(displaylogo=false, responsive=true); kw...)
    data = traces isa Config ? [traces] : traces
    Plot(; kw..., data, layout, config)
end

#-----------------------------------------------------------------------------# display
current_html() = touch(joinpath(plotdir[], "current.html"))

function write_current_html(o::Plot)
    open(current, "w") do io
        println(io, "<!DOCTYPE html>")
        println(io, "<html style=\"background-color: $(o.pagecolor)\">")
        println(io, "<head>")
        println(io, "    <meta charset=\"UTF-8\">")
        println(io, "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">")
        println(io, "    <title>$(o.pagetitle)</title>")
        println(io, "</head>")
        println(io, "<body>")
        show(io, MIME"text/html"(), o)
        println(io, "</body>")
        println(io, "</html>")
    end
end

function Base.display(::PlotlyLightDisplay, o::Plot)
    write_current_html(o)
    DefaultApplication.open(current)
end

#-----------------------------------------------------------------------------# save
save(filename::String, p::Plot) = save(p, filename)

function save(p::Plot, filename::String)
    if endswith(filename, ".html")
        write_current_html(p)
        cp(current, filename; force=true)
    else
        # TODO: .png, .svg, etc.
        error("File extension on file `$filename` not recognized.")
    end
    abspath(filename)
end


#-----------------------------------------------------------------------------# Show text/html
function Base.show(io::IO, M::MIME"text/html", o::Plot)
    src = plotlysrc[]
    src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    show(io, M, o.before_plot)
    println(io, "<div class=\"", o.parent_class, "\" style=\"", o.parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", o.class, "\" style=\"", o.style, "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")
    show(io, M, o.after_plot)

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
