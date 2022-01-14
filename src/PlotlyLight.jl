module PlotlyLight

using Random
using JSON3
using EasyConfig
using DefaultApplication
using Scratch
using Serialization

export Plot, Config

#-----------------------------------------------------------------------------# init
const plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js")

plotdir = Ref("")
plot_number = Ref(0)

saved() = readdir(plotdir[])

function __init__()
    isfile(plotlyjs) || @warn("Can't find local plotly.js.  Try building PlotlyLight again.")
    plotdir[] = @get_scratch!("PlotlyLightHistory")
    foreach(rm, joinpath.(plotdir, saved()))
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config; kw...)

A Plotly.js plot with components `data`, `layout`, and `config`.  Each of the three components are
directly converted to JSON.  See the Plotly Javascript docs here: https://plotly.com/javascript/.

### Arguments
- `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
- `layout = Config()`.
- `config = Config()`.

### Keyword Arguments
- `src = :cdn`: specify how to load Plotly's Javascript.  One of:
    - `:cdn` → load from `"https://cdn.plot.ly/plotly-latest.min.js"` (requires internet access).
    - `:local` → load from `"deps/plotly-latest.min.js"` (downloaded during `Pkg.build("PlotlyLight")`).
    - `:standalone` → Write the `:local` .js file directly into a script tag in the html output.
    - `:none` → `write(io, MIME"text/html"(), plot)` will not add the script tag.
- `class = String[]`: Classes given to the HTML div that holds the plot.
- `style = ""`: Styles given given to the HTML div that holds the plot.
- `saveas = "plot_\$n"`: A name to save the plot as (Can be reloaded with `Plot(name)`).
    - Plots are only saved within a session.  Multiple Julia sessions running `PlotlyLight` can
      overwrite
- `pagetitle`: The `<title>` tag of the HTML page (default=`"PlotlyLight Viz"`).
- `pagecolor`: The `background-color` style of the HTML Page (default=`"#FFFFFF00"`).

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
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
    src::Symbol
    class::Vector{String}
    style::String
    scratchfile::String
    pagetitle::String
    pagecolor::String
    function Plot(data = Config[], layout=Config(), config=Config(displaylogo=false); src=:cdn,
            style="", class=String[], pagetitle="PlotlyLight Viz", pagecolor="#FFF", saveas=nothing)
        @assert src in [:cdn, :local, :standalone]
        n = plot_number[] += 1
        jlsfile = isnothing(saveas) ? "plot_$n.jls" : "$saveas.jls"
        scratchfile = joinpath(plotdir[], jlsfile)
        p = new(data isa Vector ? data : [data], layout, config, src, class, style, scratchfile, pagetitle, pagecolor)
        serialize(touch(p.scratchfile), p)
        return p
    end
end

Plot(i::Integer) = Plot("plot_$i.jls")

function Plot(name::String)
    name = endswith(name, ".jls") ? name : name * ".jls"
    path = joinpath(plotdir[], name)
    if !isfile(path)
        @warn "No saved plot `$name` was found.  Here is what is available:" saved()
        error("Saved plot not found.")
    end
    deserialize(path)
end

function Base.show(io::IO, o::Plot; open_after_writing=true, kw...)
    page = WebPage(body=[o]; title=o.pagetitle, bgcolor=o.pagecolor, kw...)
    htmlfile = touch(joinpath(plotdir[], "current.html"))
    open(io -> show(io, MIME"text/html"(), page), htmlfile, "w")
    open_after_writing && DefaultApplication.open(htmlfile)
    nothing
end

#-----------------------------------------------------------------------------# save
save(filename::String, p::Plot) = save(p, filename)

function save(p::Plot, filename::String)
    if endswith(filename, ".html")
        show(IOBuffer(), p; open_after_writing = false)
        cp(joinpath(plotdir[], "current_plot.html"), filename; force=true)
    else
        # TODO: .png, .svg, etc.
        error("File extension on file `$filename` not recognized.")
    end
    abspath(filename)
end


#-----------------------------------------------------------------------------# Show text/html
function Base.show(io::IO, ::MIME"text/html", o::Plot)
    o.src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    id = randstring(20)
    print(io, """<div class="$(join(o.class, ' '))" style="$(o.style)" id="$id"></div>\n""")

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

#-----------------------------------------------------------------------------# WebPage
"""
    WebPage(; title, bgcolor, body::Vector)

Simple struct that uses `show(::IO, ::MIME"text/html", ::WebPage)` to write HTML pages.
"""
Base.@kwdef struct WebPage
    title::String = ""
    bgcolor::String = "#FFFFFF"
    body::Vector
end

function Base.show(io::IO, ::MIME"text/html", page::WebPage)
    println(io, "<!DOCTYPE html style='background-color=$(page.bgcolor)'>")
    println(io, "<head>")
    println(io, "  <meta charset=\"UTF-8\">")
    println(io, "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">")
    println(io, "  <title>$(page.title)</title>")
    println(io, "</head>")
    println(io, "<body>")
    for content in page.body
        show(io, MIME"text/html"(), content)
        println(io)
    end
    println(io, "</body>")
    println(io, "</html>")
end

end # module
