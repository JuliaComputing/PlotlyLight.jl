[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~150 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

<br><br>

# 🆒 Features

- 🚀 Fastest time-to-first-plot in Julia!
- 🌐 Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.  No magic syntax: Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl).
    - Set deeply-nested keys easily with [`EasyConfig.jl`](https://github.com/joshday/EasyConfig.jl).
        - e.g. `myplot.layout.xaxis.title.font.family = "Arial"`
- 🕸️ Plays nicely with [Cobweb.jl](https://github.com/joshday/Cobweb.jl) to display or save plots as HTML.
- 🎈 Plots will appear in `MIME"text/html"` environments (like [Pluto.jl](https://github.com/fonsp/Pluto.jl)).
- 📊 The Same [built-in themes](https://plotly.com/python/templates/) as Plotly's python package.

<br><br>

# 🚀 Quickstart

### Create

```julia
using PlotlyLight

p = Plot(x = 1:20, y = cumsum(randn(20)), type="scatter", mode="lines+markers")
```

### Mutate

```julia
p.layout.title.text = "My Title!"  # Change Layout

p  # Display again (in same browser tab)
```
<p align="center">
    <img width=650 src="https://user-images.githubusercontent.com/8075494/151987917-15a1c0fa-8f1f-483d-b662-cb8eaba5c7bf.png">
</p>

#### Adding Traces

- You can add a trace by calling a `PlotlyLight.Plot` object as a function:

```julia
Plot()(
    x = 1:10, y = randn(10), name = "trace 1"
)(
    x = 3:12, y = randn(10), name = "trace 2"
)
```

<br><br>

# 📄 Saving HTML files with [Cobweb.jl](https://github.com/joshday/Cobweb.jl)

```julia
using Cobweb: Page

page = Page(p)

save(page, "myplot.html")
```

<br><br>

# 📖 Docs

## `?Plot`

    Plot(data, layout, config; id, js)

- A Plotly.js plot with components `data`, `layout`, and `config`.
    - `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
    - `layout = Config()`.
    - `config = Config(displaylogo=false, responsive=true)`.
- Each of the three components are converted to JSON via `JSON3.write`.
- See the Plotly Javascript docs here: https://plotly.com/javascript/.
- Keyword Args:
    - `id`: The `id` of the `<div>` the plot will be created in.  Default: `randstring(10)`.
    - `js`:  `Cobweb.Javascript` to add after the creation of the plot.  Default:
        - `Cobweb.Javascript("console.log('plot created!')")`

## `?PlotlyLight.src!`

    src!(x::Symbol) # `x` must be one of: [:cdn, :local, :standalone, :none]

- `:cdn` → Use PlotlyJS CDN.
- `:local` → Use local artifact.
- `:standalone` → Write JS into the HTML file directly (can be shared and viewed offline).
- `:none` → For when inserting into a page with Plotly.js already included.

<br><br>

# ⚙️ Defaults

A common workflow is to create multiple plots with a similar style.  Rather then setting nearly identical layouts for multiple plots, you can set default values for a variety of items.  HTML defaults (`class`/`style`/`parent_class`/`parent_style`) are chosen to make the plot reactive to the browser window size.

```julia
module Defaults
# Plot defaults
config          = Ref(Config(displaylogo=false, responsive=true))
layout          = Ref(Config())

# HTML defaults
src             = Ref(:cdn)  # How plotly gets loaded.  see ?PlotlyLight.src!
class           = Ref("")  # class of the <div> the plot is inside of.
style           = Ref("height: 100%;")  # style of the <div> the plot is inside of.
parent_class    = Ref("")  # class of the plot's parent <div>.
parent_style    = Ref("height: 100vh;")  # style of the plot's parent <div>.
end
```

- As a reference, the underlying HTML of the plot looks like this:
```html
<div class="$parent_class" style="$parent_style">
    <div class="$class" style="$style" id="plot_goes_here"></div>
</div>
```

- Default values can be set e.g.

```julia
PlotlyLight.Defaults.layout[].title="Default Title"
```

- Revert back to the original defaults with `Defaults.reset!()`

<br><br>

# 📊 Themes/Templates

The themes available in [Plotly's python package](https://plotly.com/python/templates/) are also made available in PlotlyLight.jl.  They can be set via:

```julia
layout = Config(template = PlotlyLight.template("plotly_dark"))

PlotlyLight.template!("plotly_dark")  # or replace the default `layout.template`
```

See `PlotlyLight.templates` for a list of theme/template options:

```julia
 "ggplot2"
 "gridon"
 "plotly"
 "plotly_dark"
 "plotly_white"
 "presentation"
 "seaborn"
 "simple_white"
 "xgridoff"
 "ygridoff"
```

<br><br>

# 😵‍💫 Gotchas

- JSON does not have multidimensional arrays (https://www.w3schools.com/js/js_json_datatypes.asp).  Therefore, traces that require matrix inputs (such as heatmap) must use an array of arrays.  We have a small utility function for running this conversion: `PlotlyLight.collectrows(x)`.
