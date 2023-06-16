[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight interface for working with [Plotly.js](https://plotly.com/javascript/).

<br><br>

# Features

- 🚀 Fastest time-to-first-plot in Julia!
- 🌐 Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.  No magic syntax: Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl).
    - Set deeply-nested keys easily with [`EasyConfig.jl`](https://github.com/joshday/EasyConfig.jl).
        - e.g. `myplot.layout.xaxis.title.font.family = "Arial"`
- 🕸️ Plays nicely with [Cobweb.jl](https://github.com/joshday/Cobweb.jl) to display or save plots as HTML.
- 🎈 Plots will appear in `MIME"text/html"` environments (like [Pluto.jl](https://github.com/fonsp/Pluto.jl)).
- 📊 The Same [built-in themes](https://plotly.com/python/templates/) as Plotly's python package.

<br><br>

# 🚀 Quickstart

```julia
using PlotlyLight

Preset.Template.plotly_dark!()  # Change template

p = Plot(x = 1:20, y = cumsum(randn(20)), type="scatter", mode="lines+markers")  # Make plot

p.layout.title.text = "My Title!"  # Make changes

p  # `display(p)` to see the updated plot
```


<p align="center">
    <img width=650 src="https://user-images.githubusercontent.com/8075494/213164013-3ba1a108-122a-4339-a0a2-fa2175fa06e3.png">
</p>

#### Adding Traces

- Calling a `Plot` object will add a trace:

```julia
Plot()(
    x = 1:10, y = randn(10), name = "trace 1"
)(
    x = 3:12, y = randn(10), name = "trace 2"
)
```

<br><br>

# 📄 Saving Plots

## Save HTML files with [Cobweb.jl](https://github.com/joshday/Cobweb.jl)

```julia
using Cobweb

page = Cobweb.Page(p)

Cobweb.save(page, "myplot.html")
```

## Save images with [PlotlyKaleido.jl](https://github.com/JuliaPlots/PlotlyKaleido.jl)

```julia
using PlotlyKaleido

PlotlyKaleido.savefig(p, "myplot.png")
```

<br><br>

# `?Plot`

```julia
Plot(data, layout=Config(), config=Config())
Plot(layout=Config(), config=Config(); kw...)
```

Create a Plotly plot with the given `data` (`Config` or `Vector{Config}`), `layout`, and `config`.
Alternatively, you can create a plot with a single trace by providing the `data` as keyword arguments.

For more info, read the Plotly.js docs: [https://plotly.com/javascript/](https://plotly.com/javascript/).

### Examples

```julia
p = Plot(Config(x=1:10, y=randn(10)))

p = Plot(; x=1:10, y=randn(10))
```

<br><br>

# ⚙️ Presets and Settings

- There are several presets that can make your life easier, located in the `Preset` module.
- Each preset is a function that you set via `Preset.[Template|Source|PlotContainer].<preset!>`


## `Preset.Template`

```julia
ggplot2!
gridon!
plotly!
plotly_dark!
plotly_white!
presentation!
seaborn!
simple_white!
xgridoff!
ygridoff!
```


## `Preset.Source`

```julia
cdn!        # Use https://cdn.plot.ly/plotly-<version>.min.js to load Plotly.js.
local!      # Use a local copy of Plotly.
standalone! # Create a standalone html file that hard-codes Plotly.js into it.
none!       # Do not load Plotly.js
```

## `Preset.PlotContainer`

```julia
fillwindow!     # Fill the height/width of the page (REPL default).
responsive!     # Fill whatever container the plot lives in.
iframe!         # Wrap the Plot inside an <iframe> (Jupyter[lab] default).
pluto!          # Use the full width of a Pluto cell (Pluto default).
auto!           # Automatically choose one of the above based on `stdout`.
```

## Manual Settings

If the available `Preset`s aren't enough to satisfy your use case, you can override the settings to your own preferences via the `settings!(; kw...)` function.

- `fix_matrix::Bool = true`
    - Automatically convert any `Matrix` in `data` into a `Vector` of `Vectors`.
    - See [https://github.com/quinnj/JSON3.jl/issues/196](https://github.com/quinnj/JSON3.jl/issues/196) for why this may be necessary.
- `load_plotlyjs = () -> Cobweb.h.script(src=cdn_url[], charset="utf-8")`
    - A function that returns a `MIME("text/html")`-representable object that will load the Plotly.js library.
- `make_container = (id::String) -> Cobweb.h.div(; id=id)
    - A function of an identifier that returns a `MIME("text/html")`-representable object that will write the `<div>` to be populated with the plot.
- `layout = Config()` and `config = Config()`
    - The default `layout` and `config`.  The `Plot`'s `layout` and `config` will override existing values.
- `iframe::Union{Nothing, Cobweb.IFrame} = nothing`
    - A `Cobweb.IFrame` to use as a template to wrap the plot in, e.g. `Cobweb.IFrame(""; height="500px", width="600px")`.

# Update/Change the Version of Plotly.js

```julia
PlotlyLight.update!() # update to latest released version

PlotlyLight.update!(v"2.24.2")  # update to specific release.
```
