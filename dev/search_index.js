var documenterSearchIndex = {"docs":
[{"location":"source/#Plotly.js-Source-Presets","page":"Plotly.js Source Presets","title":"Plotly.js Source Presets","text":"","category":"section"},{"location":"source/","page":"Plotly.js Source Presets","title":"Plotly.js Source Presets","text":"Change how the plotly.js script gets loaded in the produced html via preset.source.<option>!().","category":"page"},{"location":"source/","page":"Plotly.js Source Presets","title":"Plotly.js Source Presets","text":"preset.source.none!()       # Don't include the script.\npreset.source.cdn!()        # Use the official plotly.js CDN.\npreset.source.local!()      # Use a local version of the plotly.js script.\npreset.source.standalone!() # Copy-paste the plotly.js script into the html output.","category":"page"},{"location":"saving/#Saving-Plots","page":"Saving Plots","title":"Saving Plots","text":"","category":"section"},{"location":"saving/#Saving-Plots-As-HTML","page":"Saving Plots","title":"Saving Plots As HTML","text":"","category":"section"},{"location":"saving/","page":"Saving Plots","title":"Saving Plots","text":"p = plot(y=rand(10))\n\nPlotlyLight.save(p, \"myplot.html\")","category":"page"},{"location":"saving/","page":"Saving Plots","title":"Saving Plots","text":"Note: call PlotlyLight.preset.source.standalone!() first if you want the html file to contain the entire plotly.js script.  This enables you to view the plot even without internet access.","category":"page"},{"location":"saving/#Save-Plots-as-Image-via-[PlotlyKaleido.jl](https://github.com/JuliaPlots/PlotlyKaleido.jl)","page":"Saving Plots","title":"Save Plots as Image via PlotlyKaleido.jl","text":"","category":"section"},{"location":"saving/","page":"Saving Plots","title":"Saving Plots","text":"using PlotlyKaleido\n\nPlotlyKaleido.start()\n\n(;data, layout, config) = p\n\nPlotlyKaleido.savefig((; data, layout, config), \"myplot.png\")","category":"page"},{"location":"plotly_basics/#Plotly.js-Basics","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"","category":"section"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"Plotly.js is a JavaScript library that allows you to create interactive plots in the browser.","category":"page"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"PlotlyLight provide a lightweight interface over the Javascript, so it is worthwhile to learn how the Plotly.js library works.","category":"page"},{"location":"plotly_basics/#What-is-a-Plot?","page":"Plotly.js Basics","title":"What is a Plot?","text":"","category":"section"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"The core JS function that generates a plot is Plotly.newPlot(data, layout, config), where data is a JSON array of objects and layout/config are JSON objects.  Each element of data is called a trace (data along with specifications on how to plot it).","category":"page"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"note: Plotly.js Schema\nThe Plotly.js specification is available as a JSON schema (raw JSON here).PlotlyLight includes this schema as PlotlyLight.plotly.schema if you wish to investigate it.","category":"page"},{"location":"plotly_basics/#What-is-a-Trace?","page":"Plotly.js Basics","title":"What is a Trace?","text":"","category":"section"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"A trace is a JSON object that specifies how data should be represented in a plot.\nThere are many different trace types (e.g. \"scatter\" for scatterplots, \"box\" for boxplots).","category":"page"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"note: Tab Auto-Complete\nPlotlyLight's plot function enables tab-autocomplete for trace types:julia> plot.<TAB>\n# bar                 barpolar            box                 candlestick\n# carpet              choropleth          choroplethmapbox    cone\n# contour             contourcarpet       densitymapbox       funnel\n# funnelarea          heatmap             heatmapgl           histogram\n# histogram2d         histogram2dcontour  icicle              image\n# indicator           isosurface          mesh3d              ohlc\n# parcats             parcoords           pie                 pointcloud\n# sankey              scatter             scatter3d           scattercarpet\n# scattergeo          scattergl           scattermapbox       scatterpolar\n# scatterpolargl      scattersmith        scatterternary      splom\n# streamtube          sunburst            surface             table\n# treemap             violin              volume              waterfallAlternatively, you can type e.g. plot(; type=\"scatter\", kw...).","category":"page"},{"location":"plotly_basics/","page":"Plotly.js Basics","title":"Plotly.js Basics","text":"note: Trace Chaining\nPlotlyLight lets you chain traces with the dot syntax:using PlotlyLight  # hide\ny = randn(20)\n\nplot.bar(; y).scatter(; y)","category":"page"},{"location":"settings/#Settings","page":"Settings","title":"Settings","text":"","category":"section"},{"location":"settings/","page":"Settings","title":"Settings","text":"Occasionally the PlotlyLight.presets aren't enough.  Low level user-configurable settings are available in PlotlyLight.settings:","category":"page"},{"location":"settings/","page":"Settings","title":"Settings","text":"PlotlyLight.settings.src::Cobweb.Node           # plotly.js script loader\nPlotlyLight.settings.div::Cobweb.Node           # The plot-div\nPlotlyLight.settings.layout::EasyConfig.Config  # default `layout` for all plots\nPlotlyLight.settings.config::EasyConfig.Config  # default `config` for all plots\nPlotlyLight.settings.reuse_preview::Bool        # In the REPL, open plots in same page (true, the default) or different pages.","category":"page"},{"location":"settings/","page":"Settings","title":"Settings","text":"Check out e.g. PlotlyLight.Settings().src to examine default values.","category":"page"},{"location":"templates/#Templates","page":"Templates","title":"Templates","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"Templates are set by using the preset.template.<template>! family of functions:","category":"page"},{"location":"templates/","page":"Templates","title":"Templates","text":"using PlotlyLight\n\nkeys(PlotlyLight.preset.template)","category":"page"},{"location":"templates/","page":"Templates","title":"Templates","text":"We'll use the following plot to demonstrate each template:","category":"page"},{"location":"templates/","page":"Templates","title":"Templates","text":"plt = plot.bar(y = randn(10))\n\nnothing # hide","category":"page"},{"location":"templates/#none!()","page":"Templates","title":"none!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.none!()\nplt  # hide","category":"page"},{"location":"templates/#ggplot2!()","page":"Templates","title":"ggplot2!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.ggplot2!()\nplt  # hide","category":"page"},{"location":"templates/#gridon!()","page":"Templates","title":"gridon!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.gridon!()\nplt  # hide","category":"page"},{"location":"templates/#plotly!()","page":"Templates","title":"plotly!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.plotly!()\nplt  # hide","category":"page"},{"location":"templates/#plotly_dark!()","page":"Templates","title":"plotly_dark!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.plotly_dark!()\nplt  # hide","category":"page"},{"location":"templates/#plotly_white!()","page":"Templates","title":"plotly_white!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.plotly_white!()\nplt  # hide","category":"page"},{"location":"templates/#presentation!()","page":"Templates","title":"presentation!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.presentation!()\nplt  # hide","category":"page"},{"location":"templates/#seaborn!()","page":"Templates","title":"seaborn!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.seaborn!()\nplt  # hide","category":"page"},{"location":"templates/#simple_white!()","page":"Templates","title":"simple_white!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.simple_white!()\nplt  # hide","category":"page"},{"location":"templates/#xgridoff!()","page":"Templates","title":"xgridoff!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.xgridoff!()\nplt  # hide","category":"page"},{"location":"templates/#ygridoff!()","page":"Templates","title":"ygridoff!()","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"preset.template.ygridoff!()\nplt  # hide","category":"page"},{"location":"templates/#Custom-Template","page":"Templates","title":"Custom Template","text":"","category":"section"},{"location":"templates/","page":"Templates","title":"Templates","text":"To create your own template, simply provide any JSON3-writeable object to PlotlyLight.settings.layout.template.  Here's an example:","category":"page"},{"location":"templates/","page":"Templates","title":"Templates","text":"my_template = Config()\nmy_template.layout.title.text = \"This Title Will be in Every Plot!\"\n\nPlotlyLight.settings.layout.template = my_template\n\nplt  # hide","category":"page"},{"location":"#PlotlyLight.jl","page":"PlotlyLight.jl","title":"PlotlyLight.jl","text":"","category":"section"},{"location":"","page":"PlotlyLight.jl","title":"PlotlyLight.jl","text":"PlotlyLight.jl is a speedy lightweight interface for creating Plotly.js plots from Julia.","category":"page"},{"location":"#Features","page":"PlotlyLight.jl","title":"✨ Features","text":"","category":"section"},{"location":"","page":"PlotlyLight.jl","title":"PlotlyLight.jl","text":"🚀 Fastest time-to-first-plot in Julia!\n🌐 Use the Plotly.js Javascript documentation directly.  No magic syntax: Just JSON3.write.\n📂 Set deeply-nested keys easily, e.g. myplot.layout.xaxis.title.font.family = \"Arial\".\n📊 The Same built-in themes as Plotly's python package.","category":"page"},{"location":"#Quickstart","page":"PlotlyLight.jl","title":"🚀 Quickstart","text":"","category":"section"},{"location":"","page":"PlotlyLight.jl","title":"PlotlyLight.jl","text":"using PlotlyLight\n\n# Change template\npreset.template.plotly_dark!()\n\n# Make Plot\np = plot(x = 1:20, y = cumsum(randn(20)), type=\"scatter\", mode=\"lines+markers\")\n\n# Make changes\np.layout.title.text = \"My Title!\"\n\n# Re-display to see updated plot\np","category":"page"}]
}
