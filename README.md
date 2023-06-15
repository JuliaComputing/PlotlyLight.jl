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

PlotlyLight.Preset.Template.plotly_dark!()  # Change template

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

# ⚙️ Settings

There are several settings that 

## 🧰 Presets





# 📖 Docs

## `?Plot`

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

## `?PlotlyLight.src!`

    src!(x::Symbol) # `x` must be one of: [:cdn, :local, :standalone, :none]

- `:cdn` → Use PlotlyJS CDN.
- `:local` → Use local artifact.
- `:standalone` → Write JS into the HTML file directly (can be shared and viewed offline).
- `:none` → For when inserting into a page with Plotly.js already included.

<br><br>

# ⚙️ Settings and Presets

You can set default values for the `layout`, `config`, and a number of other options that affect how the plot displays in your browser.  HTML defaults (`class`/`style`/`parent_class`/`parent_style`) are chosen to make the plot reactive to the browser window size.

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
    <div class="$class" style="$style" id="plot_is_placed_here"></div>
</div>
```

- Default values are `Ref`s and can be changed e.g.

```julia
PlotlyLight.Defaults.layout[].title.text = "Default Title"
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

- JSON does not have multidimensional arrays (https://www.w3schools.com/js/js_json_datatypes.asp).  Therefore, traces that require matrix inputs (such as heatmap) must use a Vector of Vectors.  We include a small utility function for running this conversion: `PlotlyLight.collectrows(x::Matrix)`.
