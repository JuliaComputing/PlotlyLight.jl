# Saving

### Saving Plots As HTML

```julia
p = plot(y=rand(10))

PlotlyLight.save(p, "myplot.html")
```

!!! note "Standalone Source"
    Use `PlotlyLight.preset.source.standalone!()` before you save the plot if you want to be able view the plot without internet access.  This will copy-paste the plotly.js script into the html file.



### Save Plots as Image via [PlotlyKaleido.jl](https://github.com/JuliaPlots/PlotlyKaleido.jl)

```julia
using PlotlyKaleido

PlotlyKaleido.start()

(;data, layout, config) = p

PlotlyKaleido.savefig((; data, layout, config), "myplot.png")
```
