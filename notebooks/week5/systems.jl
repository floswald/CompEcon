### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ c3572e14-c058-455c-96c0-6324970af323
using NLsolve

# ╔═╡ 84674032-4848-11ec-3ead-092daf45ee6a
md"""
# Solving Systems of Equations

>This is a simplified version of our paper [Structural Change, Land Use and Urban Expansion](https://floswald.github.io/publication/landuse/) by Coeurdacier, Oswald and Teignier. I am using this only to illustrate the steps involved to solve a system of equations.

## A Model of Land Use and Housing

* There are 2 sectors, Urban and Rural, each producing one good. We take the urban good as the numeraire good and assign relative price $p$ to the rural good.
* There are $L$ workers: $L_r$ rural workers and $L_u$ urban workers.
* The wage is identical in both sectors.
* Land can be use for either Rural Production or to live on.
* People consume rural, urban and housing goods. The housing good is provided by a developer who makes zero profit. He buys land at unit price $\rho$ and combines it with urban good to produce housing services. Those get rented out to people at unit price $q$.
* There is *no notion of space*, i.e. people do *not* have to commute. Hence, a key mechanism from our full model is missing.

## preferences

$$U = c_r^{\nu (1-\gamma)} c_u^{(1-\nu) (1-\gamma)} h^\gamma$$

budget

$$p c_r + c_u + q h= w + r$$

where $w$ is wage, $r$ is land rents which are given back to each individual and $q$ is the rental price of housing.

## Expenditure

maximizing U wrt budget gives expenditure on each good

$$\begin{align}
c_u &=(1-\nu) (1-\gamma) (w + r)\\
c_r &=\nu (1-\gamma) (w + r) / q\\
h   &=\gamma (w + r) / q\\
\end{align}$$
"""

# ╔═╡ 607a4845-02f1-4bc0-8e44-6951d33c4367
md"""
## Production

$$\begin{align}
Y_u &=\theta_u L_u\\
Y_r &=\theta_r (L_r^\alpha S_r^{1-\alpha})
\end{align}$$

The Urban firm has profits $1 \times Y_u - w L_u= \theta_u L_u - w L_u$, hence has an optimality condition

$$\theta_u = w$$

The rural firm has profit $p Y_r - w L_r - \rho S_r$ which it maximizes. FOCs

$$\begin{align}
w &= p \alpha \theta_r L_r^{\alpha-1} S_r^{1-\alpha}\\
\rho &= p (1-\alpha) \theta_r L_r^{\alpha} S_r^{-\alpha}\\
\end{align}$$

From the first condition we obtain the relative price of rural good:
$$p = \frac{w}{\alpha \theta_r} \left( \frac{L_r}{S_r} \right)^{1-\alpha}$$

while by combingin both we get a condition for the amount of land used in rural production

$$S_r = \frac{w}{\rho} \frac{1-\alpha}{\alpha} L_r$$
"""

# ╔═╡ 4a6cbff6-3c1a-414a-a866-599cb5df177c
md"""
## Housing Supply

The housing developer will supply $H$ units of housing in any location at a cost of 

$$\frac{H^{1+1/\epsilon}}{1+1/\epsilon}$$

which they will pay for in terms of numeraire (urban) good. Their profits are thus

$$\pi = q H - \frac{H^{1+1/\epsilon}}{1+1/\epsilon} - \rho$$

Maximizing wrt $H$ yields optimal housing supply function

$$H^* = q^\epsilon$$

Free entry implies $\pi = 0$, hence we get

$$\begin{align}
q^{1+\epsilon} - \frac{q^{1+\epsilon}}{1+1/\epsilon} &= \\
 \frac{q^{1+\epsilon}}{1+\epsilon} &=\rho
\end{align}$$

This expression determines housing prices $q$ as a function of the land price $\rho$.
"""

# ╔═╡ c5255877-e38d-4614-9ea6-7678d13ebb06
md"""
## Housing and Land Market Clearing

* Both rural and urban workers consume housing space $h$ as per above.
* In both urban and rural area, we need that supply equals housing demand.

$$\begin{align}
\text{supply} & =  \text{demand} \\
 H^* = q^{\epsilon} & = L_u h =L_u \gamma (w + r) / q\\
q^{1+\epsilon} & = L_u \gamma (w + r) \\
\rho (1+\epsilon) & = L_u \gamma (w + r) \\
\end{align}$$
where the last equality follows from the previous section. Given that $L_u \gamma (w + r)$ represents total demand for housing space in the urban sector, and given that in urban we *only* have space for housing, this defines the size of the city $\phi$:

$$\phi = \frac{L_u \gamma_\epsilon (w + r)}{\rho}$$ where $\gamma_\epsilon = \gamma / (1+\epsilon)$. Similarly in the rural sector, we define space for housing as $S_{rh}$ and obtain

$$S_{rh} = \frac{L_r \gamma_\epsilon (w + r)}{\rho}$$
"""

