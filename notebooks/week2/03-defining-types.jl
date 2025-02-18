### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 082b1918-678b-11eb-1a78-2316091d6272
using PlutoUI

# ╔═╡ f855b1c0-670e-11eb-2a81-4de0846c0d93
using Dates   

# ╔═╡ 9e2fc76c-6727-11eb-2cab-7f81bdfb7343
using Distributions

# ╔═╡ 4723a50e-f6d1-11ea-0b1c-3d33a9b92f87
md"# Defining new types"

# ╔═╡ 91ba119e-670a-11eb-0bb2-15ac7192e7e7
html"<button onclick='present()'>present</button>"

# ╔═╡ 92cef0a4-670a-11eb-2df2-5b31a1602299
md"
# Types in Julia

* Julia has a very rich type system
* The [manual](https://docs.julialang.org/en/v1/manual/types/) is very good again.
* What's really cool with julia is the easy with which we can declare new types.
"

# ╔═╡ d19385e0-678a-11eb-3156-c51cb20abe3e
md"
# Julia Base Type System

Here is the basics of the `Number` type in julia. This is just one part of the type system. 

At the very top of all types (not shown) is the `DataType` `Any`, from which all others are derived.
"

# ╔═╡ e97a60e6-678c-11eb-0b37-fd80c3f0e8aa
Resource("https://upload.wikimedia.org/wikipedia/commons/d/d9/Julia-number-type-hierarchy.svg")

# ╔═╡ aa5adfba-678e-11eb-02e4-210b8b753e21
subtypes(Integer)

# ╔═╡ bff062f0-678e-11eb-131d-e11297e36d4b
supertypes(Integer)

# ╔═╡ bed2a154-f6d1-11ea-0812-1f5c628a9785
md"
# Why define new types?

Here is an example. Many mathematical and other objects can be represented by a pair of numbers, for example:

  - a rectangle has a width and a height;
  - a complex number has a real and imaginary part;
  - a position vector in 2D space has 2 components.

Each of these could naturally be represented by a pair $(x, y)$ of two numbers, or in Julia as a tuple:"

# ╔═╡ 81113974-f6d2-11ea-2ef8-fb2930402a74
begin 
	rectangle = (3, 4)   # (width, height)
	c = (3, 4)   # 3 + 4im
	x = (3, 4)   # position vector
end

# ╔═╡ a4296474-6714-11eb-0500-1d888fe18b51
md"#"

# ╔═╡ ac321d80-f6d2-11ea-2951-676e6e1aef56
md"


But from the fact that we have to remind ourselves using comments what each of these numbers represents, and the fact that they all look the same but should behave very differently, that there is a problem here. 

For example, we would like to have a function `width` that returns the width of a rectangle, but it makes no sense to apply that to a complex number.

In other words, we need a way to be able to distinguish between different *types of* objects with different *behaviours*.
"

# ╔═╡ 9a168a92-670b-11eb-34af-0121d1a252bd
md"
# Defining a New type
"

# ╔═╡ 66abc04e-f6d8-11ea-27d8-9f8b14659755
struct Rectangle
	width::Float64
	height::Float64
end

# ╔═╡ 7571be3a-f6d8-11ea-174c-9d65d5185153
md"""The keyword `struct` (short for "structure") tells Julia that we are defining a new type. We list the field names together with **type annotations** using `::` that specify which type each field can contain."""

# ╔═╡ 9f384ac2-f6d8-11ea-297e-4bf09acf9fe7
md"Once Julia has this template, we can create objects which have that type as follows:"

# ╔═╡ b0dac516-f6d8-11ea-1bdb-b59723107206
r = Rectangle(1, 2.5)

# ╔═╡ af236602-5ffa-11eb-0bec-cd944a602c70
md"the function `Rectangle` with identical name to our type is called a **constructor**."

# ╔═╡ b98b9faa-f6d8-11ea-3610-bf8a84af2b5a
md"
#

We can check that `r` is now a variable whose type is `Rectangle`, in other words `r` *is a* `Rectangle`:"

# ╔═╡ cf1c4aae-f6d8-11ea-3200-c5fb458c7c09
typeof(r)

# ╔═╡ d0749974-f6d8-11ea-2f41-074b6744f3d5
r isa Rectangle

# ╔═╡ d372342c-f6d8-11ea-10cd-573cf7eab992
md"""We can  extract from `r` the information about the values of the fields that it contains using "`.`": """

# ╔═╡ dd8f9e88-f6d8-11ea-15e3-f17f4af0d81b
r.width

# ╔═╡ e3e70064-f6d8-11ea-22fd-892bbc567ed4
r.height

# ╔═╡ e582eb02-f6d8-11ea-1fcc-89bbc9dfbb07
md"

#

We can create a new `Rectangle` with its own width and height:"

# ╔═╡ f2ed18b4-f6d8-11ea-3bc7-0b82eb5e8dc0
r2 = Rectangle(3.0, 4.0)

# ╔═╡ f9d192fe-f6d8-11ea-138d-3dcdff33c034
md"You should check that this does *not* affect the `width` and `height` variables belonging to `r`."

# ╔═╡ 6085144c-f6db-11ea-19fe-ed46dafb4562
md"Types like this are often called **composite types**; they consist of aggregating, or collecting together, different pieces of information that belong to a given object."

# ╔═╡ 1840898e-f6d9-11ea-3035-bb4dac496834
md"

## Mutable vs immutable


Now suppose we want to change the width of `r`. We would naturally try the following:

"

# ╔═╡ 63f76d28-f6d9-11ea-071c-458528c36008
r.width = 10

# ╔═╡ 68934a2a-f6d9-11ea-37ea-850304f6d3d6
md"But Julia complains that fields of objects of type `Rectangle` *cannot* be modified. This is because `struct` makes **immutable** (i.e. unchangeable) objects. The reason for this is that these usually lead to *faster code*."

# ╔═╡ a38a0164-f6d9-11ea-2e1d-a7a6e2106d0b
md"If we really want to have a **mutable** (modifiable) object, we can declare it using `mutable struct` instead of `struct` -- try it!"

# ╔═╡ 3fa7d8e2-f6d9-11ea-2e82-9f59b5cb9424
md"## Functions on types

We can now define functions that act only on given types. To restrict a given function argument to only accept objects of a certain type, we add a type annotation:"

# ╔═╡ 8c4beb6e-f6db-11ea-12d1-cf450181363b
width(r::Rectangle) = r.width

# ╔═╡ 91e21d28-f6db-11ea-1b0f-336719682f28
width(r)

# ╔═╡ 2ef7392e-f6dc-11ea-00e4-770cdf9a102e
md"Applying the function to objects of other types gives an error:"

# ╔═╡ 9371209e-f6db-11ea-3ba2-c3597d42d8ed
width(3)   # throws an error

# ╔═╡ d1166a30-670b-11eb-320d-9b13b96824fb
md"#"

# ╔═╡ b916acb4-f6dc-11ea-3cdf-2b8ab3c34e03
md"""It is common in Julia to have "generic" versions of functions that apply to any object, and then specialised versions that apply only to certain types.

For example, we might want to define an `area` function with the correct definition for `Rectangle`s, but it might be convenient to fall back to a version that just returns the value itself for any other type:"""

# ╔═╡ 6fe1b332-f6dd-11ea-39d4-1954aeda6f08
begin
	# two different function bodies for the same function name!
	area(r::Rectangle) = r.width * r.height
	area(x) = x
end

# ╔═╡ c34355b8-f6dd-11ea-1089-cf5be2117ba8
area(r)

# ╔═╡ c4a7fae6-f6dd-11ea-1851-3bd445ebf677
area(17)

# ╔═╡ c83180d8-f6dd-11ea-32f7-634b781070f1
md"

#

But since we didn't restrict the type in the second method, we also have"

# ╔═╡ d3dc64b6-f6dd-11ea-1273-7fb3957e4964
area("hello")

# ╔═╡ 6d7ca590-f6f5-11ea-0a00-6128f971b546
area

# ╔═╡ d6e5a276-f6dd-11ea-34aa-b9e2d3805364
md"which does not make much sense."

# ╔═╡ 79fa562e-f6dd-11ea-2e97-df3c62c83685
md"Note that these are different versions of the function with the *same* function name; each version acting on different (combinations of) types is called a **method** of the (generic) function."

# ╔═╡ a1d2ae6c-f6dd-11ea-0216-ef9db5d9e29b
md"Suppose that later we create a `Circle` type. We can then just add a new method `area(c::Circle)` with the corresponding definition, and Julia will continue to choose the correct version (method) when we call `area(x)`, depending on the type of `x`.

[Note that at the time of writing, Pluto requires all methods of a function to be defined in the same cell.]
"

# ╔═╡ 41e21994-f6de-11ea-0e5c-0515a3a52f6f
md"## Multiple dispatch


The act of choosing which function to call based on the type of the arguments that are passed to the function is called **dispatch**. A central feature of Julia is **multiple dispatch**: this choice is made based on the types of *all* the arguments to a function.

For example, the following three calls to the `+` function each call *different* methods, defined in different locations. Click on the links to see the definition of each method in the Julia source code on GitHub!"

# ╔═╡ 814e328c-f6de-11ea-13c0-d1b97714c4f3
cc = 3 + 4im

# ╔═╡ cdd3e14e-f6f5-11ea-15e2-bd309e658823
cc + cc

# ╔═╡ e01e26f2-f6f5-11ea-13b0-95413a6f7290
+

# ╔═╡ 84cae75c-f6de-11ea-3cd4-1b263e34771f
@which cc + cc

# ╔═╡ 8ac4904a-f6de-11ea-105b-8925016ca6d5
@which cc + 3

# ╔═╡ 8cd9f438-f6de-11ea-2b58-93bbb860a005
@which 3 + cc

# ╔═╡ 549c63e4-670c-11eb-2574-55611c612e43
md"
# A `WorkerSpell` Type

* Let's look at something a bit more relevant for us
* [Robin, Piyapromdee and Lentz](https://www.dropbox.com/s/4ylyn1v7fe0jmn1/Piyapromdee_Anatomy.pdf?dl=0) write *On Worker and Firm Heterogeneity in Wages and Employment Mobility: Evidence from Danish Register Data*
* Their data are *worker spells* at firms in appendix E.1
* They have $I = 4,000,000$ workers and $J=400,000$ firms

# What is a `Spell`?

It's a period of time that a worker spent at a certain firm, earning a certain wage.

1. Start/end date of spell
1. ID of worker $i$ and firm $j$
1. A vector of wages for each year in the spell $w_i$
1. An indicator whether the worker changes firm after this spell, $D_{it}$

# Why Not a Spreadsheet?

* They have a likelihood function to estimate which encodes for worker $i$ the likelihood of observing the data

$$(w_{it}, j_{it}, x_{it})_{t=1}^{T_i}$$

* Simplifying a bit, this looks for worker $i$ like

$$L_i = \Pi_{t=1}^{T_i} f(w_{it} | j_{it}, x_{it}) \times \Pi_{t=1}^{T_i} S(i,j_{it},x_{it})^{1-D_{it}} M(j'|i,j_{it},x_{it})^{D_{it}}$$

* Can you see the $T_i$ there? 
* 👉different workers have differently long spells!
"

# ╔═╡ 1a5ca388-670e-11eb-0321-51c90fcbef35
md"## Defining a `Spell`"

# ╔═╡ 0b9cb9f4-670f-11eb-338a-5d6c16c99248
mutable struct Spell 
	start       :: Date
	stop        :: Date
	duration    :: Week
	firm        :: Int   # ∈ 1,2,...,L+1
	wage        :: Float64
	change_firm :: Bool   # switch firm after this spell?
	function Spell(t0::Date,fid::Int)  # this is the `inner constructor` method
		this = new()
		this.start = t0
		this.stop = t0
		this.duration = Week(0)
		this.firm = fid
		this.wage = 0.0
		this.change_firm = false
		return this 
	end
end

# ╔═╡ b083edfe-67a3-11eb-0924-4f44343ffceb


# ╔═╡ c63a5110-670d-11eb-0502-5fc01e7d59d5
md"#

Let's create one of those:
"

# ╔═╡ 320edd04-670f-11eb-2a98-353ca1501537
sp = Spell(Date("2015-03-21"), 34)

# ╔═╡ 3d2a7a92-670f-11eb-265c-77d1d30af869
md"ok, great. now we need a way to set some infos on this type. In particular, we want to record the wage the worker got, and how long the spell lasted. Here is function to call at the end of a spell:"

# ╔═╡ 50b68470-670f-11eb-2fd2-e9ac408adad2
md"#"

# ╔═╡ 52ecd1f4-670f-11eb-1843-7380dcf1ee54
function finish!(s::Spell,w::Float64,d::Week)
    @assert d >= Week(0)
    s.stop = s.start + d
    s.duration = d
    s.wage = w
end

# ╔═╡ 6359fe04-670f-11eb-1b4e-7d4193109484


# ╔═╡ 5afaa42c-670f-11eb-1e96-afa2a6466656
md"
let's say that particular spell lasted for 14 weeks and was characterised by a wage of 100.1 Euros
"

# ╔═╡ 5f97e3f8-670f-11eb-2b7b-e54286c0cbb3
finish!(sp, 100.1, Week(14))

# ╔═╡ 622172a6-670f-11eb-1910-8fe1652cf65b
sp

# ╔═╡ 666fba34-670f-11eb-19b0-6f5046362154
md"# Workers

Next, we need a worker. Workers accumulate `Spells`.
"

# ╔═╡ ddfab162-670f-11eb-1bff-037e2e001178
mutable struct Worker
    id :: Int   # name
    T  :: Int   # number of WEEKS observed
    l  :: Int   # current firm ∈ 1,2,...,L+1
    spells :: Vector{Spell}  # an array of type Spell
    function Worker(id,T,start::Date,l::Int)
        this = new()
        this.id = id
        this.T = T 
        this.l = l
        this.spells = Spell[Spell(start,l)]
        return this
    end
end

# ╔═╡ 1b971326-6710-11eb-2b7b-eba640d686ba
md"
#

Let's create a worker and make him work at a new firm:
"

# ╔═╡ 27629a70-6710-11eb-0527-2fe3a1fd89b5
w0 = Worker(13, 18, Dates.today(), 3)

# ╔═╡ 7119d84c-6710-11eb-0afd-b3695a395be1
md"and let's say that first spell lasts for 15 weeks at 500 Euros per week"

# ╔═╡ a5ec451e-6710-11eb-0b52-95ef2e17082e
finish!(w0.spells[end], 500.0,  Week(15))

# ╔═╡ d8ed9ee0-6710-11eb-33a0-d5648e5e3891
w0.spells

# ╔═╡ 5291c44c-6725-11eb-3508-5113b947e07b
md"
# Useful?

When we want to evaluate the function $L_i$ above, we need to sum over each workers $T_i$ weeks of work." 

# ╔═╡ e5635fae-6725-11eb-3bcc-491220b5e24a
begin
	N = 5 # workers
	F = 2 # firms
end

# ╔═╡ b8c625c8-6725-11eb-3853-2916ae6f4af5
begin
	starts = rand(Date(2014,1,29):Week(1):Dates.today(),N)
	Ts = rand(5:10,N)
	js = rand(1:F,N)
	wrks = [Worker(id,Ts[id],starts[id],js[id]) for id in 1:N]
end

# ╔═╡ f521adde-6726-11eb-1904-5d4a8cd90746
md"
#
"

# ╔═╡ fa1c3a34-6726-11eb-333b-21b7f91d524c
md"
now let's set some wages on those workers. Let's say with prob 0.5 they have 2 spells:
"

# ╔═╡ a2df9a4e-6727-11eb-129b-9bd913058795
Ln = LogNormal(1.0,	0.1)

# ╔═╡ 050b2ba8-6727-11eb-1a9a-738f657d78e6
begin
	# an empty array of type worker
	dates = Date(2014,1,29):Week(1):Dates.today()
    workers = Worker[]
	for iw in 1:N
		w = Worker(iw,rand(5:10),rand(dates),rand(1:F))
		dur = 0 # start with zero weeks
		for tx in 1:w.T
			dur += 1 # increase duration
			if rand() < 0.5
				# switches to another firm
				finish!(w.spells[end], rand(Ln), Week(dur))
				dur = 0 # reset duration
				w.spells[end].change_firm = true
				# new spell starts on the same day!
				newfirm = rand(1:F)
				push!(w.spells, Spell(w.spells[end].stop,newfirm))
				w.l = newfirm
			else
				# nothing to record: stay at same firm
			end
			if tx == w.T
				# finish last spell
				finish!(w.spells[end], rand(Ln), Week(dur))
			end
		end
		push!(workers,w)
	end
end

# ╔═╡ b8ccbe4e-6728-11eb-1f1f-7367e85017c6
workers

# ╔═╡ e2b3e500-6728-11eb-3b01-f769c8a4c799
md"# Summing over the Likelihood

Then, finally, we can iterate over our array of workers like this
"

# ╔═╡ fc2f870c-6728-11eb-06ff-ab6affcfaefe
begin
	L0 = 0.0
	for iw in workers
		# loops over multiple spells
		# for each worker
		for (idx, sp) in enumerate(iw.spells)
			L0 += logpdf(Ln, sp.wage)
		end						
	end
end

# ╔═╡ 5d72de64-672a-11eb-2b64-e73f79c72d9c
L0

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Distributions = "~0.25.23"
PlutoUI = "~0.7.17"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "3fae482b29d75a8c7e7a3595466946889096e26f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "03aa5d44647eaec98e1920635cdfed5d5560a8b9"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.117"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "2bd56245074fab4015b9174f24ceba8293209053"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.27"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
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

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

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

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "966b85253e959ea89c53a9abebbf2e964fbf593b"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.32"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "7e71a55b87222942f0f9337be62e26b1f103d3e4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.61"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
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

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─4723a50e-f6d1-11ea-0b1c-3d33a9b92f87
# ╠═91ba119e-670a-11eb-0bb2-15ac7192e7e7
# ╟─92cef0a4-670a-11eb-2df2-5b31a1602299
# ╟─d19385e0-678a-11eb-3156-c51cb20abe3e
# ╟─082b1918-678b-11eb-1a78-2316091d6272
# ╠═e97a60e6-678c-11eb-0b37-fd80c3f0e8aa
# ╠═aa5adfba-678e-11eb-02e4-210b8b753e21
# ╠═bff062f0-678e-11eb-131d-e11297e36d4b
# ╟─bed2a154-f6d1-11ea-0812-1f5c628a9785
# ╠═81113974-f6d2-11ea-2ef8-fb2930402a74
# ╟─a4296474-6714-11eb-0500-1d888fe18b51
# ╟─ac321d80-f6d2-11ea-2951-676e6e1aef56
# ╟─9a168a92-670b-11eb-34af-0121d1a252bd
# ╠═66abc04e-f6d8-11ea-27d8-9f8b14659755
# ╟─7571be3a-f6d8-11ea-174c-9d65d5185153
# ╟─9f384ac2-f6d8-11ea-297e-4bf09acf9fe7
# ╠═b0dac516-f6d8-11ea-1bdb-b59723107206
# ╟─af236602-5ffa-11eb-0bec-cd944a602c70
# ╟─b98b9faa-f6d8-11ea-3610-bf8a84af2b5a
# ╠═cf1c4aae-f6d8-11ea-3200-c5fb458c7c09
# ╠═d0749974-f6d8-11ea-2f41-074b6744f3d5
# ╟─d372342c-f6d8-11ea-10cd-573cf7eab992
# ╠═dd8f9e88-f6d8-11ea-15e3-f17f4af0d81b
# ╠═e3e70064-f6d8-11ea-22fd-892bbc567ed4
# ╟─e582eb02-f6d8-11ea-1fcc-89bbc9dfbb07
# ╠═f2ed18b4-f6d8-11ea-3bc7-0b82eb5e8dc0
# ╟─f9d192fe-f6d8-11ea-138d-3dcdff33c034
# ╟─6085144c-f6db-11ea-19fe-ed46dafb4562
# ╟─1840898e-f6d9-11ea-3035-bb4dac496834
# ╠═63f76d28-f6d9-11ea-071c-458528c36008
# ╟─68934a2a-f6d9-11ea-37ea-850304f6d3d6
# ╟─a38a0164-f6d9-11ea-2e1d-a7a6e2106d0b
# ╟─3fa7d8e2-f6d9-11ea-2e82-9f59b5cb9424
# ╠═8c4beb6e-f6db-11ea-12d1-cf450181363b
# ╠═91e21d28-f6db-11ea-1b0f-336719682f28
# ╟─2ef7392e-f6dc-11ea-00e4-770cdf9a102e
# ╠═9371209e-f6db-11ea-3ba2-c3597d42d8ed
# ╟─d1166a30-670b-11eb-320d-9b13b96824fb
# ╟─b916acb4-f6dc-11ea-3cdf-2b8ab3c34e03
# ╠═6fe1b332-f6dd-11ea-39d4-1954aeda6f08
# ╠═c34355b8-f6dd-11ea-1089-cf5be2117ba8
# ╠═c4a7fae6-f6dd-11ea-1851-3bd445ebf677
# ╟─c83180d8-f6dd-11ea-32f7-634b781070f1
# ╠═d3dc64b6-f6dd-11ea-1273-7fb3957e4964
# ╠═6d7ca590-f6f5-11ea-0a00-6128f971b546
# ╟─d6e5a276-f6dd-11ea-34aa-b9e2d3805364
# ╟─79fa562e-f6dd-11ea-2e97-df3c62c83685
# ╟─a1d2ae6c-f6dd-11ea-0216-ef9db5d9e29b
# ╟─41e21994-f6de-11ea-0e5c-0515a3a52f6f
# ╠═814e328c-f6de-11ea-13c0-d1b97714c4f3
# ╠═cdd3e14e-f6f5-11ea-15e2-bd309e658823
# ╠═e01e26f2-f6f5-11ea-13b0-95413a6f7290
# ╠═84cae75c-f6de-11ea-3cd4-1b263e34771f
# ╠═8ac4904a-f6de-11ea-105b-8925016ca6d5
# ╠═8cd9f438-f6de-11ea-2b58-93bbb860a005
# ╟─549c63e4-670c-11eb-2574-55611c612e43
# ╟─1a5ca388-670e-11eb-0321-51c90fcbef35
# ╠═f855b1c0-670e-11eb-2a81-4de0846c0d93
# ╠═0b9cb9f4-670f-11eb-338a-5d6c16c99248
# ╠═b083edfe-67a3-11eb-0924-4f44343ffceb
# ╟─c63a5110-670d-11eb-0502-5fc01e7d59d5
# ╠═320edd04-670f-11eb-2a98-353ca1501537
# ╟─3d2a7a92-670f-11eb-265c-77d1d30af869
# ╟─50b68470-670f-11eb-2fd2-e9ac408adad2
# ╠═52ecd1f4-670f-11eb-1843-7380dcf1ee54
# ╠═6359fe04-670f-11eb-1b4e-7d4193109484
# ╟─5afaa42c-670f-11eb-1e96-afa2a6466656
# ╠═5f97e3f8-670f-11eb-2b7b-e54286c0cbb3
# ╠═622172a6-670f-11eb-1910-8fe1652cf65b
# ╟─666fba34-670f-11eb-19b0-6f5046362154
# ╠═ddfab162-670f-11eb-1bff-037e2e001178
# ╟─1b971326-6710-11eb-2b7b-eba640d686ba
# ╠═27629a70-6710-11eb-0527-2fe3a1fd89b5
# ╟─7119d84c-6710-11eb-0afd-b3695a395be1
# ╠═a5ec451e-6710-11eb-0b52-95ef2e17082e
# ╠═d8ed9ee0-6710-11eb-33a0-d5648e5e3891
# ╟─5291c44c-6725-11eb-3508-5113b947e07b
# ╠═e5635fae-6725-11eb-3bcc-491220b5e24a
# ╠═b8c625c8-6725-11eb-3853-2916ae6f4af5
# ╟─f521adde-6726-11eb-1904-5d4a8cd90746
# ╟─fa1c3a34-6726-11eb-333b-21b7f91d524c
# ╠═9e2fc76c-6727-11eb-2cab-7f81bdfb7343
# ╠═a2df9a4e-6727-11eb-129b-9bd913058795
# ╠═050b2ba8-6727-11eb-1a9a-738f657d78e6
# ╠═b8ccbe4e-6728-11eb-1f1f-7367e85017c6
# ╟─e2b3e500-6728-11eb-3b01-f769c8a4c799
# ╠═fc2f870c-6728-11eb-06ff-ab6affcfaefe
# ╠═5d72de64-672a-11eb-2b64-e73f79c72d9c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
