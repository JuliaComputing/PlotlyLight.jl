module PlotlyLight

using Random, JSON3, OrderedCollections

export plot, layout, trace, config

#-----------------------------------------------------------------------------# plot 
function plot(data=[trace()], lay=layout(), conf=config(), dest=joinpath(tempdir(), "plotlylight.html"))
    write_html(data, lay; conf=conf, dest=dest)
end

#-----------------------------------------------------------------------------# utils
const plotlyjspath = joinpath(@__DIR__(), "..", "deps", "plotly-latest.min.js")

function filldict!(d, kw)
    for (k, v) in kw 
        d[k] = v
    end
    return d
end

const dict = OrderedDict{Symbol, Any}

#-----------------------------------------------------------------------------# trace
"""
    trace(; kw...)

Create a trace dict.  List of options is available at:

https://plotly.com/javascript/reference/
"""
trace(; kw...) = filldict!(dict(:x => nothing, :y => nothing, :type => nothing), kw)

#-----------------------------------------------------------------------------# layout
"""
    layout(; kw...)

Create the layout dict.  List of options is available at:

https://plotly.com/javascript/reference/#layout
"""
layout(; kw...) = filldict!(dict(:title => "PlotlyLight Plot"), kw)

#-----------------------------------------------------------------------------# config
"""
    config(; kw...)

Create the configuration dict.  List of options is available at:

https://github.com/plotly/plotly.js/blob/master/src/plot_api/plot_config.js#L22-L86
"""
function config(; kw...)
    d = OrderedDict{Symbol,Any}(
        :staticPlot                 => false,
        :editable                   => false,
        :autosizable                => true,
        :queueLength                => 0,
        :fillFrame                  => false,
        :frameMargins               => 0,
        :scrollZoom                 => false,
        :showTips                   => true,
        :showAxisDragHandles        => true,
        :showAxisRangeEntryBoxes    => true,
        :showLink                   => false,
        :sendData                   => true,
        :linkText                   => "Edit chart",
        :showSources                => false,
        :displayModeBar             => true,
        :displaylogo                => false,
        :responsive                 => true
    )
    filldict!(d, kw)
end

#-----------------------------------------------------------------------------# html_string
function div_string(data = [trace()], lay = layout(); id=randstring(10), conf=config(), kw...)
    data2 = data isa AbstractVector ? data : [data]
    """
    <div id=$(JSON3.write(id)))>
    <script>
        var data = $(JSON3.write(data2))
        var layout = $(JSON3.write(lay))
        Plotly.newPlot($(JSON3.write(id)), data, layout, $(JSON3.write(conf)))
    </script>
    """
end

#-----------------------------------------------------------------------------# html_string
function html_string(divs::String...)
    s = """
    <!DOCTYPE html>
    <html>
    <head>
    <title>PlotlyLight Visualization</title>
    <script src = "$plotlyjspath"></script>
    </head>
    <body>
    """
    for div in divs 
        s *= div 
    end
    s *= """
    </body>
    </html>
    """ 
    s
end

#-----------------------------------------------------------------------------# write_html
function write_html(args...; dest=joinpath(tempdir(), "plot.html"), openhtml=true, kw...)
    touch(dest)
    s = html_string(div_string(args...; kw...))
    write(dest, s)
    if openhtml
        if Sys.iswindows()
            run(`start $dest`)
        elseif Sys.islinux()
            run(`xdg-open $dest`)
        elseif Sys.isapple()
            Sys.run(`open $dest`)
        else
            @warn("Couldn't open $dest on system: $(Sys.KERNEL)")
        end
    end
    return s
end

end # module
