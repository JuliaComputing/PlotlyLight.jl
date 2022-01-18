[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)

<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~150 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

## Cool Features:

- [`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl)-to-JSON conversion.
    - `Config` lets you set deeply-nested items without creating intermediate levels.
    - e.g. `layout.xaxis.title.font.family = "Arial"`.
- Your plots are automatically saved.  Re-open the `i`-th most recent plot with `Plot(i)`.
- Displaying plots in the REPL will re-use the same browser window.


## Usage

```julia
using PlotlyLight

data = Config(x = 1:10, y = randn(10))

layout = Config()
layout.title.text = "My Title!"

Plot(data, layout)
```

## Main Docstring

    Plot(data, layout, config; kw...)

A Plotly.js plot with components `data`, `layout`, and `config`.  Each of the three components are
directly converted to JSON.  See the Plotly Javascript docs here: https://plotly.com/javascript/.

### Arguments
- `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
- `layout = Config()`.
- `config = Config()`.

### Keyword Arguments
- `src = :cdn`: specify how to load Plotly's Javascript.  One of:
    - `:cdn` → load from `"https://cdn.plot.ly/plotly-latest.min.js"` (requires internet access).
    - `:local` → load from `"deps/plotly-latest.min.js"` (downloaded during `Pkg.build("PlotlyLight")`).
    - `:standalone` → Write the `:local` .js file directly into a script tag in the html output.
    - `:none` → `write(io, MIME"text/html"(), plot)` will not add the script tag.
- `class = String[]`: Classes given to the HTML div that holds the plot.
- `style = ""`: Styles given given to the HTML div that holds the plot.
- `saveas = "plot_\$n"`: A name to save the plot as (Can be reloaded with `Plot(name)`).
    - Plots are only saved within a session.  Multiple Julia sessions running `PlotlyLight` can
      overwrite
- `pagetitle`: The `<title>` tag of the HTML page (default=`"PlotlyLight Viz"`).
- `pagecolor`: The `background-color` style of the HTML Page (default=`"#FFFFFF00"`).

### Adding Traces

Here's (a simplified view of) what a `Plot` is:

```julia
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
end
```

Adding traces is as simple as `push!`-ing a `Config` to the `data` field:

```julia
push!(my_awesome_plot.data, Config(x=1:10, y=randn(10)))
```

## Displaying `Plot`s

- A `Plot` will open up in your browser (using [DefaultApplication.jl](https://github.com/tpapp/DefaultApplication.jl))
- `Plot`s will display inline in environments with `text/html` mimetypes (like [Pluto.jl](https://github.com/fonsp/Pluto.jl)).
    - Here's an example using [Blink.jl](https://github.com/JuliaGizmos/Blink.jl)
    ```julia
    using Blink, PlotlyLight

    w = Window()

    load!(w, "https://cdn.plot.ly/plotly-latest.min.js")

    f(p) = body!(w, p)

    f(Plot(Config(x = 1:10, y = randn(10))))
    ```

## `Plot`ting History

- `PlotlyLight` automatically saves each plot from the current Julia session.
- See `PlotlyLight.saved()` to show the available files.
- E.g. Load the `i`-th most recent plot with `Plot(i)`.
