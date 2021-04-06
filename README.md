<p align="center">
  <h1>PlotlyLight<h1>
</p>

**PlotlyLight** is an ultra-lightweight (<100 lines) interface for working with [Plotly.js](https://plotly.com/javascript/). 

---

- Plotly's Javascript API requires three components: `data`, `layout`, and `config`.  
- `PlotlyLight.Plot` simply does [`EasyConfig.Config`](https://github.com/joshday/EasyConfig.jl)-to-JSON conversion for each of the three components.

```
using PlotlyLight

data = Config(x = 1:10, y = randn(10))

layout = Config()
layout.title.text = "My Title!"

Plot(data, layout)
```

## Display

To display a `PlotlyLight.Plot`, you must be in an environment that can utilize `text/html` mimetypes (like
[Pluto.jl](https://github.com/fonsp/Pluto.jl).

Alternatively, it's straightforward to implement your own display method:

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