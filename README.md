[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)

<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~150 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

---

- Plotly's Javascript API requires three JSON components: `data`, `layout`, and `config`.
- You supply these three components as [`EasyConfig.Config`s](https://github.com/joshday/EasyConfig.jl).
    - `Config` lets you set deeply-nested items without creating each level, e.g. `layout.xaxis.title.font.family = "Arial"`.
- `PlotlyLight` does NOT check that your `data`/`layout`/`config` are properly formatted.  You'll need to rely on:
    - [Plotly.js documentation](https://plotly.com/javascript/).
    - Your browser console (to check for javascript errors).

## Usage

```julia
using PlotlyLight

data = Config(x = 1:10, y = randn(10))

layout = Config()
layout.title.text = "My Title!"

Plot(data, layout)
```

### Adding Traces

Here's (a simplified view of) what a `Plot` is:

```julia
mutable struct Plot
    data::Vector{Config}
    layout::Config
    config::Config
end
```

Adding traces is as simple as `push!`-ing to the `data` field:

```julia
push!(my_awesome_plot.data, Config(x=1:10,y=randn(10)))
```

## Displaying `Plot`s

- A `Plot` will open up in your browser (using [DefaultApplication.jl](https://github.com/tpapp/DefaultApplication.jl))
- `Plot`s display inline with `text/html` mimetypes (like [Pluto.jl](https://github.com/fonsp/Pluto.jl)).
    - Here's an example using [Blink.jl](https://github.com/JuliaGizmos/Blink.jl)
    ```julia
    using Blink, PlotlyLight

    w = Window()

    load!(w, "https://cdn.plot.ly/plotly-latest.min.js")

    f(p) = body!(w, p)

    f(Plot(Config(x = 1:10, y = randn(10))))
    ```

## `Plot` History

- `PlotlyLight` automatically saves plot history (default 20) to be loaded in future Julia sessions.
    - Change this with `PlotlyLight.set_history!(n)`.
- See `PlotlyLight.history()` to show the available files.
- E.g. Load the most recent plot with `Plot(PlotlyLight.history(rev=true)[1])`.
