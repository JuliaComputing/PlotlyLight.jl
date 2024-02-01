### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 14f719cd-ffdc-4d9b-83f4-efd7e7b54c82
using Pkg; Pkg.activate("..")

# ╔═╡ c27879d8-9702-11eb-3050-f1c4477273fe
begin
	using Revise
	using PlotlyLight
end

# ╔═╡ e2dedee2-9702-11eb-1364-118bcaff2607
begin
	PlotlyLight.template_ggplot2!()
	Plot(Config(x=1:50, y=randn(50), type="bar"))
end

# ╔═╡ Cell order:
# ╠═14f719cd-ffdc-4d9b-83f4-efd7e7b54c82
# ╠═c27879d8-9702-11eb-3050-f1c4477273fe
# ╠═e2dedee2-9702-11eb-1364-118bcaff2607
