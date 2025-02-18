### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 34427d6a-8f74-4857-91a3-2526555eebaa
using Dates

# ╔═╡ 32465c0e-fcd4-11ea-1544-df26081c7fa7
md"""
# Functions are objects
"""

# ╔═╡ 65c59b14-fcd7-11ea-2a19-3d084b3bca56
square_root = sqrt

# ╔═╡ 249cf7dc-fcdb-11ea-3630-ed2369d20041
square_root(123)

# ╔═╡ 175cb644-fcd5-11ea-22f2-3f96d6d2e637
md"""
#
"""

# ╔═╡ 6b91914a-fcd4-11ea-0d27-c99e7ef99354
function double(x)
	x * 2
end

# ╔═╡ b5614d1a-fcd4-11ea-19b9-45043b16b332
function half(x)
	x / 2
end

# ╔═╡ 0991e74c-fce3-11ea-0616-336e1d5d83e9
things = [double, half]

# ╔═╡ 10fe7950-fce3-11ea-1ace-e1676961935e
rand(things)(123)

# ╔═╡ 2424dd62-fce3-11ea-14a6-81792a7dee89
function applyboth(f, g, x)
	f(g(x))
end

# ╔═╡ 2fb8117e-fce3-11ea-2492-55e4768f6e37
applyboth(double, half, 10)

# ╔═╡ a34557ac-fce3-11ea-1391-3d0cddd4201b
md"""
# _map_ and _filter_
"""

# ╔═╡ 70aa854a-fce5-11ea-3477-6df2b0ca1d22
struct Skier
	name
	born  # year
	photo
end

# ╔═╡ cbfc5ede-fce3-11ea-2044-15b8a07ef5f2
data = [
	Skier("Tatum Monod", 1991 , md"![](https://snowbrains.com/wp-content/uploads/2019/07/tatum-monod-backflip-.jpg)"),
	Skier("Maude Raymond", 1987, md"![](https://www.armadaskis.com/sites/armada/files/2022-09/Maude_Raymond_gallery_06.jpg)"),
	Skier("Grete Eliassen", 1986, md"![](https://cdn.skimag.com/wp-content/uploads/2017/11/ski1117_boss09_bygrantgunderson-1.jpg)"),
	Skier("Ingrid Backstrom", 1978, md"![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*F5Kiz5DNq_Y0ePBhq_Btug.jpeg)"),
	Skier("Michelle Parker", 1987, md"![](https://www.downdays.eu/wp-content/uploads/2018/04/1_MichelleParker_Cricco_225.jpg)"),
	Skier("Angel Collinson", 1990, md"![](https://snowbrains.com/wp-content/uploads/2019/07/angel-collinson-.jpg)"),
	Skier("Kaya Turski", 1988, md"![](https://olympic.ca/wp-content/uploads/2014/04/rozg_jump.jpg)"),
	]

# ╔═╡ 62a0862d-8583-4662-bd3d-5d5ef045a43a
md"""
#
"""

# ╔═╡ 74f63e2c-fce9-11ea-2145-dd96e9cda96c
md"👉 Show the **photos** of all skiers born before 1989"

# ╔═╡ 9b688c4a-fceb-11ea-10b1-590b77c7bfe3
function before89(skilady)
	skilady.born < 1989
end

# ╔═╡ 063dae04-ca39-4c07-8f70-855f98837aa1
data[1].photo

# ╔═╡ ef6ebf86-fcea-11ea-1118-4f4b4960692b
filter(before89, data)

# ╔═╡ b7608b28-fceb-11ea-3742-a7828971d170
filter(ski -> ski.born < 1989, data)

# ╔═╡ c53212da-fceb-11ea-0eeb-617a18323021
special_skiers = filter(data) do ski
	ski.born < 1989
end

# ╔═╡ ea0ca73c-fceb-11ea-348a-5df7974b4aba
map(special_skiers) do ski
	ski.photo
end

# ╔═╡ f0c1c1e7-750f-4d42-a0b7-e574f56e4294
md"""
Here are two more tasks we could do:
1. compute each skiers age in years today and filter on their age (instead of year born)
2. Augment the `skier` data type with `firstname` and `lastname` and filter on each. Like, find all skiers whose firstname starts with `M`
"""

# ╔═╡ 65599c21-12b8-4a2f-9253-455d9e083a9d
agetoday(skier) = year(Dates.today()) - skier.born

# ╔═╡ b508ac47-0d63-4c72-acfd-6ff8ba1753ff
filter(x -> agetoday(x) < 37, data)	

# ╔═╡ cefa2c0d-c6b9-4740-93d3-6d1ddcda411f
logical_vector = map(data) do ski
	agetoday(ski) < 37
