### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7f1e114b-d11f-40a5-929e-629c3b088d19
begin
	using Dates
	using Plots
	using PlutoUI
	using BenchmarkTools
end

# ╔═╡ 42ecaf0c-5585-11eb-07bf-05f964ffc325
md"""


# Julia Bootcamp - Arrays
Florian Oswald, $(Dates.format(Dates.today(), dateformat"dd u yyyy"))
"""


# ╔═╡ 7cf6ef84-6700-11eb-3cb3-6531e82cbb52
html"<button onclick='present()'>present</button>"

# ╔═╡ 6930bc28-6700-11eb-0505-f7c546f1acea

md"
# Arrays
 
In this notebook we introduce some concepts important for work with arrays in julia. First though:

> What is an Array?

An array is a *container* for elements with **identical** data type. This is different from a spreadsheet or a `DataFrame`, which can have different data types in each column. It's also different from a `Dict`, which can have fully different datatypes (similar to a `python` dict or an `R` `list`)

#
"


# ╔═╡ 8140a376-5587-11eb-1372-cbf4cb8db60d
	md"""
	!!! info
	    The official [documentation](https://docs.julialang.org/en/v1/manual/arrays/) is **really** good. Check it out!
	"""

# ╔═╡ 2b1ab8e6-5588-11eb-03bc-0f1b03719f35
md"
# Creating Arrays
"

# ╔═╡ ded79d1e-5587-11eb-0e88-c56751e46abc
a = [1.0, 2.0, 3.0, 4]

# ╔═╡ f8100ff0-5587-11eb-0731-f7b839004f3c
b = [1, 2, 3]

# ╔═╡ fdf808d2-5587-11eb-0302-1b739aaf6be5
typeof(a)

# ╔═╡ 0a8879f6-5588-11eb-023e-afe1ef6a1eb1
typeof(b)

# ╔═╡ 578ff698-5588-11eb-07fc-633d03c23062
md"
Notice the different types of those arrays.

We can get size and dimension info about an array with `size` and `ndims`. `length` returns the total number of elements.
"

# ╔═╡ ba5dcb58-6706-11eb-3b6f-c5f94de03e0d
md"#"

# ╔═╡ 79c9e5ac-5588-11eb-0341-01ca0aa2e411
size(a)

# ╔═╡ 9e5ec180-5588-11eb-34a2-f325d272532d
typeof(size(a))

# ╔═╡ a6b4ad92-5588-11eb-233f-63c5737ad710
md"*Tuple*! That's useful for *short* containers and is used a lot in function arguments or when we want to return multiple things from a function. [here](https://docs.julialang.org/en/v1/manual/functions/#Tuples) is the relevant documentation. Notice that you cannot *change* a tuple once it's created. it is **immutable**:
"

# ╔═╡ f6b5bbe2-5588-11eb-08e7-59236a4a35bf
tu = (1,2,1)

# ╔═╡ ff363182-5588-11eb-2f7e-3180d1537941
tu[2] = 3  # I want to access the second element and change it to value 3!

# ╔═╡ 7fa5274e-55aa-11eb-0399-17c0fbccac1b
md"
#


There are also *named tuples*:
"

# ╔═╡ 8b36c8c4-55aa-11eb-357f-abc29a42300f
(a = 1.1, b = 2.3)

# ╔═╡ 1e3cf52a-5589-11eb-3d72-45b0f25f1edf
md"
# Creating Arrays

"

# ╔═╡ 39aa00ec-c5e2-4839-ad1f-9b5fd17b9f6d
numvec, nummat, svec = ([1,3,6,19,29], [1 2 ; 3 4], ["three" "nice" "words"])

# ╔═╡ 657ebfce-1a82-42ad-bd08-77762705ef3b
typeof(numvec)

# ╔═╡ 5241f2c4-ca34-4dc6-b57b-1e0dddcef9bd
typeof(nummat)

# ╔═╡ e64109b9-7be3-4274-8010-9fa2f5f520d1
typeof(svec)

# ╔═╡ 0d8c330a-1ef5-4616-9dfb-30dd715a3508
size(numvec)  # by default vectors are column vectors

# ╔═╡ f7175101-a811-448d-a57e-c2a471ea77d9
ndims(numvec)  #  (just one dimension)

# ╔═╡ a9f87aa8-cb8c-46d2-b64e-7c63e96b9f01
size(svec)  # a row-vector!

# ╔═╡ 05140559-10c9-4dbf-af52-4da8749b3f1b
ndims(svec) #  (two dimensions)

# ╔═╡ 30db8bc4-5589-11eb-25cb-39afacd9bada
ones(Int,2,3)

# ╔═╡ 35694d0c-5589-11eb-01a7-1d710daa7c08
zeros(Int,2,4)

# ╔═╡ 99605a26-5589-11eb-031b-bd7709085dbf
falses(3)

# ╔═╡ 9dceb348-5589-11eb-254c-b1b8cf0781c2
trues(1,3)

# ╔═╡ b26ddb82-6700-11eb-2375-71c73ceeeea2
md"
#
"

# ╔═╡ a254b474-5589-11eb-101d-253f75350205
ra = rand(3,2)

# ╔═╡ aada0c02-5589-11eb-3d3f-d5d5cf9b8e0f
rand(1:5,3,4)

# ╔═╡ 39d9bfa4-5589-11eb-265b-5bedf62d6266
fill(1.3,2,5)

# ╔═╡ 4edab028-5589-11eb-1d4e-df07f93cd986
md"
#

