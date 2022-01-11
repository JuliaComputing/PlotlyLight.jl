module PlotlyLight

using Random
using JSON3
using EasyConfig
using DefaultApplication
using Scratch
using Printf
using Serialization

export Plot, Config

#-----------------------------------------------------------------------------# init
const plotlyjs = joinpath(@__DIR__, "..", "deps", "plotly-latest.min.js")

plotdir = Ref("")
plot_number = Ref(0)
n_history = Ref(20)  # number of plots to save as history

struct ScratchPlot
    file::String
end

history(; rev=false) = ScratchPlot.(filter!(endswith(".jls"), sort!(readdir(plotdir[]); rev)))

function clean_history!()
    h = history(rev=true)
    n = n_history[]
    if length(h) > n
        rm.(joinpath.(plotdir[], map(x->x.file, h[n+1:end])))
    end
end
set_history!(n::Int) = (n_history[] = n; clean_history!())


function __init__()
    isfile(plotlyjs) || error("Can't find plotly.js.  Try building PlotlyLight again.")
    plotdir[] = @get_scratch!("PlotlyLightHistory")
    h = history()
    if !isempty(h)
        latest_plot = replace(h[end].file, r"(plot_)|(.jls)" => "")
        plot_number[] = parse(Int, latest_plot)
    end
end

#-----------------------------------------------------------------------------# Plot
"""
    Plot(data, layout, config; src=:cdn, class=String[], style="")

A Plotly.js plot with components `data`, `layout`, and `config`.  Each of the three components are
directly converted to JSON.  See the Plotly Javascript docs here: https://plotly.com/javascript/.

- Specify how the Plotly's javascript is loaded via `src`:
    - `:cdn` → load from `"https://cdn.plot.ly/plotly-latest.min.js"` (requires internet access).
    - `:local` → load from `"deps/plotly-latest.min.js"` (downloaded during `Pkg.build("PlotlyLight")`).
    - `:standalone` → Write the `:local` .js file directly into a script tag in the html output.
    - `:none` → `write(io, "text/html"(), plot)` will not add the script tag.
- Classes in `class` will be added to the `<div class="\$(join(class, ' '))">` tag that holds the plot.
- Similar to `class`, `style` will be included via `<div style="\$style">`.

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
    function Plot(data = Config[], layout=Config(), config=Config(displaylogo=false); src=:cdn, style="", class=String[])
        @assert src in [:cdn, :local, :standalone]
        n = @sprintf("%010d", plot_number[] += 1)  # keep files sorted alphabetically
        file = joinpath(plotdir[], "plot_$n.jls")
        p = new(data isa Vector ? data : [data], layout, config, src, class, style, file)
        _save_to_scratchspaces(p)
        return p
    end
end

Plot(sp::ScratchPlot) = deserialize(joinpath(plotdir[], sp.file))

"""
    history(i)

Return the `i`-th latest plot.  E.g. `1`
"""
history(i::Integer) = Plot(history(rev=true)[i])

function delete_history!!()
    n = length(rm.(joinpath.(plotdir, map(x->x.file, history()))))
    @info "Deleted PlotlyLight history of $n plots."
end

function _save_to_scratchspaces(o::Plot)
    serialize(touch(o.scratchfile), o)
    clean_history!()
end

function Base.show(io::IO, o::Plot)
    htmlfile = touch(joinpath(plotdir[], "current_plot.html"))
    open(io -> write_html(io, o), htmlfile, "w")
    DefaultApplication.open(htmlfile)
end


#-----------------------------------------------------------------------------# Show text/html
function Base.show(io::IO, ::MIME"text/html", o::Plot)
    o.src in [:cdn, :standalone, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
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

#-----------------------------------------------------------------------------# HTML
function write_html(io::IO, p::Plot)
    write(io, "<!DOCTYPE html>\n<html>\n  <head>\n  <title>PlotlyLight Viz</title>\n")
    write(io,"\n  </head>\n  <body>\n")
    show(io, MIME"text/html"(), p)
    write(io, "\n  </body>\n  </html>")
end

end # module
