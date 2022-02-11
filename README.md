[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~100 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

<br><br>

# 🆒 Features

- Fastest time-to-first-plot in Julia!
- Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.
    - No magic syntax here.  Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl).
- Plays nicely with [Cobweb.jl](https://github.com/joshday/Cobweb.jl).
- Set deeply-nested items easily (via [`EasyConfig.jl`](https://github.com/joshday/EasyConfig.jl)):
    - `myplot.layout.xaxis.title.font.family = "Arial"`
- Plots will appear in `MIME"text/html"` environments (like Jupyter/[IJulia.jl](https://github.com/JuliaLang/IJulia.jl) and [Pluto.jl](https://github.com/fonsp/Pluto.jl)).

<br><br>

# 🏃 Quickstart

### Create

```julia
using PlotlyLight

data = Config(x = 1:20, y = cumsum(randn(20)), type="scatter", mode="lines+markers")

p = Plot(data)
```

### Mutate

```julia
p.layout.title.text = "My Title!"  # Change Layout

push!(p.data, Config(x=1:2:10, y=rand(5)))  # Add Trace

p  # Display again (in same browser tab)
```

<img align=center src="https://user-images.githubusercontent.com/8075494/151987917-15a1c0fa-8f1f-483d-b662-cb8eaba5c7bf.png">

<br><br>

# 📄 Saving HTML files with [Cobweb.jl](https://github.com/joshday/Cobweb.jl)

```julia
using Cobweb: Page

page = Page(p)

save(page, "myplot.html")
```

<br><br>

# 📖 Docs

- See `?Plot` for details on the `Plot` object.
- See `?PlotlyLight.src!` for details on how javascript gets loaded.
