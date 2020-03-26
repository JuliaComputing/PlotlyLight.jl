# PlotlyLight

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://joshday.github.io/PlotlyLight.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://joshday.github.io/PlotlyLight.jl/dev)
[![Build Status](https://travis-ci.com/joshday/PlotlyLight.jl.svg?branch=master)](https://travis-ci.com/joshday/PlotlyLight.jl)
[![Codecov](https://codecov.io/gh/joshday/PlotlyLight.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/PlotlyLight.jl)


**PlotlyLight** is a low-level interface for working with [Plotly.js](https://plotly.com/javascript/),
an open source (MIT-licensed) plotting library.  PlotlyLight works by converting Julia structs (`NamedTuple` and `Dict{Symbol,Any}`) to JSON via [JSON3.jl](https://github.com/quinnj/JSON3.jl).

## How PlotlyLight Works

Plotly.js plots require three parts: **data**, **layout**, and **config**.  In PlotlyLight, these are 
represented as:

- data: `Vector{OrderedDict{Symbol, Any}}` (vector of "traces")
  - Plotly.js refers to each line/series as a "trace".
- layout: `OrderedDict{Symbol, Any}`
- config: `OrderedDict{Symbol, Any}`

You can see the default values in PlotlyLight here:

```julia
julia> using PlotlyLight

julia> trace()
OrderedCollections.OrderedDict{Symbol,Any} with 3 entries:
  :x    => nothing
  :y    => nothing
  :type => nothing

julia> layout()
OrderedCollections.OrderedDict{Symbol,Any} with 1 entry:
  :title => "PlotlyLight Plot"

julia> config()
OrderedCollections.OrderedDict{Symbol,Any} with 17 entries:
  :staticPlot              => false
  :editable                => false
  :autosizable             => true
  :queueLength             => 0
  :fillFrame               => false
  :frameMargins            => 0
  :scrollZoom              => false
  :showTips                => true
  :showAxisDragHandles     => true
  :showAxisRangeEntryBoxes => true
  :showLink                => false
  :sendData                => true
  :linkText                => "Edit chart"
  :showSources             => false
  :displayModeBar          => true
  :displaylogo             => false
```

You can change or add items by using keyword arguments in the `trace`, `layout`, and `config` functions, e.g.:

```julia
julia> trace(x=[1,2,3], y=[3,6,5], type="scatter", text=["point 1", "point 2", "point 3"])
OrderedCollections.OrderedDict{Symbol,Any} with 4 entries:
  :x    => [1, 2, 3]
  :y    => [3, 6, 5]
  :type => "scatter"
  :text => ["point 1", "point 2", "point 3"]
```

You then create plots via the `plot(data, layout, config)` function.  You'll need to rely on the 
Plotly.js documentation to see what your options are:

- https://plotly.com/javascript/reference/
- https://plotly.com/javascript/reference/#layout
- Config options: https://github.com/plotly/plotly.js/blob/master/src/plot_api/plot_config.js#L22-L86


## Examples

```
t = trace(x=[1,2,3], y=[3,6,5], type="scatter", text=["point 1", "point 2", "point 3"])
plot(t, layout(title = "My First Plot"))

t2 = trace(y = randn(10))
plot([t, t2], layout(), config(displayModeBar = false))

# Both `NamedTuple`s and `Dict`s work
plot(t2, layout(title = (text="hi", font=Dict(:family => "Arial", :color=>"blue"))))
```