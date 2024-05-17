# Plotly.js Source Presets

Change how the plotly.js script gets loaded in the produced html via `preset.source.<option>!()`.

```julia
preset.source.none!()       # Don't include the script.
preset.source.cdn!()        # Use the official plotly.js CDN.
preset.source.local!()      # Use a local version of the plotly.js script.
preset.source.standalone!() # Copy-paste the plotly.js script into the html output.
```
