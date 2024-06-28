# Settings

Occasionally the `PlotlyLight.preset`s aren't enough.  Low level user-configurable settings are available in `PlotlyLight.settings`:

```julia
PlotlyLight.settings.src::Cobweb.Node           # plotly.js script loader
PlotlyLight.settings.div::Cobweb.Node           # The plot-div
PlotlyLight.settings.layout::EasyConfig.Config  # default `layout` for all plots
PlotlyLight.settings.config::EasyConfig.Config  # default `config` for all plots
PlotlyLight.settings.reuse_preview::Bool        # In the REPL, open plots in same page (true, the default) or different pages.
PlotlyLight.settings.style::Dict{String,String} # CSS styles for the plot <div>
```

Check out e.g. `PlotlyLight.Settings().src` to examine default values.