# ╔═╡ 59fb80db-10c5-4cca-8f85-be7599320242
md"""
## Market Clearing and Feasibility Constraint

We have to markets to clear: the labor market and the housing/land market. The labor market is easy, we need to make sure that

$$L = L_u + L_r$$

Of course the total of land uses cannot exceed available land, $S$, so we need to impose that

$$S_r + S_{rh} + \phi = S$$

Finally, we need a condition that tells us how big the lump sum land rent disbursement will be. The total amount of land rent collected is $\rho  (S_r + S_{rh} + \phi)$, hence the per capita rebate will be

$$r = \rho  (S_r + S_{rh} + \phi) / L$$

The Feasibility constraint relates to the fact that we chose the urban good to serve as the numeraire good in this economy. So we need to make sure that there is enough urban good produced to satisfy all the demands for it in this world. Notice that we need urban good here for direct consumption ($c_u$) *and* to build houses (!). 

The construction cost to be paid for in numeraire by the developer *per unit of housing* is

$$\frac{H^{1+1/\epsilon}}{1+1/\epsilon}$$

and notice that $H^{1+1/\epsilon} = H H^{1/\epsilon}$, further that $q = H^{1/\epsilon}$ as per optimal housing supply, and thus 

$$\frac{H^{1+1/\epsilon}}{1+1/\epsilon} = \frac{Hq}{1+1/\epsilon} = \frac{\epsilon}{1+\epsilon} Hq = \frac{\epsilon}{1+\epsilon} q^{1+\epsilon} =\frac{\epsilon}{1+\epsilon} (1+\epsilon) \rho = \epsilon \rho.$$

That means that we have a feasiblity constraint of

$$Y_u/L = c_u + \rho \epsilon (S_{rh} + \phi) / L$$
 
"""

# ╔═╡ 72c5f230-0e15-4baf-bd2a-91fea0a9c434
md"""
## Solving This Model

The above model is described by the consumption rules for consmers, the first order conditions for the rural firm and the constraints we have placed on the solution arising from finite land use. 

How to solve this model?

One approach is to realize that given $L,S$ and parameters $\alpha, \gamma,\nu$, the only things that determine the outcomes here are 

1. the number of people in either sector, $L_r$, say
2. the value of land, $\rho$. 

If $L_r$ is smaller, we need more space for the city, but we have less output in the rural sector. If $\rho$ is larger, housing demand will go down, but rent rebates $r$ will go up, also, the city will be smaller. Notice that all other quantities in the model are implied once the pair $(\rho, L_r)$ have been chosen.

Therefore, our approach will be to propose two numbers $(\rho, L_r)$, determine all quantities in the model, and check whether we clear the markets. Notice, that we can focus only on the land market clearing and the feasibility constraint, as all others are embedded in those.
"""

# ╔═╡ c104e2ec-67f5-4e8c-9bfb-fba51b47cd59
par = (α = 0.1, γ = 0.3, ν = 0.2, θᵤ = 1.0, θᵣ = 1.0, L = 2.0, S = 1.0, ϵ = 4.0)

