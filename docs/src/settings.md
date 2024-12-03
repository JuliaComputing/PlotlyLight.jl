# Settings

Occasionally the `PlotlyLight.preset`s aren't enough.  Low level user-configurable settings are available in `PlotlyLight.settings`:

```julia
settings.src::Cobweb.Node           # plotly.js script loader
settings.div::Cobweb.Node           # The plot-div
settings.layout::EasyConfig.Config  # default `layout` for all plots
settings.config::EasyConfig.Config  # default `config` for all plots
settings.reuse_preview::Bool        # In the REPL, open plots in same page (true, the default) or different pages.
settings.page_css::Cobweb.Node      # CSS to inject at the top of the page
settings.use_iframe::Bool           # Use an iframe to display the plot (default=false)
settings.iframe_style::String       # style attributes for the iframe
settings.src_inject::Vector         # Code (typically scripts) to inject into the html
```

Check out e.g. `PlotlyLight.Settings()` to examine default values.