Here you see how to create an *empty* array with the `undef` object. notice that those numbers are garbage (they are just whatever value is currently stored in a certain location of your computer's RAM). Sometimes it's useful to *preallocate* a large array, before we do a long-running computation, say. We will see that *allocating* memory is an expensive operation in terms of computing time and we should try to minimize it.

The function `similar` is a *similar* idea: you create an array of same shape and type as the input arg, but it's filled with garbage:
"

# ╔═╡ 40472640-5589-11eb-19eb-838837e9fdc0
Array{Float64}(undef, 3,3,2)

# ╔═╡ f5109d62-5588-11eb-0abc-2d21b95a3477
similar(ra)

# ╔═╡ fa21d678-5589-11eb-391a-633dbadf9558
md"
## Manually creating arrays

We can create arrays manually, as above, with the `[` operator:
"

# ╔═╡ cadb8b28-55a4-11eb-1600-5739c2a95a9c
a2 = [ 1 2 ;  # the semicolon says "next row"
	   3 4 ]

# ╔═╡ d97da51c-55a4-11eb-305c-1bb0e1634cb0
ndims(a2)

# ╔═╡ e27215b8-55a4-11eb-21c5-2738c0897729
a2'

# ╔═╡ 09e97578-55a5-11eb-1042-0d7ea64aa830
vcat(ones(3),1.1)

# ╔═╡ a3211b38-1e4c-4201-bc08-83b0ac625cdd
typeof([[1,2,3], [5] ])

# ╔═╡ 6f434e7b-3f6d-4e51-b566-9d6e212cb2b3
md"""
#
"""

# ╔═╡ 516b88a0-55a5-11eb-105e-17c75539d751
hcat(rand(2,2),falses(2,3))

# ╔═╡ 2835338a-679a-11eb-1557-a75b2d2d657a
typeof(falses(2,2))

# ╔═╡ 6242d548-55a5-11eb-22e4-531a821011c9
 promote_type(Float64, Bool)

# ╔═╡ c66ff85c-55a5-11eb-042a-836b641d0bc9
hcat(rand(2,2),fill("hi",2,5))

# ╔═╡ 4effe7c2-6150-4a26-9877-6089f9a93524
md"""
So, `Any` is the overarching data type at the root of the type graph. You can have `Any`, but that is not optimized at all.
"""

# ╔═╡ e0fd8a60-822e-48cd-94c5-a14a2e97d6fc
md"""
#

You can also put different-length obejects in to arrays. An array is *just another container*:
"""

# ╔═╡ 8bebe92a-88ec-481d-b260-fffcdb6e7a49
mix = [rand(2), [1,2,3], [false, true]]

# ╔═╡ 9e125fa4-0ee4-4dcd-99da-429622e1866b
typeof(mix)  # see how it promoted everyting to Float64?

# ╔═╡ 42febc06-3feb-4f1e-ad82-ca5d8d8018b1
md"""
### combining existing arrays
"""

# ╔═╡ 2c750c3d-3038-4279-9ffc-ac4258af0075
[ones(2), zeros(2)]  # that is an Array of Arrays. I wanted one long array!

# ╔═╡ 39dd6e58-927e-4df8-9996-8d9de266e9f2
[ones(2)..., zeros(2)...]   # the ... is the `splatting` operator

# ╔═╡ e475a7a9-0c93-4270-b16c-ae702dfa9f8c
vcat(ones(2) , zeros(2))

# ╔═╡ c2106201-4492-433d-a98a-d2393921f93b
md"""
splatting is quite important in julia: it means to *unpack* a collection and insert the elements one by one into a function, one after the other. So, the above is equivalent to
"""

# ╔═╡ 0700da90-5ca9-4ccd-b7a7-fa178fdbe381
[1,1,0,0]

# ╔═╡ 3528961f-54b3-40bf-9ad9-d29dbc1ce001
md"""
which is indeed the result we wanted.
"""

# ╔═╡ 06dc9993-9e12-44f9-952a-642adf039875


# ╔═╡ f81c4ae0-6789-11eb-2289-333a2f14725b
md"

# `push`ing onto an existing (or empty) array

* Oftentimes it's useful to accumulate elements along the way, e.g. in a loop.
* In general *preallocating* arrays is good practice, particularly if you repeatedly modify the elements of an array.
* But sometimes we don't know the eventual size of an array (it may depend on the outcome of some other operation)."

# ╔═╡ 4a16caaa-678a-11eb-1818-5f72eb0bb0bb
z = Int[]   

# ╔═╡ 592f0b86-678a-11eb-39f4-55ec3bd7989a
typeof(z)

# ╔═╡ 5d2906c8-678a-11eb-3e11-05f1efd3f778
length(z)

# ╔═╡ 60b6d98a-678a-11eb-34f0-91b61835ccc2
push!(z, "hi")

# ╔═╡ 6ad042d4-71ac-448c-825d-a54997bee9b6
md"""
#
"""

# ╔═╡ b77ae9fe-679a-11eb-19de-678b04bcc042
pushfirst!(z, 1)

# ╔═╡ be5f5cf0-679a-11eb-2b4f-f7d5ab85c6a0
z

# ╔═╡ 686337f0-678a-11eb-09bd-2badaadba117
pop!(z)

# ╔═╡ 6dd1411e-678a-11eb-047a-a1bc3fdea332
z

# ╔═╡ 7c1e52b4-678a-11eb-1a97-3d56ba213b3b
append!(z, 14, 15)

# ╔═╡ 46695ecc-f3fe-4611-bb56-8bd04bd0bc53
deleteat!(z, 1)

# ╔═╡ 1df551d8-e5bb-4621-895b-545ec7cf9362
z

# ╔═╡ f53088a2-55a5-11eb-3b9b-8b91844c5384
md"

# Comprehensions

are a very powerful way to create arrays following from an expression:
"

# ╔═╡ 17ef63ac-55a6-11eb-3713-77dfe04fa601
comp = [ i + j for i in 1:3, j in 1:2] 

# ╔═╡ 2cfde6f6-55a6-11eb-0a12-6b336a02c015
md"
so we could have also done before:
"

# ╔═╡ 3c4111cc-55a6-11eb-198b-458475b9b85f
hcat(rand(2,2), ["hi" for i in 1:2, j in 1:5 ])

# ╔═╡ 75640521-a952-4c86-81cd-397df0280d64
md"""
#

"""

# ╔═╡ 73893134-1701-4e12-9567-176a4cf4c279


# ╔═╡ 626879e4-6603-4606-83bd-9388071a46b9
md"""
#
"""

# ╔═╡ 85cda2a3-9a2e-45ea-b0a6-f982660660c9
md"""
Inside *comprehensions*, we can also have *interdependent indices*, like here, where the $j$ of the second sum starts at the $i$ of the first sum:
"""

# ╔═╡ b5182a08-679c-11eb-01c4-21be55d14ac0
md"
$$\sum_{i=1}^3 \sum_{j=i}^{16} i^2 + j^3$$
"

# ╔═╡ 04af7e0d-9bf0-4552-b949-81081e942fe8
s1 = [ i^2 + j^3 for i in 1:3 for j in i:16 ]   # note no (!) comma because not rectangular

# ╔═╡ e8fc47cb-1831-4ec8-a344-2ebea5d0804a
md"""
then, if we wanted to actually perform the above operation, we could just sum over all those values:
"""

# ╔═╡ 8e96a2c1-0c4b-45a8-98d8-b5cf3af242c2
sum(s1)

# ╔═╡ 3734e433-42cd-4573-8ac7-0013c767e28e
md"""
#

what's even better is to use a so-called *Generator*, which will *not* create an entire array of values, before summing it, but will perform the operation on the fly (summing the next number in line to the current sum):
"""

# ╔═╡ 23f7fa4a-f5dd-4bf7-b6bc-9e0bbd4bf2d0
sum( i^2 + j^3 for i in 1:3 for j in i:16 ) # no square brackets

# ╔═╡ 33a6f0c5-6f3e-4ec4-9a82-5c9134ae2d95
md"""
Time to start talking a bit about performance now. Will do much more of it, for now lets just do a simple benchmark on 2 ways of running that summation (for larger indices to see a real difference).
"""

# ╔═╡ ed724a1a-dd0e-4817-be93-0c4e1fc3ec38
1_000_000_000

# ╔═╡ cdae4a9c-ee2f-48a5-800e-963213301e30
begin
	# I'm defining 2 functions without any args here. More on that later!
	f1() = sum([ i^2 + j^3 for i in 1:1_000 for j in i:1_000 ])
	f2() = sum(  i^2 + j^3 for i in 1:1_000 for j in i:1_000 )  # just remove []
	f1();  # run once to trigger compilation
	f2();
end

# ╔═╡ 8934a18d-1b61-4054-979a-d180fa77ffa2
md"""
#

"""

# ╔═╡ 8cc15db6-0869-4037-928e-9ae9ba4957ed
b1 = @benchmark f1()   # @benchmark from BenchmarkTools.jl

# ╔═╡ b1dac8d1-c818-4353-961c-a75747541181
b2 = @benchmark f2()

# ╔═╡ 7597a626-6a5a-45c8-96e8-ae89ec891512
md"""
#

"""

# ╔═╡ f88db9bb-5635-4e1c-812e-0fc961b1c997
bmr = ratio( median(b1), median(b2) )   # `ratio`, `median` from BenchmarkTools

# ╔═╡ 86016eaa-8b0d-4ca7-b822-4bb421e45c26
judge( median(b1), median(b2) )  # `judge` as well

# ╔═╡ 08bc3323-7e33-492e-a6c5-a7bee0016576
md"""
🤯 Wow the median time is roughly $(round(bmr.time, digits = 0)) times faster, and the memory difference is massive: 5 MiB (*Mebibyte* is the [binary version](https://en.wikipedia.org/wiki/Byte#Multiple-byte_units) of *Megabyte*) vs 0 memory allocated.
"""

# ╔═╡ 3f2fb44a-55a5-11eb-1bc6-aba9b4f794c7
md"
# Ranges

We have `Range` objects in julia. this is similar to `linspace`.
"

# ╔═╡ 2d7852b8-55a8-11eb-07e6-e1dc3016acfd
typeof(0:10)

# ╔═╡ 36e1f93a-55a8-11eb-3c41-bf266aa44859
collect(0:10)

# ╔═╡ fdb8e9b4-6706-11eb-2016-3b0323a35d58
myrange = 0:14

# ╔═╡ 07c4a8a8-6707-11eb-1c69-892820a63270
myrange[5]

# ╔═╡ 0aad3756-6707-11eb-1980-4b52a8129d5d
md"#"

# ╔═╡ 667ca08c-55a8-11eb-1944-dbd8171bd5ad
@bind 📍 Slider(2:10, show_value=true)

# ╔═╡ 3ba19e1c-55a8-11eb-0268-d333107b4ccc
scatter(exp.(range(log(2.0), stop = log(4.0), length = 📍)), ones(📍),ylims = (0.8,1.2))

# ╔═╡ ee1f71a8-55a4-11eb-352b-396905c8b20e
md"
# Array Indexing - *Getting* values

We can use the square bracket operator `[ix]` to get element number `ix`. There is a difference between **linear indexing**, ie. traversing the array in *storage order*, vs **Cartesian indexing**, i.e. addressing the element by its location in the cartesian grid. Julia does both.  
"

# ╔═╡ 2920a9e6-55a7-11eb-235a-d9f89dbdc86d
x = [i + 3*(j-1) for i in 1:3, j in 1:4]

# ╔═╡ 07aca9d4-4716-42ea-aecf-3d097d620bfd
x[8]

# ╔═╡ b65533cc-55a7-11eb-22ce-fb51e1d6a4c2
x[1,1]

# ╔═╡ c0efcdec-55a7-11eb-15a5-e700195132aa
x[1,3]

# ╔═╡ c749dcbe-55a7-11eb-3b6e-4917aaff9e88
x[1,:]  # the colon means "all"

# ╔═╡ cace8fa8-55a7-11eb-083b-d5050a6ad009
x[:,1]

# ╔═╡ d087566c-55a7-11eb-22cf-493144e9f225
x[4]  # the 4th linear index in storage order. julia stores arrays column major

# ╔═╡ dff566ca-55a7-11eb-1b8c-335c0aaf3ac4
x[end] #reserved word `end`

# ╔═╡ 1a1eb880-55b0-11eb-31af-7572840ce1a2
md"
#

we can also use logical indexing by supplying  a boolean array saying which elements to pick:
"

# ╔═╡ 2fae8126-55b0-11eb-17ac-c54318e62c5e
which_ones = rand([true false], 12)

# ╔═╡ 430925e6-55b0-11eb-1637-6fe56713e397
x[ which_ones ]

# ╔═╡ 59708954-55b1-11eb-0e62-b72b3f3f65f0
md"
# Broadcasting and *setting* values

* How can we modify the value of an array?
"

# ╔═╡ 25386099-4cfd-4162-b7a3-c544ffb0e646
v0 = ones(3)

# ╔═╡ 7295c79e-6701-11eb-3ec4-2ba3c1f45bfe
v0[2] = -9

# ╔═╡ 85456dc2-6701-11eb-3348-379f534568c8
v0

# ╔═╡ a21d3740-6701-11eb-3009-4da56916e76c
md"
#

Ok. But now consider this vector here and a range of indices:
"

# ╔═╡ fe354836-6701-11eb-191c-2de25e7daacf
v0[2:3] = 2

# ╔═╡ 074dccd8-6702-11eb-038c-0b8c14b62647
md"
## Broadcasting

* This operation was not allowed.
* Why? on the left we had an `Array` and on the right we had a scalar.
* What we really wanted was to use the operation `=` (*assign to object*) in an **element-by-element** fashion on the array on the LHS. 
* **element-by-element** means to *broadcast* over a colleciton in julia.
* We use the dot `.` to mark broadcasting:
"

# ╔═╡ c2c94874-9858-41eb-b9e9-a7f38e2e4514
v1 = copy(v0)

# ╔═╡ 58d5e0ce-6702-11eb-2130-b1e9f84e5a65
v1[2:3] .= 2

# ╔═╡ 64be4458-6702-11eb-02f9-37de11e2b41f
v1

# ╔═╡ aec57e7c-de48-4da3-9149-b152a1b83b15
v0

# ╔═╡ e71d752c-34a9-401b-9e0f-abf0c0bfde81
md"""
#

Broadcasting is ubiquous in julia, and it is a major difference to `R` or `matlab`. Those languages *automatically vectorize many function calls* for you, so this would work in R
"""

# ╔═╡ abd4c30f-806f-4cb3-8857-80cbd3b32ae5
exp([1.0,2.0])

# ╔═╡ 164d6171-748c-4816-885e-d1884578cd27
md"""
In julia, you need to be specific and use the broadcast operator `.` after the function name:
"""

# ╔═╡ 045a03af-5105-4081-b069-95a9c359b33d
exp.([1.0,2.0])

# ╔═╡ 6c9a8f92-af66-4d56-a824-ba8c065ab1d0
md"""
#

While this may look a bit awkward and like a limitation at first sight, you will soon find out that the ability of julia to broadcast operations over entire arrays is extremely powerful, for a simple reason: while in `R` and `matlab` and so on, some developer had to sit down and *design the function* `exp for vectors`, the `.` in julia works **for every function, even your own**. While this clearly belongs into our *Performance* section, if you want to more about this, here is a [post](https://julialang.org/blog/2018/05/extensible-broadcast-fusion/) about introduction of the broadcast for our own functions, and here [another one](https://julialang.org/blog/2017/01/moredots/) about how julia *unrolls loops and fuses them into one pass over the input array*. Geeky stuff. 🔥

What if I also told you that the same technology (the dot-broadcast) will work, whether we use a standard julia array, like here, or a `CUDA.jl` array, that will run on your massive GPU in that huge data centre where you rented some very large compute capacity? 😮 . Real Geek stuff. 🔥🔥🔥
"""

# ╔═╡ b2ef6805-383d-4537-9476-d2b922116a0a
md"""
##
"""

# ╔═╡ 51386cdc-8641-42c8-885f-75ff4e5bf0e0
v3 = ones(3)

# ╔═╡ 9aad3dec-6702-11eb-15c9-75d6b2d3713e
v3[1:2] = [0, 0]

# ╔═╡ 9e35cf88-6702-11eb-2a92-0f9271383c8f
v3

# ╔═╡ ad8175b6-6702-11eb-2edf-c9b3304a5ddd
md"
That worked because the right and left of `=` had the same type!
"

# ╔═╡ c8319ed4-6702-11eb-1651-5bb3675f8aa2
md"
## Working with Slices

* Let's give a name to that slice now
"

# ╔═╡ 81e2dc73-ba5d-4e1f-9bcd-1c98dcdfd798
v = ones(12)

# ╔═╡ d91a964c-6702-11eb-12ad-f7d5398c1591
s = v[4:7]

# ╔═╡ 578f31c2-6703-11eb-05a7-11f472bc9ee5
md"
#

Well let's try of course. We are here currently:
"

# ╔═╡ 7e8ed468-df06-497f-bd84-1d543e11464b
s[1] = 99

# ╔═╡ 00afe52e-a9a6-435d-984c-23810ed36560
s

# ╔═╡ 7dc0ec32-6703-11eb-2cd7-27b1f1dcca3a
md"So far so good. But what happend to the original array `v`?

#

"

# ╔═╡ a37e8fd0-6703-11eb-3d69-85511daf9720
v

# ╔═╡ 1b7cd4bb-5d4a-43ea-b948-48212be59d1f
v[1:4] == s

# ╔═╡ a6732366-6703-11eb-36da-110356d80106
md"Nothing!

Surprised? 

We take note that the operator `[]` makes a *copy* of the data. Our object `s` is allocated on a *different* set of memory locations than the original array `v`, hence changing `s` does not affect `v`.

Here is an alternative:

# Views

Sometimes we don't want to take a copy, but just operate on some subset of array. Literally *on the same memory* in RAM. a `view` creates a *window* into the original array:
"

# ╔═╡ 1332b796-0a02-4868-9dc1-5df237f9a05f
v4 = ones(10)

# ╔═╡ c810b5ec-6703-11eb-293c-69fc0a8e573f
w = view(v4, 4:7)

# ╔═╡ 35ae4a94-6704-11eb-3ebd-a75cbd2ca619
typeof(w)

# ╔═╡ 3d914642-6704-11eb-00a4-c1011ff61fdd

md"
#

Ok let's try to modify that again:
"

# ╔═╡ 9e79d118-6704-11eb-3cff-613653dd369b
w[3:4] .= -999

# ╔═╡ a1ca494c-6704-11eb-3bfd-b520e12ac37a
v4

# ╔═╡ a7e0ee82-6704-11eb-258e-e77dee71e929
md"
It did modify the original array `v4`! ✅

# `@view` macro

* There is a nicer way to write it as well
"

# ╔═╡ 729bda00-6704-11eb-126a-439d41284c1c
w2 = @view v4[3:5]

# ╔═╡ 9b2565fa-6703-11eb-26d0-d5a4c520bfef
md"
What's this trickery? The macro `@view` literally takes the piece of Julia code `v[3:5]` and replaces it with the new piece of code `view(v, 3:5)`

# Matrices

This works in the same way on matrices or higher dimensional arrays.
"

# ╔═╡ 5b3f73ac-6705-11eb-3fc3-a7132d790ddc
M = [10i + j for i in 0:5, j in 1:4]

# ╔═╡ 5c8f0d58-6705-11eb-0415-afa1032e72b3
M[3:5, 1:2]

# ╔═╡ 63b39b30-6705-11eb-11ef-31053508273a
md"
# Reshaping

* Reshaping a matrix or a general array is done with the `reshape` function:
"

# ╔═╡ 7e404c62-6705-11eb-2886-6b9da420f7b0
reshape(M, 3, 8)

# ╔═╡ a07a1634-6705-11eb-0342-61fd861a94a9
md"Notice that julia is *column-major* storage: i.e. we travers first columns, then rows through memory. This is reflected in how the reshaping picks elements

* Some times we also want to convert an array back to a simple vector (we strip all dimensionality info away from a vector)
* You can again see the storage order of the data in your computer's memory

"

# ╔═╡ 538eefb5-d5eb-42d7-a282-9d4c33521815
md"""
#
"""

# ╔═╡ e0180ac6-6705-11eb-3fe0-1ffdb3809f11
M[:]

# ╔═╡ e4dca698-6705-11eb-2e54-e751eb17d068
vec(M)

# ╔═╡ 7fb9ae2e-6704-11eb-0db7-abc17c115185
md"library"

# ╔═╡ 1e745340-6703-11eb-0853-2d40b6d3bc46
info(text) = Markdown.MD(Markdown.Admonition("info", "Info", [text]));

# ╔═╡ 426a4592-c04e-44fc-a01f-a1b61b823eeb
info(title,text) = Markdown.MD(Markdown.Admonition("info", title, [text]));

# ╔═╡ a3894bfc-a64e-4e0b-b934-bb3270299b66
info(md"Wait, didn't you say the all need to have the *same type*? ↪ yes, they are **all** of type `Any`! More on *types* later!")

# ╔═╡ 08bb40ae-956e-40c5-a18e-b1907dadfbb8
tip(text) = Markdown.MD(Markdown.Admonition("tip", "Tip", [text]));

# ╔═╡ 057e6407-3f3d-4b4d-bca8-fd77014cdb76
q(text) = Markdown.MD(Markdown.Admonition("tip", "Question", [text]));

# ╔═╡ 899051a8-d1c4-4763-b372-3d7b3b499bd3
q(md"""
* Consider this budget constraint:
$$c_t + \frac{1}{1+r} a_{t+1} = y_t + a_t$$
* suppose we have values for $y \in \{1,2\}$ and for $a \in \{0,1,2\}$, and set $r=0.02$
* Use a comprehension to build a 3-dimensional array of size (3,2,3) which has the quantity 
```
cons[i,j,k] = y[j] + a[i] - 1/(1+r) * a[k]
```
in cell `[i,j,k]`. 

""")

# ╔═╡ 62656d47-64b9-4a59-870b-cab53e869315
q(md"""
* Tell us the consumption $c$ associated with all savings choices $a_{t+1}$ if $a=1,y=1$ by indexing your `cons` array from above!
* That is, just index `cons` in the corresponding indices (and use `:` for the savings dimension)
""")

# ╔═╡ 7268d01a-6702-11eb-057d-a33ff7b6dff5
q(md"

* If you were followign along, what is this going to do?

```julia
v3 = ones(3)
v3[1:2] = [0, 0]
```

#
")

# ╔═╡ e48c1410-6702-11eb-06c4-8300fc6614af
q(md"
What's going to happen if you modify the values in `s`?
That's not a simple question!")

# ╔═╡ 0e7c8540-a939-49ed-89a6-46588c4b0e58
danger(text) = Markdown.MD(Markdown.Admonition("danger", "Caution", [text]));

# ╔═╡ 7dc2bb38-6704-11eb-2aed-8563be2b3d89
begin
	struct TwoColumn{L, R}
		left::L
		right::R
	end

	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
		write(io, """<div style="display: flex;"><div style="flex: 50%;">""")
		show(io, mime, tc.left)
		write(io, """</div><div style="flex: 50%;">""")
		show(io, mime, tc.right)
		write(io, """</div></div>""")
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
Plots = "~1.38.2"
PlutoUI = "~0.7.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "3fa4ebe19270b8274ea97499153f3ddffcdcb6c9"

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

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "545a177179195e442472a1c4dc86982aa7a1bef0"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.7"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "26ec26c98ae1453c692efded2b17e15125a5bea1"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.28.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

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

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "f36e5e8fdffcb5646ea5da81495a5a7566005127"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.3"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

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

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

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

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "df37206100d39f79b3376afb6b9cee4970041c61"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.1+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89211ea35d9df5831fca5d33552c02bd33878419"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e888ad02ce716b319e6bdb985d2ef300e7089889"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.3+0"

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

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

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

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+3"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ed6834e95bd326c52d5675b4181386dfbe885afb"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.55.5+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "9f8675a55b37a70aa23177ec110f6e3f4dd68466"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.17"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "37b7bb7aabf9a085e0044307e1717436117f2b3b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
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

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

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

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

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

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c0667a8e676c53d390a09dc6870b3d8d6650e2bf"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.22.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56c6604ec8b2d82cc4cfe01aa03b00426aac7e1f"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.4+1"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+3"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e9216fdcd8514b7072b43653874fd688e4c6c003"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.12+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89799ae67c17caa5b3b5a19b8469eeee474377db"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.5+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d7155fea91a4123ef59f42c4afb5ab3b4ca95058"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+3"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c57201109a9e4c0585b208bb408bc41d205ac4e9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.2+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "1a74296303b6524a0472a8cb12d3d87a78eb3612"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6dba04dbfb72ae3ebe5418ba33d087ba8aa8cb00"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.1+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "622cf78670d067c738667aaa96c553430b65e269"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0ba42241cb6809f1a278d0bcb976e0483c3f1f2d"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "055a96774f383318750a1a5e10fd4151f04c29c5"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.46+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─7f1e114b-d11f-40a5-929e-629c3b088d19
# ╟─42ecaf0c-5585-11eb-07bf-05f964ffc325
# ╟─7cf6ef84-6700-11eb-3cb3-6531e82cbb52
# ╟─6930bc28-6700-11eb-0505-f7c546f1acea
# ╟─8140a376-5587-11eb-1372-cbf4cb8db60d
# ╟─2b1ab8e6-5588-11eb-03bc-0f1b03719f35
# ╠═ded79d1e-5587-11eb-0e88-c56751e46abc
# ╠═f8100ff0-5587-11eb-0731-f7b839004f3c
# ╠═fdf808d2-5587-11eb-0302-1b739aaf6be5
# ╠═0a8879f6-5588-11eb-023e-afe1ef6a1eb1
# ╟─578ff698-5588-11eb-07fc-633d03c23062
# ╟─ba5dcb58-6706-11eb-3b6f-c5f94de03e0d
# ╠═79c9e5ac-5588-11eb-0341-01ca0aa2e411
# ╠═9e5ec180-5588-11eb-34a2-f325d272532d
# ╟─a6b4ad92-5588-11eb-233f-63c5737ad710
# ╠═f6b5bbe2-5588-11eb-08e7-59236a4a35bf
# ╠═ff363182-5588-11eb-2f7e-3180d1537941
# ╟─7fa5274e-55aa-11eb-0399-17c0fbccac1b
# ╠═8b36c8c4-55aa-11eb-357f-abc29a42300f
# ╟─1e3cf52a-5589-11eb-3d72-45b0f25f1edf
# ╠═39aa00ec-c5e2-4839-ad1f-9b5fd17b9f6d
# ╠═657ebfce-1a82-42ad-bd08-77762705ef3b
# ╠═5241f2c4-ca34-4dc6-b57b-1e0dddcef9bd
# ╠═e64109b9-7be3-4274-8010-9fa2f5f520d1
# ╠═0d8c330a-1ef5-4616-9dfb-30dd715a3508
# ╠═f7175101-a811-448d-a57e-c2a471ea77d9
# ╠═a9f87aa8-cb8c-46d2-b64e-7c63e96b9f01
# ╠═05140559-10c9-4dbf-af52-4da8749b3f1b
# ╠═30db8bc4-5589-11eb-25cb-39afacd9bada
# ╠═35694d0c-5589-11eb-01a7-1d710daa7c08
# ╠═99605a26-5589-11eb-031b-bd7709085dbf
# ╠═9dceb348-5589-11eb-254c-b1b8cf0781c2
# ╟─b26ddb82-6700-11eb-2375-71c73ceeeea2
# ╠═a254b474-5589-11eb-101d-253f75350205
# ╠═aada0c02-5589-11eb-3d3f-d5d5cf9b8e0f
# ╠═39d9bfa4-5589-11eb-265b-5bedf62d6266
# ╟─4edab028-5589-11eb-1d4e-df07f93cd986
# ╠═40472640-5589-11eb-19eb-838837e9fdc0
# ╠═f5109d62-5588-11eb-0abc-2d21b95a3477
# ╟─fa21d678-5589-11eb-391a-633dbadf9558
# ╠═cadb8b28-55a4-11eb-1600-5739c2a95a9c
# ╠═d97da51c-55a4-11eb-305c-1bb0e1634cb0
# ╠═e27215b8-55a4-11eb-21c5-2738c0897729
# ╠═09e97578-55a5-11eb-1042-0d7ea64aa830
# ╠═a3211b38-1e4c-4201-bc08-83b0ac625cdd
# ╟─6f434e7b-3f6d-4e51-b566-9d6e212cb2b3
# ╠═516b88a0-55a5-11eb-105e-17c75539d751
# ╠═2835338a-679a-11eb-1557-a75b2d2d657a
# ╠═6242d548-55a5-11eb-22e4-531a821011c9
# ╠═c66ff85c-55a5-11eb-042a-836b641d0bc9
# ╟─a3894bfc-a64e-4e0b-b934-bb3270299b66
# ╟─4effe7c2-6150-4a26-9877-6089f9a93524
# ╟─e0fd8a60-822e-48cd-94c5-a14a2e97d6fc
# ╠═8bebe92a-88ec-481d-b260-fffcdb6e7a49
# ╠═9e125fa4-0ee4-4dcd-99da-429622e1866b
# ╟─42febc06-3feb-4f1e-ad82-ca5d8d8018b1
# ╠═2c750c3d-3038-4279-9ffc-ac4258af0075
# ╠═39dd6e58-927e-4df8-9996-8d9de266e9f2
# ╠═e475a7a9-0c93-4270-b16c-ae702dfa9f8c
# ╟─c2106201-4492-433d-a98a-d2393921f93b
# ╠═0700da90-5ca9-4ccd-b7a7-fa178fdbe381
# ╟─3528961f-54b3-40bf-9ad9-d29dbc1ce001
# ╠═06dc9993-9e12-44f9-952a-642adf039875
# ╟─f81c4ae0-6789-11eb-2289-333a2f14725b
# ╠═4a16caaa-678a-11eb-1818-5f72eb0bb0bb
# ╠═592f0b86-678a-11eb-39f4-55ec3bd7989a
# ╠═5d2906c8-678a-11eb-3e11-05f1efd3f778
# ╠═60b6d98a-678a-11eb-34f0-91b61835ccc2
# ╟─6ad042d4-71ac-448c-825d-a54997bee9b6
# ╠═b77ae9fe-679a-11eb-19de-678b04bcc042
# ╠═be5f5cf0-679a-11eb-2b4f-f7d5ab85c6a0
# ╠═686337f0-678a-11eb-09bd-2badaadba117
# ╠═6dd1411e-678a-11eb-047a-a1bc3fdea332
# ╠═7c1e52b4-678a-11eb-1a97-3d56ba213b3b
# ╠═46695ecc-f3fe-4611-bb56-8bd04bd0bc53
# ╠═1df551d8-e5bb-4621-895b-545ec7cf9362
# ╟─f53088a2-55a5-11eb-3b9b-8b91844c5384
# ╠═17ef63ac-55a6-11eb-3713-77dfe04fa601
# ╟─2cfde6f6-55a6-11eb-0a12-6b336a02c015
# ╠═3c4111cc-55a6-11eb-198b-458475b9b85f
# ╟─75640521-a952-4c86-81cd-397df0280d64
# ╟─899051a8-d1c4-4763-b372-3d7b3b499bd3
# ╠═73893134-1701-4e12-9567-176a4cf4c279
# ╟─626879e4-6603-4606-83bd-9388071a46b9
# ╟─85cda2a3-9a2e-45ea-b0a6-f982660660c9
# ╟─b5182a08-679c-11eb-01c4-21be55d14ac0
# ╠═04af7e0d-9bf0-4552-b949-81081e942fe8
# ╟─e8fc47cb-1831-4ec8-a344-2ebea5d0804a
# ╠═8e96a2c1-0c4b-45a8-98d8-b5cf3af242c2
# ╟─3734e433-42cd-4573-8ac7-0013c767e28e
# ╠═23f7fa4a-f5dd-4bf7-b6bc-9e0bbd4bf2d0
# ╟─33a6f0c5-6f3e-4ec4-9a82-5c9134ae2d95
# ╠═ed724a1a-dd0e-4817-be93-0c4e1fc3ec38
# ╠═cdae4a9c-ee2f-48a5-800e-963213301e30
# ╟─8934a18d-1b61-4054-979a-d180fa77ffa2
# ╠═8cc15db6-0869-4037-928e-9ae9ba4957ed
# ╠═b1dac8d1-c818-4353-961c-a75747541181
# ╟─7597a626-6a5a-45c8-96e8-ae89ec891512
# ╠═f88db9bb-5635-4e1c-812e-0fc961b1c997
# ╠═86016eaa-8b0d-4ca7-b822-4bb421e45c26
# ╟─08bc3323-7e33-492e-a6c5-a7bee0016576
# ╟─3f2fb44a-55a5-11eb-1bc6-aba9b4f794c7
# ╠═2d7852b8-55a8-11eb-07e6-e1dc3016acfd
# ╠═36e1f93a-55a8-11eb-3c41-bf266aa44859
# ╠═fdb8e9b4-6706-11eb-2016-3b0323a35d58
# ╠═07c4a8a8-6707-11eb-1c69-892820a63270
# ╟─0aad3756-6707-11eb-1980-4b52a8129d5d
# ╠═667ca08c-55a8-11eb-1944-dbd8171bd5ad
# ╠═3ba19e1c-55a8-11eb-0268-d333107b4ccc
# ╟─ee1f71a8-55a4-11eb-352b-396905c8b20e
# ╠═2920a9e6-55a7-11eb-235a-d9f89dbdc86d
# ╠═07aca9d4-4716-42ea-aecf-3d097d620bfd
# ╠═b65533cc-55a7-11eb-22ce-fb51e1d6a4c2
# ╠═c0efcdec-55a7-11eb-15a5-e700195132aa
# ╠═c749dcbe-55a7-11eb-3b6e-4917aaff9e88
# ╠═cace8fa8-55a7-11eb-083b-d5050a6ad009
# ╠═d087566c-55a7-11eb-22cf-493144e9f225
# ╠═dff566ca-55a7-11eb-1b8c-335c0aaf3ac4
# ╟─1a1eb880-55b0-11eb-31af-7572840ce1a2
# ╠═2fae8126-55b0-11eb-17ac-c54318e62c5e
# ╠═430925e6-55b0-11eb-1637-6fe56713e397
# ╟─62656d47-64b9-4a59-870b-cab53e869315
# ╟─59708954-55b1-11eb-0e62-b72b3f3f65f0
# ╠═25386099-4cfd-4162-b7a3-c544ffb0e646
# ╠═7295c79e-6701-11eb-3ec4-2ba3c1f45bfe
# ╠═85456dc2-6701-11eb-3348-379f534568c8
# ╟─a21d3740-6701-11eb-3009-4da56916e76c
# ╠═fe354836-6701-11eb-191c-2de25e7daacf
# ╟─074dccd8-6702-11eb-038c-0b8c14b62647
# ╠═c2c94874-9858-41eb-b9e9-a7f38e2e4514
# ╠═58d5e0ce-6702-11eb-2130-b1e9f84e5a65
# ╠═64be4458-6702-11eb-02f9-37de11e2b41f
# ╠═aec57e7c-de48-4da3-9149-b152a1b83b15
# ╟─e71d752c-34a9-401b-9e0f-abf0c0bfde81
# ╠═abd4c30f-806f-4cb3-8857-80cbd3b32ae5
# ╟─164d6171-748c-4816-885e-d1884578cd27
# ╠═045a03af-5105-4081-b069-95a9c359b33d
# ╟─6c9a8f92-af66-4d56-a824-ba8c065ab1d0
# ╟─b2ef6805-383d-4537-9476-d2b922116a0a
# ╟─7268d01a-6702-11eb-057d-a33ff7b6dff5
# ╠═51386cdc-8641-42c8-885f-75ff4e5bf0e0
# ╠═9aad3dec-6702-11eb-15c9-75d6b2d3713e
# ╠═9e35cf88-6702-11eb-2a92-0f9271383c8f
# ╟─ad8175b6-6702-11eb-2edf-c9b3304a5ddd
# ╟─c8319ed4-6702-11eb-1651-5bb3675f8aa2
# ╠═81e2dc73-ba5d-4e1f-9bcd-1c98dcdfd798
# ╠═d91a964c-6702-11eb-12ad-f7d5398c1591
# ╟─e48c1410-6702-11eb-06c4-8300fc6614af
# ╟─578f31c2-6703-11eb-05a7-11f472bc9ee5
# ╠═7e8ed468-df06-497f-bd84-1d543e11464b
# ╠═00afe52e-a9a6-435d-984c-23810ed36560
# ╟─7dc0ec32-6703-11eb-2cd7-27b1f1dcca3a
# ╠═a37e8fd0-6703-11eb-3d69-85511daf9720
# ╠═1b7cd4bb-5d4a-43ea-b948-48212be59d1f
# ╟─a6732366-6703-11eb-36da-110356d80106
# ╠═1332b796-0a02-4868-9dc1-5df237f9a05f
# ╠═c810b5ec-6703-11eb-293c-69fc0a8e573f
# ╠═35ae4a94-6704-11eb-3ebd-a75cbd2ca619
# ╟─3d914642-6704-11eb-00a4-c1011ff61fdd
# ╠═9e79d118-6704-11eb-3cff-613653dd369b
# ╠═a1ca494c-6704-11eb-3bfd-b520e12ac37a
# ╟─a7e0ee82-6704-11eb-258e-e77dee71e929
# ╠═729bda00-6704-11eb-126a-439d41284c1c
# ╟─9b2565fa-6703-11eb-26d0-d5a4c520bfef
# ╠═5b3f73ac-6705-11eb-3fc3-a7132d790ddc
# ╠═5c8f0d58-6705-11eb-0415-afa1032e72b3
# ╟─63b39b30-6705-11eb-11ef-31053508273a
# ╠═7e404c62-6705-11eb-2886-6b9da420f7b0
# ╟─a07a1634-6705-11eb-0342-61fd861a94a9
# ╟─538eefb5-d5eb-42d7-a282-9d4c33521815
# ╠═e0180ac6-6705-11eb-3fe0-1ffdb3809f11
# ╠═e4dca698-6705-11eb-2e54-e751eb17d068
# ╟─7fb9ae2e-6704-11eb-0db7-abc17c115185
# ╟─1e745340-6703-11eb-0853-2d40b6d3bc46
# ╟─426a4592-c04e-44fc-a01f-a1b61b823eeb
# ╟─08bb40ae-956e-40c5-a18e-b1907dadfbb8
# ╟─057e6407-3f3d-4b4d-bca8-fd77014cdb76
# ╟─0e7c8540-a939-49ed-89a6-46588c4b0e58
# ╟─7dc2bb38-6704-11eb-2aed-8563be2b3d89
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
