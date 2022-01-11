[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)

<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight interface for working with [Plotly.js](https://plotly.com/javascript/).

---

- Plotly's Javascript API requires three components: `data`, `layout`, and `config`.
- `PlotlyLight.Plot` simply does [`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl)-to-JSON conversion for each of the three components.
- `PlotlyLight` does very little handholding/checking that your `data`/`layout`/`config` are properly formatted.  You'll need to rely on the [Plotly.js](https://plotly.com/javascript/) docs.

```julia
using PlotlyLight

data = Config(x = 1:10, y = randn(10))

layout = Config()
layout.title.text = "My Title!"

Plot(data, layout)
```

## Displaying `Plot`s

- A `Plot` will open up in your browser (using [DefaultApplication.jl](https://github.com/tpapp/DefaultApplication.jl))
- `Plot`s display inline with `text/html` mimetypes (like [Pluto.jl](https://github.com/fonsp/Pluto.jl).
    - Here's an example using [Blink.jl](https://github.com/JuliaGizmos/Blink.jl)
    ```julia
    using Blink, PlotlyLight

    w = Window()

    load!(w, "https://cdn.plot.ly/plotly-latest.min.js")

    f(p) = body!(w, p)

    f(Plot(Config(x = 1:10, y = randn(10))))
    ```

## `Plot` History

- `PlotlyLight` automatically saves up to `PlotlyLight.n_history[]` (default is 20) plots to be loaded in future Julia sessions.
    - Change this with `PlotlyLight.set_history!(n)`
- See `PlotlyLight.history()` to show the available files.
- E.g. Load the most recent plot with `Plot(PlotlyLight.history(rev=true)[1])`.
