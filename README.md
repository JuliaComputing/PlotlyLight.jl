[![Build status](https://github.com/JuliaComputing/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/JuliaComputing/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/JuliaComputing/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaComputing/PlotlyLight.jl)

<h1 align="center">PlotlyLight</h1>

<p align="center"><b>PlotlyLight</b> is an ultra-lightweight interface for working with <a href="https://plotly.com/javascript">Plotly.js</a>.</p>

<br><br>

## Features

- 🚀 Fastest time-to-first-plot in Julia!
- 🌐 Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.  No magic syntax: Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl) at the core of it.
- 📂 Set deeply-nested keys easily, e.g. `myplot.layout.xaxis.title.font.family = "Arial"`.
- 📊 The Same [built-in themes](https://plotly.com/python/templates/) as Plotly's python package.

<br><br>

## 🚀 Quickstart

```julia
using PlotlyLight

preset.template.plotly_dark!()  # Change template

p = plot(x = 1:20, y = cumsum(randn(20)), type="scatter", mode="lines+markers")  # Make plot

p.layout.title.text = "My Title!"  # Make changes

p  # `display(p)` to see the updated plot
```


<p align="center">
    <img width=650 src="https://user-images.githubusercontent.com/8075494/213164013-3ba1a108-122a-4339-a0a2-fa2175fa06e3.png">
</p>

## Traces

- A core concept in Plotly is that of a *trace*, which is the data along with specifications on how to plot it.
- There are many different trace *types* (e.g. "scatter" for scatterplots, "box" for boxplots).


PlotlyLight does some simple "tricks" with the `plot` function so that:

```julia
plot.trace(; kw...) == Plot(; type=trace, kw...)
```

**This lets you tab-autocomplete the trace type:**

```julia
julia> plot.<TAB>
# bar                 barpolar            box                 candlestick         carpet              choropleth          choroplethmapbox
# cone                contour             contourcarpet       densitymapbox       funnel              funnelarea          heatmap
# heatmapgl           histogram           histogram2d         histogram2dcontour  icicle              image               indicator
# isosurface          mesh3d              ohlc                parcats             parcoords           pie                 pointcloud
# sankey              scatter             scatter3d           scattercarpet       scattergeo          scattergl           scattermapbox
# scatterpolar        scatterpolargl      scattersmith        scatterternary      splom               streamtube          sunburst
# surface             table               treemap             violin              volume              waterfall
```

**You can chain the dot syntax to add traces to a plot, e.g.**

```julia
y = randn(20)

plot.bar(; y).scatter(; y)
```

<br><br>

## 📄 Saving Plots

### Saving Plots As HTML

```julia
p = plot(y=rand(10))

open(io -> show(io, MIME("text/html"), p), touch("myplot.html"), "w")
```

### Save Plots as Image via [PlotlyKaleido.jl](https://github.com/JuliaPlots/PlotlyKaleido.jl)

```julia
using PlotlyKaleido

PlotlyKaleido.start()

(;data, layout, config) = p

PlotlyKaleido.savefig((; data, layout, config), "myplot.png")
```

<br><br>

### Examples

```julia
p = Plot(Config(x=1:10, y=randn(10)))

p = Plot(; x=1:10, y=randn(10))
```

<br><br>

## 🎛️ Presets

### Theme Presets

Set a theme/template via `preset.template.<option>!()`.  Note that options are tab-autocomplete-able.  These are borrowed from the [built-in themes](https://plotly.com/python/templates/) in the plotly python package.

```julia
preset.template.ggplot2!()
```

### Source Presets

Change how the plotly.js script gets loaded in the produced html via `preset.source.<option>!()`.

```julia
preset.source.none!()       # Don't include the script.
preset.source.cdn!()        # Use the official plotly.js CDN.
preset.source.local!()      # Use a local version of the plotly.js script.
preset.source.standalone!() # Copy-paste the plotly.js script into the html output.
```

## ⚙️ Settings

Occasionally `preset`s aren't enough.  Lower level user-configurable settings are available in `PlotlyLight.settings`:

```julia
PlotlyLight.settings.src::Cobweb.Node           # plotly.js script loader
PlotlyLight.settings.div::Cobweb.Node           # The plot-div
PlotlyLight.settings.layout::EasyConfig.Config  # default `layout` for all plots
PlotlyLight.settings.config::EasyConfig.Config  # default `config` for all plots
PlotlyLight.settings.reuse_preview::Bool        # In the REPL, open plots in same page (true, the default) or different pages.
```

Check out e.g. `PlotlyLight.Settings().src` to examine default values.
