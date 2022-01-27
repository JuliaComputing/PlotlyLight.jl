module PlotlyLight

using Random
using JSON3
using EasyConfig
using DefaultApplication
using Scratch

export Plot, Config

#-----------------------------------------------------------------------------# init/utils
const plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js")

current = ""  # path to current.html

plotlysrc = Ref(:cdn)  # :cdn, :local, :standalone, :none
src!(x::Symbol) = (plotlysrc[] = x)

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

- `id`, `class`, `style`, `parent_class`, `parent_style`, `pagetitle`, `pagecolor`
- Defaults are chosen so that the plot will responsively fill the page.

Keywords are best understood at looking at how the `Plot` will be `Base.display`-ed (`{{x}}` shows where the arguments go):

    <!DOCTYPE html>
    <html style="background-color: {{pagecolor}}">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{{pagetitle}}</title>
    </head>
    <body>
        <div class={{parent_class}} style={{parent_style}} id="parent-of-{{id}}">
            <div class={{class}} style={{style}} id={{id}}></div>
        </div>
        <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
        <script>
            Plotly.newPlot({{id}}, {{data}}, {{layout}}, {{config}})
        </script>
    </body>
    </html>

### Example

    p = Plot(Config(x=1:10, y=randn(10)))
    p.layout.title.text = "My Title!"
    p
"""
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    id::String              # id of plot div
    class::String           # class of plot div
    style::String           # style of plot div
    parent_class::String    # class of plot div's parent div
    parent_style::String    # style of plot div's parent div
    pagetitle::String       # Used only in display(::Plot)
    pagecolor::String       # Used only in display(::Plot)
    function Plot(data=Config(), layout=Config(), config=Config(displaylogo=false, responsive=true);
            id              = randstring(10),
            class           = "",
            style           = "height: 100%",
            parent_class    = "",
            parent_style    = "height: 100vh",
            pagetitle       = "PlotlyLight.jl",
            pagecolor       = "#FFFFFF00")
        d = data isa Vector ? data : [data]
        new(d, layout, config, id, class, style, parent_class, parent_style, pagetitle, pagecolor)
    end
end

#-----------------------------------------------------------------------------# display
current_html() = touch(joinpath(plotdir[], "current.html"))

function write_current_html(o::Plot)
    open(current, "w") do io
        println(io, "<!DOCTYPE html>")
        println(io, "<html style=\"background-color: $(o.pagecolor)\">")
        println(io, "<head>")
        println(io, "  <meta charset=\"UTF-8\">")
        println(io, "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">")
        println(io, "  <title>$(o.pagetitle)</title>")
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
function Base.show(io::IO, ::MIME"text/html", o::Plot)
    src = plotlysrc[]
    src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    println(io, "<div class=\"", o.parent_class, "\" style=\"", o.parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "  <div class=\"", o.class, "\" style=\"", o.style, "\" id=\"", o.id, "\"></div>")
    println(io, "</div>")

    if src === :cdn
        println(io, "  <script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>")
    elseif src === :standalone
        println(io, "  <script>")
        for line in eachline(plotlyjs)
            println(io, line)
        end
        println(io, "  </script>")
    elseif src === :local
        println(io, "  <script src=\"", plotlyjs, "\"></script>")
    else
        # :none
    end

    println(io, "<script>")
    print(io, "  Plotly.newPlot(\"", o.id, "\", ")
    JSON3.write(io, o.data)
    print(io, ", ")
    JSON3.write(io, o.layout)
    print(io, ", ")
    JSON3.write(io, o.config)
    println(io, ')')
    print(io, "</script>\n")
end

end # module
