[![Build status](https://github.com/joshday/PlotlyLight.jl/workflows/CI/badge.svg)](https://github.com/joshday/PlotlyLight.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


<h1 align="center">PlotlyLight</h1>

**PlotlyLight** is an ultra-lightweight (~150 lines) interface for working with [Plotly.js](https://plotly.com/javascript/).

## Cool Features:

- Use the [Plotly.js Javascript documentation](https://plotly.com/javascript/) directly.
    - No magic syntax here.  Just [`JSON3.write`](https://github.com/quinnj/JSON3.jl).
- Set deeply-nested items easily (via [`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl)):
    - `layout.xaxis.title.font.family = "Arial"`
- `display`-ed plots will re-use the same browser tab.


<h2 align="center">Usage</h2>

##### Creating a Plot

```julia
using PlotlyLight

data = Config(x = 1:10, y = randn(10))

p = Plot(data)
```

##### Making Changes

```julia
# Change Layout
p.layout.title.text = "My Title!"

# Add Trace
push!(p.data, Config(x=1:2:10, y=rand(5)))

# Display again (in same browser tab)
p
```

<h2 align="center">Docs for <code>Plot</code></h2>

    Plot(data, layout, config; kw...)

- A Plotly.js plot with components `data`, `layout`, and `config`.
- Each of the three components are converted to JSON via `JSON3.write`.
- See the Plotly Javascript docs here: https://plotly.com/javascript/.

### Arguments
- `data = Config()`: A `Config` (single trace) or `Vector{Config}` (multiple traces).
- `layout = Config()`.
- `config = Config(displaylogo=false, responsive=true)`.

### Keyword Arguments

- `id`, `class`, `style`, `parent_class`, `parent_style`, `pagetitle`, `pagecolor`
- Defaults are chosen so that the plot will responsively fill the page.

Keywords are best understood at looking at how the `Plot` will be `Base.display`-ed (`{{x}}` shows where the arguments go):

    <!DOCTYPE html>
    <html style="background-color: {{pagecolor}}">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{{pagetitle}}</title>
    </head>
    <body>
        <div class={{parent_class}} style={{parent_style}} id="parent-of-{{id}}">
            <div class={{class}} style={{style}} id={{id}}></div>
        </div>
        <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
        <script>
            Plotly.newPlot({{id}}, {{data}}, {{layout}}, {{config}})
        </script>
    </body>
    </html>

### Example

    p = Plot(Config(x=1:10, y=randn(10)))
    p.layout.title.text = "My Title!"
    p
