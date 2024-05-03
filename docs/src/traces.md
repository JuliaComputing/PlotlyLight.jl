# Traces


- A core concept in Plotly is that of a *trace*, which is the data along with specifications on how to plot it.
- There are many different trace *types* (e.g. "scatter" for scatterplots, "box" for boxplots).


PlotlyLight does some simple "tricks" with the `plot` function so that:

```julia
plot.trace(; kw...) == plot(; type=trace, kw...)
```

**This allows you to tab-autocomplete the trace type:**

```julia
julia> plot.<TAB>
# bar                 barpolar            box                 candlestick
# carpet              choropleth          choroplethmapbox    cone
# contour             contourcarpet       densitymapbox       funnel
# funnelarea          heatmap             heatmapgl           histogram
# histogram2d         histogram2dcontour  icicle              image
# indicator           isosurface          mesh3d              ohlc
# parcats             parcoords           pie                 pointcloud
# sankey              scatter             scatter3d           scattercarpet
# scattergeo          scattergl           scattermapbox       scatterpolar
# scatterpolargl      scattersmith        scatterternary      splom
# streamtube          sunburst            surface             table
# treemap             violin              volume              waterfall
```

**You can chain the dot syntax to add traces to a plot, e.g.**

```julia
y = randn(20)

plot.bar(; y).scatter(; y)
```
