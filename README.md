# PlotlyLight

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://joshday.github.io/PlotlyLight.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://joshday.github.io/PlotlyLight.jl/dev)
[![Build Status](https://travis-ci.com/joshday/PlotlyLight.jl.svg?branch=master)](https://travis-ci.com/joshday/PlotlyLight.jl)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


**PlotlyLight** is a low-level interface for working with [Plotly.js](https://plotly.com/javascript/),
an open source (MIT-licensed) plotting library. 

Everything is a pretty direct Julia-to-Javacript ([`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl) -> `JSON`) conversion.
 
## Quickstart

```julia
using PlotlyLight 

p = Plot()

trace1 = Config()
trace1.x = 1:10
trace1.y = randn(10)

push!(p.data, trace1)

push!(p.data, Config(x=11:20, y=randn(10))) 

p.layout.title.text = "My Title"

p
```

**This won't display the plot in the REPL**

- In environments like [Pluto.jl](https://github.com/fonsp/Pluto.jl), the plot **will** display.
- Instead, you can create an HTML div string via `repr("text/html", p)`.
- You can also create an HTML file string via `PlotlyLight.html(p)`.

## Cool Things to Try

```
using Blink, PlotlyLight

w = Window()

load!(w, "https://cdn.plot.ly/plotly-latest.min.js")

body!(w, Plot(Config(x=1:10,y=randn(10))))
```