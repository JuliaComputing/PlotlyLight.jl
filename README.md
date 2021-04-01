# PlotlyLight

[![Build Status](https://travis-ci.com/joshday/PlotlyLight.jl.svg?branch=master)](https://travis-ci.com/joshday/PlotlyLight.jl)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


**PlotlyLight** is a low-level, ultra-lightweight interface for working with [Plotly.js](https://plotly.com/javascript/). 

Everything is a pretty direct Julia-to-Javacript conversion.  You create [`EasyConfig.Config`s](https://github.com/joshday/EasyConfig.jl) that mirror the JSON spec of Plotly.  The only two exports are `Plot` and `Config`:

- The `Plot` fields correspond with the three arguments that the Javascript function [`Plotly.newPlot`](https://plotly.com/javascript/plotlyjs-function-reference/#plotlynewplot) accepts.

```julia
Plot(data::Vector{Config}, layout::Config, config::Config)
```

- A `Config` is a JSON-like object that can create intermediate levels on the fly, e.g.

```julia
layout = Config()

layout.xaxis.title = "My X Axis"
```
 
## 🚀 Quickstart

```julia
using PlotlyLight 

p = Plot(Config(x = 1:10, y = randn(10)))

p.layout.title.text = "My Title"

p
```

**This won't display the plot in the REPL**.  Instead you'll see:

```julia
Plot
  Data
     trace 1: [:x, :y]
     trace 2: [:x, :y]
  Layout
     title: Config(:text => "My Title")
  Config
     displaylogo: false
```

- In environments like [Pluto.jl](https://github.com/fonsp/Pluto.jl), the plot **will** display.
- Instead, you can create an HTML div string via `repr("text/html", p)`.
- You can also create an HTML file string via `PlotlyLight.html(p)`.

## Custom Display Functions


### [DefaultApplication.jl](https://github.com/tpapp/DefaultApplication.jl) (HTML)

```julia
using PlotlyLight, DefaultApplication

function f(p::Plot) 
    filename = joinpath(tempdir(), "temp.html")
    file = write(filename, PlotlyLight.html(p))
    DefaultApplication.open(filename)
end

p = Plot(Config(x = 1:10, y = randn(10)))

f(p)
```

### [Blink.jl](https://github.com/JuliaGizmos/Blink.jl)

```julia
using Blink, PlotlyLight

w = Window()

load!(w, "https://cdn.plot.ly/plotly-latest.min.js")

f(p) = body!(w, p)

f(Plot(Config(x = 1:10, y = randn(10))))
```