end

# ╔═╡ 1d039747-585c-495e-8301-02b153a74c87
data[logical_vector]

# ╔═╡ 52d854d1-b0eb-45c3-800a-00e6e07770f9
struct Skier2
	firstname
	lastname
	born
	photo
end

# ╔═╡ f20499c9-5cb6-430e-bec7-2f07cee774b7
function parseskier(skilady)
	fl = split(skilady.name, " ")
	Skier2(
		fl[1],
		fl[2],
		skilady.born,
		skilady.photo
	)
end

# ╔═╡ 8fb8f0ff-b038-43dd-8c88-300767f66706
data2 = map(parseskier, data)


# ╔═╡ 8679b016-82b9-44af-b409-f2b8a6189d3f
startwith(x,y) = first(x) == y

# ╔═╡ abf13010-a955-4f11-8c5f-24b16886262e
startswith(data2[1].firstname,'R')

# ╔═╡ 4248707f-fd15-4fa9-a77e-e08042963f91
startswith(data2[1].firstname,'T')

# ╔═╡ 76a9c3eb-403d-44a6-950b-0770296eab13
filter(data2) do ski
	startswith(ski.firstname,'T')	
end

# ╔═╡ be041de9-7c82-4677-94f1-d02715668f28
filter(x -> startwith(x.firstname,'T'), data2)

# ╔═╡ 4564dd4b-20f0-4ff3-9774-c71959858a07
firstletter(x,y) = filter( z -> first(z.firstname) == y, x)

# ╔═╡ 0bd82801-5198-40ca-bc2f-496624ed0866
firstletter(data2, 'M')

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "d7cd76e304b32b583eb96a7ac19153dc0f2d1730"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"
"""

# ╔═╡ Cell order:
# ╟─32465c0e-fcd4-11ea-1544-df26081c7fa7
# ╠═65c59b14-fcd7-11ea-2a19-3d084b3bca56
# ╠═249cf7dc-fcdb-11ea-3630-ed2369d20041
# ╟─175cb644-fcd5-11ea-22f2-3f96d6d2e637
# ╠═6b91914a-fcd4-11ea-0d27-c99e7ef99354
# ╠═b5614d1a-fcd4-11ea-19b9-45043b16b332
# ╠═0991e74c-fce3-11ea-0616-336e1d5d83e9
# ╠═10fe7950-fce3-11ea-1ace-e1676961935e
# ╠═2424dd62-fce3-11ea-14a6-81792a7dee89
# ╠═2fb8117e-fce3-11ea-2492-55e4768f6e37
# ╟─a34557ac-fce3-11ea-1391-3d0cddd4201b
# ╠═70aa854a-fce5-11ea-3477-6df2b0ca1d22
# ╟─cbfc5ede-fce3-11ea-2044-15b8a07ef5f2
# ╟─62a0862d-8583-4662-bd3d-5d5ef045a43a
# ╟─74f63e2c-fce9-11ea-2145-dd96e9cda96c
# ╠═9b688c4a-fceb-11ea-10b1-590b77c7bfe3
# ╠═063dae04-ca39-4c07-8f70-855f98837aa1
# ╠═ef6ebf86-fcea-11ea-1118-4f4b4960692b
# ╠═b7608b28-fceb-11ea-3742-a7828971d170
# ╠═c53212da-fceb-11ea-0eeb-617a18323021
# ╠═ea0ca73c-fceb-11ea-348a-5df7974b4aba
# ╟─f0c1c1e7-750f-4d42-a0b7-e574f56e4294
# ╠═34427d6a-8f74-4857-91a3-2526555eebaa
# ╠═65599c21-12b8-4a2f-9253-455d9e083a9d
# ╠═b508ac47-0d63-4c72-acfd-6ff8ba1753ff
# ╠═cefa2c0d-c6b9-4740-93d3-6d1ddcda411f
# ╠═1d039747-585c-495e-8301-02b153a74c87
# ╠═52d854d1-b0eb-45c3-800a-00e6e07770f9
# ╠═f20499c9-5cb6-430e-bec7-2f07cee774b7
# ╠═8fb8f0ff-b038-43dd-8c88-300767f66706
# ╠═8679b016-82b9-44af-b409-f2b8a6189d3f
# ╠═abf13010-a955-4f11-8c5f-24b16886262e
# ╠═4248707f-fd15-4fa9-a77e-e08042963f91
# ╠═76a9c3eb-403d-44a6-950b-0770296eab13
# ╠═be041de9-7c82-4677-94f1-d02715668f28
# ╠═4564dd4b-20f0-4ff3-9774-c71959858a07
# ╠═0bd82801-5198-40ca-bc2f-496624ed0866
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
