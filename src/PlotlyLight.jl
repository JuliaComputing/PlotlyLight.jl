module PlotlyLight

using Random
using JSON3
using EasyConfig
using Cobweb
using Pkg.Artifacts
using Downloads

export Plot, Config

#-----------------------------------------------------------------------------# plotly.js artifact
plotlyjs = let
    artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
    plotlylatest_hash = artifact_hash("plotlylatest", artifacts_toml)

    if isnothing(plotlylatest_hash) || !artifact_exists(plotlylatest_hash)
        plotlylatest_hash = create_artifact() do dir
            Downloads.download("https://cdn.plot.ly/plotly-2.8.3.min.js", joinpath(dir, "plotly-latest.min.js"))
        end
        bind_artifact!(artifacts_toml, "plotlylatest", plotlylatest_hash; force=true)
    end
    joinpath(artifact_path(plotlylatest_hash), "plotly-latest.min.js")
end



#-----------------------------------------------------------------------------# src
src_opts = [:cdn, :local, :standalone, :none]
plotlysrc = Ref(:cdn)

"""
    src!(x::Symbol) # `x` must be one of: $src_opts

- `:cdn` → Use PlotlyJS CDN.
- `:local` → Use local artifact.
- `:standalone` → Write JS into the HTML file directly (can be shared and viewed offline).
- `:none` → For when inserting into a page with Plotly.js already included.
"""
src!(x::Symbol) = (x in src_opts || error("src must be one of: $src_opts"); plotlysrc[] = x)


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

Defaults are chosen so that the plot will responsively fill the page.  Keywords are best understood at looking at how the `Plot` gets written into HTML.

```html
<div class="\$parent_class" style="\$parent_style" id="parent-of-\$id">
    <div class="\$class" style="\$style" id="\$id"></div>
</div>

\$(see ?PlotlyLight.src! which shows how plotly.js script is inserted)

<script>
    data = \$(JSON3.write(data))
    layout = \$(JSON3.write(layout))
    config = \$(JSON3.write(config))
    Plotly.newPlot("\$id", data, layout, config)
    \$js
</script>
```

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
    js::Cobweb.Javascript   = Cobweb.Javascript("console.log('plot created!')")
end
function Plot(traces, layout=Config(), config=Config(displaylogo=false, responsive=true); kw...)
    data = traces isa Config ? [traces] : traces
    Plot(; kw..., data, layout, config)
end

#-----------------------------------------------------------------------------# Display
Base.display(::Cobweb.CobwebDisplay, o::Plot) = display(Cobweb.CobwebDisplay(), Cobweb.Page(o))

function Base.show(io::IO, M::MIME"text/html", o::Plot)
    src = plotlysrc[]
    src in [:cdn, :standalone, :none, :local] || error("`src` must be :cdn, :standalone, :none, or :local")
    println(io, "<div class=\"", o.parent_class, "\" style=\"", o.parent_style, "\" id=\"", "parent-of-", o.id, "\">")
    println(io, "    <div class=\"", o.class, "\" style=\"", o.style, "\" id=\"", o.id, "\"></div>")
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