# ╔═╡ 4cd4c450-237c-464a-bd6b-0cd325a97a30
function compute_model!(F::Vector,x::Vector,p::NamedTuple)
	# notice we call p the parameters and pr the relative price of rural good.
	if any(x .< 0)
		F[:] .= 100.0
	else
		# define choice variables
		ρ = x[1]
		Lᵣ = x[2]
	
		# implied quantities
		Lᵤ = p.L - Lᵣ   # this clears the labor market
		w = p.θᵤ  # wage in both sectors equal to that
		Sᵣ = w / ρ * ((1-p.α)/p.α ) * Lᵣ  # from rural FOC
		pr = w / (p.α * p.θᵣ) * (Lᵣ / Sᵣ)^(1-p.α)  # also
		r = ρ * (p.S / p.L)  # total rent collected per capita
	
		# housing demand in each sector
		γϵ = par.γ / (1+p.ϵ)
		ϕ   = Lᵤ * γϵ * (w + r) / ρ  # space need for city housing
		Sᵣₕ = Lᵣ * γϵ * (w + r) / ρ  # space for rural housing

		# total construction costs
		ccost = p.ϵ * ρ * (Sᵣₕ + ϕ)
		
		# constraints to obey. each equation should be (close to) zero
		# 1. feasibilty on urban good:
		# (urban good consumption) + (construction cost) = urban production
		# notice this is in per capita terms
		F[1] = (1 - p.γ) * (1 - p.ν) * (w + r) + ccost / p.L - Lᵤ * p.θᵤ / p.L
		# 2. Land market clearing
		F[2] = Sᵣ + Sᵣₕ + ϕ - p.S
	end

	# returns nothing but modified F

end

# ╔═╡ 98c1305e-ad91-46a0-a910-47c48512e2c8
r = nlsolve( (F,x) -> compute_model!(F,x,par), [1.0, 0.5] );

# ╔═╡ 788fc4e1-836d-4da8-a3fc-8865a3442f31
function getresult(x,p)
	ρ = x[1]
	Lᵣ = x[2]
	γϵ = p.γ / (1+p.ϵ)

	# implied quantities
	Lᵤ = p.L - Lᵣ   # this clears the labor market
	w = p.θᵤ  # wage in both sectors equal to that
	Sᵣ = w / ρ * ((1-p.α)/p.α ) * Lᵣ  # from rural FOC
	pr = w / (p.α * p.θᵣ) * (Lᵣ / Sᵣ)^(1-p.α)  # also
	r = ρ * (p.S / p.L)  # total rent collected per capita

	# housing demand in each sector
	ϕ   = Lᵤ * γϵ * (w + r) / ρ  # space need for city housing
	Sᵣₕ = Lᵣ * γϵ * (w + r) / ρ  # space for rural housing

	# check land market clearing
	Yᵣ = p.θᵣ * (Lᵣ^p.α * Sᵣ^(1-p.α) )
	check = (1 - p.γ) * p.ν * (w + r) - pr * Yᵣ / p.L

	(ρ = ρ, Lᵤ = Lᵤ, Lᵣ = Lᵣ, ϕ = ϕ, Sᵣₕ = Sᵣₕ, Sᵣ = Sᵣ, p = p, pr = pr, walrascheck = check)

end

# ╔═╡ f8804a53-92e4-47ad-82c8-3914e49f00ed
getresult(r.zero,par)

# ╔═╡ aa32ac11-58b7-454d-bdec-7ca76d258468


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
NLsolve = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"

[compat]
NLsolve = "~4.5.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "40d7e5842851675cd76492739a6f724047e24525"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cd8b948862abee8f3d3e9b73a102a9ca924debb0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.2.0"

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "017fcb757f8e921fb44ee063a7aafe5f89b86dd1"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.18.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

    [deps.Distances.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Setfield"]
git-tree-sha1 = "f089ab1f834470c525562030c8cfde4025d5e915"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.27.0"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffSparseArraysExt = "SparseArrays"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "e4c3be53733db1051cc15ecf573b1042b3a712a1"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.3.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "c5391c6ace3bc430ca630251d02ea9687169ca68"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"
"""

# ╔═╡ Cell order:
# ╟─84674032-4848-11ec-3ead-092daf45ee6a
# ╟─607a4845-02f1-4bc0-8e44-6951d33c4367
# ╟─4a6cbff6-3c1a-414a-a866-599cb5df177c
# ╟─c5255877-e38d-4614-9ea6-7678d13ebb06
# ╟─59fb80db-10c5-4cca-8f85-be7599320242
# ╟─72c5f230-0e15-4baf-bd2a-91fea0a9c434
# ╠═c3572e14-c058-455c-96c0-6324970af323
# ╠═4cd4c450-237c-464a-bd6b-0cd325a97a30
# ╠═c104e2ec-67f5-4e8c-9bfb-fba51b47cd59
# ╠═98c1305e-ad91-46a0-a910-47c48512e2c8
# ╠═f8804a53-92e4-47ad-82c8-3914e49f00ed
# ╟─788fc4e1-836d-4da8-a3fc-8865a3442f31
# ╠═aa32ac11-58b7-454d-bdec-7ca76d258468
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
