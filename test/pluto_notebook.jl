### A Pluto.jl notebook ###
# v0.18.2

using Markdown
using InteractiveUtils

# ╔═╡ 14f719cd-ffdc-4d9b-83f4-efd7e7b54c82
using Pkg; Pkg.activate(".")

# ╔═╡ c27879d8-9702-11eb-3050-f1c4477273fe
using PlotlyLight

# ╔═╡ 301cbfcf-88f6-4eed-9b75-6cc193242d12
PlotlyLight.Defaults.parent_style[] = "height: 400px;"

# ╔═╡ e2dedee2-9702-11eb-1364-118bcaff2607
Plot(Config(x=1:50,y=randn(50), type="bar"))

# ╔═╡ Cell order:
# ╠═14f719cd-ffdc-4d9b-83f4-efd7e7b54c82
# ╠═c27879d8-9702-11eb-3050-f1c4477273fe
# ╠═301cbfcf-88f6-4eed-9b75-6cc193242d12
# ╠═e2dedee2-9702-11eb-1364-118bcaff2607
