# Templates

Templates are set by using the `preset.template.<template>!` family of functions:

```@example templates
using PlotlyLight

keys(PlotlyLight.preset.template)
```

We'll use the following plot to demonstrate each template:

```@example templates
plt = plot.bar(y = randn(10))

nothing # hide
```

## `none!()`

```@example templates
preset.template.none!()
plt
```

## `ggplot2!()`

```@example templates
preset.template.ggplot2!()
plt
```

## `gridon!()`

```@example templates
preset.template.gridon!()
plt
```

## `plotly!()`

```@example templates
preset.template.plotly!()
plt
```

## `plotly_dark!()`

```@example templates
preset.template.plotly_dark!()
plt
```

## `plotly_white!()`

```@example templates
preset.template.plotly_white!()
plt
```

## `presentation!()`

```@example templates
preset.template.presentation!()
plt
```

## `seaborn!()`

```@example templates
preset.template.seaborn!()
plt
```

## `simple_white!()`

```@example templates
preset.template.simple_white!()
plt
```

## `xgridoff!()`

```@example templates
preset.template.xgridoff!()
plt
```

## `ygridoff!()`

```@example templates
preset.template.ygridoff!()
plt
```
