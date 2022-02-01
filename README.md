[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~100 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

<br><br>

# 🆒 Features

- Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.
    - No magic syntax here.  Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl).
- Plays nicely with [Cobweb.jl](https://github.com/joshday/Cobweb.jl).
- Set deeply-nested items easily (via [`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl)):
    - `layout.xaxis.title.font.family = "Arial"`
- Plots displayed in `MIME"text/html"` environments (like Jupyter/[IJulia.jl](https://github.com/JuliaLang/IJulia.jl) and [Pluto.jl](https://github.com/fonsp/Pluto.jl)) will appear inline.

<br><br>

# 🏃 Quickstart

### Create

```julia
using PlotlyLight

data = Config(x = 1:10, y = randn(10), type="scatter", mode="markers")

p = Plot(data)
```

### Mutate

```julia
p.layout.title.text = "My Title!"  # Change Layout

push!(p.data, Config(x=1:2:10, y=rand(5)))  # Add Trace

p  # Display again (in same browser tab)
```

<br><br>

# 📄 Saving HTML files with [Cobweb.jl](https://github.com/joshday/Cobweb.jl)

```julia
page = Page(p)

save(page, "myplot.html")
```

<br><br>

# 📖 Docs

- See `?Plot` for details on the `Plot` object.
- See `?PlotlyLight.src!` for details on how javascript gets loaded.
