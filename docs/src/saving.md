# Saving Plots

### Saving Plots As HTML

```julia
p = plot(y=rand(10))

PlotlyLight.save(p, "myplot.html")
```

- Note: call `PlotlyLight.preset.source.standalone!()` first if you want the html file to contain the entire plotly.js script.  This enables you to view the plot even without internet access.


### Save Plots as Image via [PlotlyKaleido.jl](https://github.com/JuliaPlots/PlotlyKaleido.jl)

```julia
using PlotlyKaleido

PlotlyKaleido.start()

(;data, layout, config) = p

PlotlyKaleido.savefig((; data, layout, config), "myplot.png")
```
