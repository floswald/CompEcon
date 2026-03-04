### A Pluto.jl notebook ###
# v0.20.23

using Markdown
using InteractiveUtils

# ╔═╡ 5d6b38c3-c977-44fd-9ef4-cc931b3b334f
begin
	using PlutoUI
	using Colors  # working with colors later
	using Dates # and with dates
end

# ╔═╡ e32c0efb-f88f-4a18-9d9b-ee0b9bdc7857
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
		font-size: x-large
	}
</style>
"""

# ╔═╡ dd6d9c4c-da95-40fd-945b-cadf8fae508a
html"<button onclick='present()'>present</button>"



# ╔═╡ 505963ac-853c-11ec-028c-b34d1d0e028f
md"""
# Julia Bootcamp

Florian Oswald, $(Dates.format(Dates.today(), "dd u yyyy"))
"""

# ╔═╡ 43077757-7064-4fa9-9ab2-ab8875a425ac
html"<button onclick='present()'>present</button>"

# ╔═╡ b182aaf9-6b81-4697-8a37-83ff03fba00e
md"""
## Assigning Variables and Mathematical Operations

* We assign with the `=` sign
* Your variable names can be any Unicode character
* Strings are in double quotes `"` and single quotes `'` are characters
* We can to `LaTeX` completion with the TAB key.
"""

# ╔═╡ b6f354d2-ace2-4605-bf6a-10acc1b9170a
md"""
#
"""

# ╔═╡ 0f882cf2-a25f-4481-b8c7-15e7aa780a10
x = 4

# ╔═╡ 883d1dae-d6aa-4c42-8676-50dbcd3ab5c9
y = x ^ 2

# ╔═╡ 0d32140e-26c7-46d6-a97b-97d279eedf5e
α = 1/3  # type \alpha and hit TAB

# ╔═╡ 8687b097-97c3-4882-acf1-801ec0c01d2d
β = 2/3

# ╔═╡ 672bc5e6-fd9d-476c-81c8-c046a9d055dc
α + β == 1

# ╔═╡ 4ca5b69a-545b-4713-88f0-592182ee439d
😄, 💃, 🍕 = (3, 1, 4)  # \:pizza: and TAB

# ╔═╡ 6bf1f569-c6f8-43d0-9ea6-e77f3db4c7c4
ifelse(😄 + 💃 == 🍕, md"🎉 this is the correct, OMG", md"🤮 Oh no, totally wrong")

# ╔═╡ 0f37a2d6-7431-4135-875a-6a49537b69cb


# ╔═╡ 0e3b68ed-6627-4246-b736-55a2942fff86
md"""
#
"""

# ╔═╡ c8181ff7-7edf-46b2-91ce-1b0ae9221c92
md"""
We have the special updating assignment operators as well:

```julia
x += 1 # x = x + 1
x -= 2 # x = x - 2
x *= 4 # x = x * 4
x /= 1.4 # x = x / 1.4
```
"""

# ╔═╡ b848b674-bd41-432f-9ed4-542bd991780b
md"""
we can write really terse code in multiplication as long as the number is on the left of the variable:
"""

# ╔═╡ 88513608-ac93-466f-b9ec-6f249e97731f
5x + 3α - 2β

# ╔═╡ 30f00ec5-3f97-4624-8b2f-397fc5c97e71
md"""
Every object in julia has a *type*, and this is really important. We can learn the type of any object by doing
"""

# ╔═╡ b8df2f83-5877-41c1-87f9-0d70001f3043
typeof(🍕)

# ╔═╡ c4d1cb6b-7226-4f2d-a9f6-4c0cb541483e
typeof("¿Cuál es el significado de qué onda wey?")

# ╔═╡ a11f932d-0e0e-4bc4-8497-6b6236fbce96
md"""
#
"""

# ╔═╡ 9b9160b8-4c60-4a6e-821d-1f4b9c78c9e4
md"""
by the way, string interpolation is really nice with the `$` operator:
"""

# ╔═╡ 3f5625cd-2718-402b-9ef0-7ae3e1eba7d7
🍺 = 2

# ╔═╡ 111deaa0-2970-4e53-92dc-8636cb723b72
md"""
I'll eat $(🍕) 🍕 and I'll drink $(🍺) 🍺. Make that $(🍺 + 1) 🍺.
"""

# ╔═╡ 9bbab050-ad99-4bcc-be23-50d4b1379108
md"""
```julia
"I'll eat $(🍕) 🍕 and I'll drink $(🍺) 🍺. Make that $(🍺 + 1) 🍺."
```
"""

# ╔═╡ 6b302cc1-fc1e-4835-aa7d-6d3e3f56daac


# ╔═╡ 65cfcb70-b754-4816-b588-91c0efe72c01
md"""
## Boolean Operators
"""

# ╔═╡ 76dbda14-90ca-4910-873d-045c0ac29aae
1 == 1

# ╔═╡ d7435925-5479-4ff7-9c0e-89759db7f58c
true || false   # short circuit or

# ╔═╡ df64ae39-7593-434a-87b8-54178af73f76
true && false   # short circuit and

# ╔═╡ 23771d6f-a197-49fd-b53f-9df398598017
md"""

## basic built-in data types
"""

# ╔═╡ 8182aa7a-160b-4341-a429-2b1890b4107d
md"""
```julia
1::Int       # 64 bit integer on 64 bit Julia, no overflow warnings
1.0::Float64 # 64 bit float, defines NaN, -Inf, Inf
true::Bool   # boolean, allows "true" and "false"
'c'::Char    # character, allows Unicode
"s"::String  # strings, allows Unicode
```
"""

# ╔═╡ 45cd1145-bbcc-49cc-981d-997dd4ca652e
md"""
we can convert types with the `convert` function, or by just calling the *constructor* of a certain type (more on that later!):
"""

# ╔═╡ fa12276d-6ef4-42c5-a6b9-9cea4af344e4
convert(Float64,1)

# ╔═╡ 0bac8b82-3450-4ab3-8db4-d47cff57f24a
Float64(1)

# ╔═╡ 173f003a-6c10-4b81-9e0f-896a6681c08e
convert(Int,2.0)

# ╔═╡ 9fdf6eeb-8dec-4db4-8f76-808693d9e3af
Int(2.0)

# ╔═╡ 958d00a2-106b-4ff6-ad84-c8619803431d
md"""
#
"""

# ╔═╡ 63dc06e0-cad1-4519-8aed-44255dd63e80
string(true)

# ╔═╡ 51787899-7339-4210-aa62-c4d1960f2333
Int(true)

# ╔═╡ c4128a1b-1e1c-4808-9da7-895fc5b88e46
Bool(1)

# ╔═╡ 37e0b7f2-ecc2-40cc-8776-bf4abdb0e81f
Bool(2) #error

# ╔═╡ 63d4b74a-c51c-4876-af20-af35a61931a3
zero(1.1)  # the additive identity element of typeof(1.1)

# ╔═╡ 4abdd77f-7155-4fcd-b130-0c45c49dae81
typeof(1+3im)

# ╔═╡ 7a9e0bbe-5e5c-49d9-9f03-c4b75348007c
one(1+3im)  # multiplicative identity element of imaginary numbers

# ╔═╡ be63e503-76cf-4bed-b68b-ba1123215e16
π

# ╔═╡ 2751b1b6-cc43-4331-a0ec-6a3b6ed34f1d
floor(π), ceil(π), round(π, digits =3)

# ╔═╡ ba168312-dd09-446e-82c0-e59c888a5b42
parse(Int,"1") isa Int  # same as isa(parse(Int,"1"),Int)

# ╔═╡ 894dc9f8-72af-4e12-963c-f848699fd4f2
BigFloat(10)^1000

# ╔═╡ 65321f25-c155-448c-ab5f-d310a6bdb94e
md"""
Next to `convert` we can also *promote* types to a common type:
"""

# ╔═╡ 65f98399-4a1f-4c08-b479-452c3d23e88a
promote(1, 2.5)  # `upgrades` the Int to a Float

# ╔═╡ 4a353442-e563-4e2f-917f-e31e0059019b
md"""
## Strings
"""

# ╔═╡ 0b51f9e2-49db-40e6-8538-dc6f3a3b56b5
s = "¿Cuál es el significado" 

# ╔═╡ 4c0c2f5e-2336-4be1-bcd7-bca51a51d9f6
typeof(s)

# ╔═╡ c5bceb53-3dd1-48b9-b36d-e9ed5bd6a55c
s * " de qué onda wey?"    # the * operator concatenates a string

# ╔═╡ e415a8ef-c9d1-404e-a945-0613e3118a53
string("hi"," there")

# ╔═╡ d4558619-6fce-4cf7-9552-10553d0b13c1
string("number = ",112)

# ╔═╡ 8da9efe7-1366-40f0-99a5-5cacb43a9b08
md"""
#
"""

# ╔═╡ bd00eff7-031a-4cb4-ac5c-67a97538d9b6
md"""
#

There are bunch of *special strings* in julia as well. Like in this notebook, I'm using *markdown strings* all the time with `md"string"` (part of the `Markdown` package).
"""

# ╔═╡ 0be453a4-7b06-4d9c-9868-3ca8ee341f83
md"""
This is a markdown string. You guys know [markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/)?
"""

# ╔═╡ c2bf25cd-43c0-4739-8978-21de5b2cd0ac
md"""
Raw strings are good for windows file paths: 
"""

# ╔═╡ cf3c2069-da2f-423f-9cf6-6285ad94af59
raw"C:\MyWindows\Path"

# ╔═╡ 856b1263-61d0-4d60-bf41-292d2cfcf012
md"""
## File System
"""

# ╔═╡ e2471749-1374-47e7-8013-d0071b1d5ee0
md"""
Oh, file paths. Never hard code a file path. use this instead:
"""

# ╔═╡ 64f9e174-0855-49fb-8dfa-d90adae7c268
joinpath("path","to","file")   # the file separater (the slash) is OS specific

# ╔═╡ e2ba69c5-94f4-4ec9-8acb-85bb8311f893
md"""
you can refer to the location of the current file
"""

# ╔═╡ 872590dc-9756-48b6-9bf0-f7e1d8d01501
@__FILE__

# ╔═╡ 6a126422-62cc-4b8e-998b-5fa11520049b
@__DIR__  # current directory. useful for scripts and programs

# ╔═╡ 9cbb941a-bbf6-49a1-892c-962f16bbab90
pwd()  # useful in an interactive session

# ╔═╡ 9286d7d7-4eea-4236-83d2-f6c3ccc8bd0f
cd(".")  # change to directory (the dot is the current directory!)

# ╔═╡ 8f40a4da-4534-48b9-bd5b-4255fc199a3b
md"""
#
"""

# ╔═╡ c77df580-26b5-4c61-a4cc-22859c073c49
md"""
#
"""

# ╔═╡ b26020a0-bb82-4261-be06-f39162edad13
contains("There are many football clubs in Barelona", "football")

# ╔═╡ 567e6a01-baca-4c9e-b1f9-dba2885a0805
occursin("football", "There are many football clubs in Barelona")

# ╔═╡ 42e71a94-29c3-43e2-a669-a62fb54a3ca7
r = r"A|B"  # a regex

# ╔═╡ d29a6c41-e72b-4be9-a695-09c835375483
occursin(r,"CDE")

# ╔═╡ 13c888eb-59f4-4777-8a06-dbc5c4f94e4a
md"""
#
"""

# ╔═╡ 57b72616-2eb4-4154-a5a2-df5c02220417
occursin(r,"The A-Team")

# ╔═╡ a74db094-81c7-4f23-af47-9a93aecca866
match(r, "The A-Team is Ace, Buddy")  # find first match

# ╔═╡ 2f507515-bf94-48f5-9473-7195abdaa3ca
eachmatch(r, "The A-Team is Ace, Buddy")  # find all matches

# ╔═╡ 060482dc-38cc-4a8b-b114-7cf9f4fa6b94
[e.match for e in eachmatch(r, "The A-Team is Ace, Buddy")]  

# ╔═╡ 3c37e656-c960-4846-b94e-76eeb17c7814
md"""
Wow, what's that? An Array! What's an array? ➡ a *Collection*!
"""

# ╔═╡ d1cba411-5ac6-4f1c-a6d6-004070ee4ee6
md"""
## Collections

In julia you have many different containers for data, each useful for a different purpose. Collections are called *iterables* in julia, because you can *iterate* over them, i.e. traverse them one by one and do stuff with each element. Notice that sometimes you can only *read* each element (and not write).

*Indexing*, i.e. *getting an element from a collection* is done with the `[]` operator in julia, like if `c` is a collection, 

```
c[4]
```
you would get the *fourth element* of `c`.

**Julia indexing starts at 1!**

#

### Tuples and NamedTuples

Tuples are immutable (often short) sequences of values. *immutable* means you can't change them.
"""

# ╔═╡ ee73f510-26e0-491f-9ff9-da12acb920fe
w = (1,2,"what's up",🍕)

# ╔═╡ bd9dc1c7-eb73-458b-bfd7-cf043311a881
w[1]

# ╔═╡ d8760510-1773-44c9-9f59-f3bcd3badb0e
w[3]

# ╔═╡ 3b483860-094c-41b0-8f2a-f99e08abe29c
w[4] = 10  # cannot change a tuple, i.e. cannot assign a different value

# ╔═╡ c7e68933-095d-4fd7-a938-12a93856f298
md"""
#

NamedTuples are similar, but you can give names. 
"""

# ╔═╡ 5ce16643-19c2-4f56-81c3-e5865e656a6e
ww = (one = 1, two = 2, three = "what's up", 🍔 = 🍕)

# ╔═╡ 527925b4-5bef-4299-8947-2f78e3c71c65
ww[1]   # can still index by position  

# ╔═╡ 87782135-a05d-4e84-ad8e-b4d163632904
ww[:three]  # by name as a "Symbol" (the : creates a symbol)

# ╔═╡ 43012bd6-83b4-41f4-ac8a-1cabea0e1417
ww[:🍔]   # 🍔 is just another name!

# ╔═╡ 89b15836-c931-4902-b3c8-faaa0c6e4761
md"""
or with the object accessor `.`
"""

# ╔═╡ 92c3561d-a180-4e72-80b0-f936c7ad51d1
ww.two   # or with the object accessor `.`

# ╔═╡ 4d64e715-3d3d-4a5f-90fb-328052c3ff97
md"""
## Ranges

A range is a sequence with fixed step size. The advantage of julia ranges is that they are computed *lazily*, i.e. we never store an entire array of values. We only store 3 values: `start`, `stop` and `step`:
"""

# ╔═╡ 6c676131-b7b0-4faa-9261-9ac6b14ccc32
ra = 0:2:12  

# ╔═╡ c096fc85-3a1c-4667-8e62-595a65b65b8c
typeof(ra)

# ╔═╡ 778e0c66-e9cf-45ab-8fc8-95955a208bd7
rb = range(0, stop = 10, length = 11)

# ╔═╡ 4db3429f-6901-46dd-85ae-85c3b53c5993
typeof(rb)

# ╔═╡ 65422359-25c9-43db-90c0-161abbad4ac4
md"""
#

you can collect all values into a standard array with 
"""

# ╔═╡ c6445e9e-ea94-46a8-95e7-47ea642d23e0
myvalues = collect(ra)

# ╔═╡ 1ab25def-758c-4d6d-83e1-33fc37ec04aa
md"""
but most of the times you don't need that. we use ranges often to index other iterables, and so we go through the range on by one. for, example, if we want to get the fifth element of `ra`, the corresponding value is computed on the fly:
"""

# ╔═╡ 78160acc-fa24-4cd3-9d89-9750df24caac
ra[5]

# ╔═╡ b1210e5b-2ba9-47f5-b965-360b5c0cda88
ra[5] = 2

# ╔═╡ 833a7d75-12ea-44c6-b946-da287566dee1
md"""

#
ranges can be built on many data types, not just numbers.
"""

# ╔═╡ 8fe2d586-65ce-4df2-8b17-3406b95ab914
letters = 'a':'z'

# ╔═╡ df54be49-1936-4f93-a12f-717538146314
letters[10]

# ╔═╡ 1438bcde-9d01-4d5e-b273-f675a5383e67
letters[4]

# ╔═╡ ac6f68fd-5c84-4650-98f1-b26f4a7bc547
range(colorant"red", stop=colorant"green", length=15)

# ╔═╡ 70598515-4f53-4c0a-92a2-ff18ac36c3f5
dr = Date(2014,1,29):Day(1):Date(2014,2,3)

# ╔═╡ dc8722ce-2a0e-4a87-8cb9-5704c74ed7fd
dr[2]

# ╔═╡ 3a801d9e-bbbf-4d72-9dc5-05e10babe43e
typeof(:a => 1)

# ╔═╡ 51988aba-83b8-4757-be99-5152c628abdc
md"""
## Pairs

* We have an important building block for `key => value` assignments called `Pair`.
* `key` and `value` can have any datatype.
* Pairs are the building blocks of `Dict`s (below)
"""

# ╔═╡ d4223b2c-3347-4038-a8a0-9a6b224f9bcd
 = "anything"

# ╔═╡ ffe63034-c0c9-482b-be17-553beaa429d7
7.9 => "anything"


# ╔═╡ 08fb3ea6-06f3-462d-8bdf-8359b6ed085b
md"""
#
"""

# ╔═╡ 681eaddd-5fe2-4abe-8fdc-1ae77eb4ef9e
my_pair = Pair("key1",3.3)

# ╔═╡ 8704f468-45b8-40f8-b9b7-e2bf66005cd2
my_pair.first

# ╔═╡ 3e48da15-eedf-4472-b182-07aa4cac9418
my_pair.second

# ╔═╡ 56b39540-cbde-47b7-9b12-f6e285066e54
# also directly with the arrow
my_pair2 = "key2" => 1.12

# ╔═╡ 6768aba8-5135-4b11-a9a8-81a84c130c61
md"""
## Dictionaries

* Similar to `R` `list` objects
* Similar to `python` `dicts`
* Similar to *linked lists* in FORTRAN
* like a `map` in `C++`.

We have a `key => value` structure. the `key` can be any type, as can of course the `value`.
"""

# ╔═╡ b48a6589-22a1-4dec-9bd5-96d6fb33d8b8
phonebook = Dict(:john => 34221, :mary => 12344)

# ╔═╡ a858c992-d9f0-47c0-9a74-e42ef9f543fe
typeof(phonebook)

# ╔═╡ d02618a3-720d-42f1-89fb-ff80733e2339
phonebook[:john]

# ╔═╡ 7f873cab-e58e-4e3c-bf75-b60cf9628648
md"""
#
"""

# ╔═╡ cd456c1f-0b63-45f7-aea2-f9f2a205bbb0
phonebook[:peter] = 43210  # notice once it's created, assign with '='

# ╔═╡ 51d37b9d-f630-4ed3-9ec4-699cd68470cd
phonebook["florian"] = 12334  # wrong type of key

# ╔═╡ a3397a22-3917-4782-a4b4-ea330293b7cf
md"""
#
"""

# ╔═╡ 666f5e87-5e14-4cd0-8c44-497d11562414
typeof(phonebook)

# ╔═╡ 5d9eea1e-3f09-4634-9a8a-91000fe9bdde
Dict( k => rand([true,false],rand(1:4)) for k in 1:2 )  # Dict constructor 

# ╔═╡ 3473b870-4e8d-443f-b9eb-ece08da11790
# OrderedDict preservers ordering. DataStructures.jl package. 

# ╔═╡ 11efb440-cf18-4e8a-9751-f92a0a85f96e
keys(phonebook)

# ╔═╡ 87a56c3a-1e2e-489e-a790-783180e6cc21
values(phonebook)

# ╔═╡ ae65a5fd-c90f-4277-93eb-32dbdfff9273
collect(values(phonebook))

# ╔═╡ d488f5d3-149c-4ce5-892b-7d113b712dfe
md"""
#
"""

# ╔═╡ a42fcc5d-2998-48cd-a5c6-aa97be940af0
for (k,v) in phonebook
	println("The number of $k is $v")
end

# ╔═╡ b8061445-404d-46c6-a811-4f4cb566fb25
haskey(phonebook, :florian)

# ╔═╡ 341e2132-520c-4cbc-8fc7-82aa2e18c707
myanonom = p -> p.first == :peter


# ╔═╡ 2046420f-ad09-4143-9072-0320d20b3ef3
filter( p -> p.first == :peter, phonebook)  # x -> 2x is an anonymous function. later.

# ╔═╡ d29e9d34-2a67-49e8-9cf8-fd279df01015
filter( myanonom, phonebook)  # x -> 2x is an anonymous function. later.

# ╔═╡ e125a1af-ce81-491b-b7a2-c3e7e0ee8216
filter( p -> p.second > 12500, phonebook)

# ╔═╡ 060bc6c4-cb85-4ee8-98f8-91656a478631
md"""
#
"""

# ╔═╡ fe9a68ee-d59b-4b33-a720-c426f3577d37
md"""
#
"""

# ╔═╡ d64bdfdb-50d5-476d-81ae-2543e0e246da
begin
	q(text) = Markdown.MD(Markdown.Admonition("tip", "Question", [text]));
	info(text) = Markdown.MD(Markdown.Admonition("info", "Info", [text]));
	danger(text) = Markdown.MD(Markdown.Admonition("danger", "Caution", [text]));
end

# ╔═╡ ca104c99-5ee6-4647-8a3d-b27ddc8de067
danger(md"*Assigning a value to a variable* in julia means to **bind** a value to a name. Particularly for collections of more than one value (like an array), one has to be careful with assigning arrays like `x = y`, since both `x` and `y` will refer to the same values.")

# ╔═╡ 066a7ddd-7203-44aa-9029-0566f91a0348
q(md"""
* create a create a variable s1 that contains the word "hello"
* create a variable n that contains your name as a string
* use the `println` function to print the sentence "hello, n, welcome to julia!" where you want to evaluate the value of `n` inside the string.
""")

# ╔═╡ b24fcce2-f729-49e2-9cbc-b0cf28ca6e33
q(md"""
* save the path of the current directory into a variable `dir`
* look at `?mkdir` and create a new folder `bootcamp` in your tempdir.
* you can get your tempdir with `tempdir`
* use `cd` to go into the new `bootcamp` folder
* use `cd` again to go back to `dir`
""")

# ╔═╡ cc346dd2-5920-46b7-b192-db59ce4f04d6
q(md"""
* look at `?findall` to find all the positions of the the characters `'g'` or 😄 (!) in "The weather is good today, I'm not going to take an umbrella 😄"
""")

# ╔═╡ 6caf7a73-7377-4e6f-9858-b9cdc141746d
q(md"""
* Create a `Dict` with keys `1,3,5,7`
* The set of numbers `1,3,5,7` should be represent by a `range`.
* The value for each key should be the value of the key raised to the third power.
* Filter the elements with value greater than 21
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Colors = "~0.12.8"
PlutoUI = "~0.7.34"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "97293cbf5d0edff7c6b483aec7e8f0597b7530a0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

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

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

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

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"

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

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

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
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╠═e32c0efb-f88f-4a18-9d9b-ee0b9bdc7857
# ╠═dd6d9c4c-da95-40fd-945b-cadf8fae508a
# ╠═5d6b38c3-c977-44fd-9ef4-cc931b3b334f
# ╟─505963ac-853c-11ec-028c-b34d1d0e028f
# ╟─43077757-7064-4fa9-9ab2-ab8875a425ac
# ╟─b182aaf9-6b81-4697-8a37-83ff03fba00e
# ╟─ca104c99-5ee6-4647-8a3d-b27ddc8de067
# ╟─b6f354d2-ace2-4605-bf6a-10acc1b9170a
# ╠═0f882cf2-a25f-4481-b8c7-15e7aa780a10
# ╠═883d1dae-d6aa-4c42-8676-50dbcd3ab5c9
# ╠═0d32140e-26c7-46d6-a97b-97d279eedf5e
# ╠═8687b097-97c3-4882-acf1-801ec0c01d2d
# ╠═672bc5e6-fd9d-476c-81c8-c046a9d055dc
# ╠═4ca5b69a-545b-4713-88f0-592182ee439d
# ╠═6bf1f569-c6f8-43d0-9ea6-e77f3db4c7c4
# ╠═0f37a2d6-7431-4135-875a-6a49537b69cb
# ╟─0e3b68ed-6627-4246-b736-55a2942fff86
# ╟─c8181ff7-7edf-46b2-91ce-1b0ae9221c92
# ╟─b848b674-bd41-432f-9ed4-542bd991780b
# ╠═88513608-ac93-466f-b9ec-6f249e97731f
# ╟─30f00ec5-3f97-4624-8b2f-397fc5c97e71
# ╠═b8df2f83-5877-41c1-87f9-0d70001f3043
# ╠═c4d1cb6b-7226-4f2d-a9f6-4c0cb541483e
# ╟─a11f932d-0e0e-4bc4-8497-6b6236fbce96
# ╟─9b9160b8-4c60-4a6e-821d-1f4b9c78c9e4
# ╠═3f5625cd-2718-402b-9ef0-7ae3e1eba7d7
# ╟─111deaa0-2970-4e53-92dc-8636cb723b72
# ╟─9bbab050-ad99-4bcc-be23-50d4b1379108
# ╠═6b302cc1-fc1e-4835-aa7d-6d3e3f56daac
# ╟─65cfcb70-b754-4816-b588-91c0efe72c01
# ╠═76dbda14-90ca-4910-873d-045c0ac29aae
# ╠═d7435925-5479-4ff7-9c0e-89759db7f58c
# ╠═df64ae39-7593-434a-87b8-54178af73f76
# ╟─23771d6f-a197-49fd-b53f-9df398598017
# ╟─8182aa7a-160b-4341-a429-2b1890b4107d
# ╟─45cd1145-bbcc-49cc-981d-997dd4ca652e
# ╠═fa12276d-6ef4-42c5-a6b9-9cea4af344e4
# ╠═0bac8b82-3450-4ab3-8db4-d47cff57f24a
# ╠═173f003a-6c10-4b81-9e0f-896a6681c08e
# ╠═9fdf6eeb-8dec-4db4-8f76-808693d9e3af
# ╟─958d00a2-106b-4ff6-ad84-c8619803431d
# ╠═63dc06e0-cad1-4519-8aed-44255dd63e80
# ╠═51787899-7339-4210-aa62-c4d1960f2333
# ╠═c4128a1b-1e1c-4808-9da7-895fc5b88e46
# ╠═37e0b7f2-ecc2-40cc-8776-bf4abdb0e81f
# ╠═63d4b74a-c51c-4876-af20-af35a61931a3
# ╠═4abdd77f-7155-4fcd-b130-0c45c49dae81
# ╠═7a9e0bbe-5e5c-49d9-9f03-c4b75348007c
# ╠═be63e503-76cf-4bed-b68b-ba1123215e16
# ╠═2751b1b6-cc43-4331-a0ec-6a3b6ed34f1d
# ╠═ba168312-dd09-446e-82c0-e59c888a5b42
# ╠═894dc9f8-72af-4e12-963c-f848699fd4f2
# ╟─65321f25-c155-448c-ab5f-d310a6bdb94e
# ╠═65f98399-4a1f-4c08-b479-452c3d23e88a
# ╟─4a353442-e563-4e2f-917f-e31e0059019b
# ╠═0b51f9e2-49db-40e6-8538-dc6f3a3b56b5
# ╠═4c0c2f5e-2336-4be1-bcd7-bca51a51d9f6
# ╠═c5bceb53-3dd1-48b9-b36d-e9ed5bd6a55c
# ╠═e415a8ef-c9d1-404e-a945-0613e3118a53
# ╠═d4558619-6fce-4cf7-9552-10553d0b13c1
# ╟─8da9efe7-1366-40f0-99a5-5cacb43a9b08
# ╟─066a7ddd-7203-44aa-9029-0566f91a0348
# ╟─bd00eff7-031a-4cb4-ac5c-67a97538d9b6
# ╠═0be453a4-7b06-4d9c-9868-3ca8ee341f83
# ╟─c2bf25cd-43c0-4739-8978-21de5b2cd0ac
# ╠═cf3c2069-da2f-423f-9cf6-6285ad94af59
# ╟─856b1263-61d0-4d60-bf41-292d2cfcf012
# ╟─e2471749-1374-47e7-8013-d0071b1d5ee0
# ╠═64f9e174-0855-49fb-8dfa-d90adae7c268
# ╟─e2ba69c5-94f4-4ec9-8acb-85bb8311f893
# ╠═872590dc-9756-48b6-9bf0-f7e1d8d01501
# ╠═6a126422-62cc-4b8e-998b-5fa11520049b
# ╠═9cbb941a-bbf6-49a1-892c-962f16bbab90
# ╠═9286d7d7-4eea-4236-83d2-f6c3ccc8bd0f
# ╟─8f40a4da-4534-48b9-bd5b-4255fc199a3b
# ╟─b24fcce2-f729-49e2-9cbc-b0cf28ca6e33
# ╟─c77df580-26b5-4c61-a4cc-22859c073c49
# ╠═b26020a0-bb82-4261-be06-f39162edad13
# ╠═567e6a01-baca-4c9e-b1f9-dba2885a0805
# ╠═42e71a94-29c3-43e2-a669-a62fb54a3ca7
# ╠═d29a6c41-e72b-4be9-a695-09c835375483
# ╟─cc346dd2-5920-46b7-b192-db59ce4f04d6
# ╟─13c888eb-59f4-4777-8a06-dbc5c4f94e4a
# ╠═57b72616-2eb4-4154-a5a2-df5c02220417
# ╠═a74db094-81c7-4f23-af47-9a93aecca866
# ╠═2f507515-bf94-48f5-9473-7195abdaa3ca
# ╠═060482dc-38cc-4a8b-b114-7cf9f4fa6b94
# ╟─3c37e656-c960-4846-b94e-76eeb17c7814
# ╟─d1cba411-5ac6-4f1c-a6d6-004070ee4ee6
# ╠═ee73f510-26e0-491f-9ff9-da12acb920fe
# ╠═bd9dc1c7-eb73-458b-bfd7-cf043311a881
# ╠═d8760510-1773-44c9-9f59-f3bcd3badb0e
# ╠═3b483860-094c-41b0-8f2a-f99e08abe29c
# ╟─c7e68933-095d-4fd7-a938-12a93856f298
# ╠═5ce16643-19c2-4f56-81c3-e5865e656a6e
# ╠═527925b4-5bef-4299-8947-2f78e3c71c65
# ╠═87782135-a05d-4e84-ad8e-b4d163632904
# ╠═43012bd6-83b4-41f4-ac8a-1cabea0e1417
# ╟─89b15836-c931-4902-b3c8-faaa0c6e4761
# ╠═92c3561d-a180-4e72-80b0-f936c7ad51d1
# ╟─4d64e715-3d3d-4a5f-90fb-328052c3ff97
# ╠═6c676131-b7b0-4faa-9261-9ac6b14ccc32
# ╠═c096fc85-3a1c-4667-8e62-595a65b65b8c
# ╠═778e0c66-e9cf-45ab-8fc8-95955a208bd7
# ╠═4db3429f-6901-46dd-85ae-85c3b53c5993
# ╟─65422359-25c9-43db-90c0-161abbad4ac4
# ╠═c6445e9e-ea94-46a8-95e7-47ea642d23e0
# ╟─1ab25def-758c-4d6d-83e1-33fc37ec04aa
# ╠═78160acc-fa24-4cd3-9d89-9750df24caac
# ╠═b1210e5b-2ba9-47f5-b965-360b5c0cda88
# ╟─833a7d75-12ea-44c6-b946-da287566dee1
# ╠═8fe2d586-65ce-4df2-8b17-3406b95ab914
# ╠═df54be49-1936-4f93-a12f-717538146314
# ╠═1438bcde-9d01-4d5e-b273-f675a5383e67
# ╠═ac6f68fd-5c84-4650-98f1-b26f4a7bc547
# ╠═70598515-4f53-4c0a-92a2-ff18ac36c3f5
# ╠═dc8722ce-2a0e-4a87-8cb9-5704c74ed7fd
# ╠═3a801d9e-bbbf-4d72-9dc5-05e10babe43e
# ╟─51988aba-83b8-4757-be99-5152c628abdc
# ╠═d4223b2c-3347-4038-a8a0-9a6b224f9bcd
# ╠═ffe63034-c0c9-482b-be17-553beaa429d7
# ╟─08fb3ea6-06f3-462d-8bdf-8359b6ed085b
# ╠═681eaddd-5fe2-4abe-8fdc-1ae77eb4ef9e
# ╠═8704f468-45b8-40f8-b9b7-e2bf66005cd2
# ╠═3e48da15-eedf-4472-b182-07aa4cac9418
# ╠═56b39540-cbde-47b7-9b12-f6e285066e54
# ╟─6768aba8-5135-4b11-a9a8-81a84c130c61
# ╠═b48a6589-22a1-4dec-9bd5-96d6fb33d8b8
# ╠═a858c992-d9f0-47c0-9a74-e42ef9f543fe
# ╠═d02618a3-720d-42f1-89fb-ff80733e2339
# ╟─7f873cab-e58e-4e3c-bf75-b60cf9628648
# ╠═cd456c1f-0b63-45f7-aea2-f9f2a205bbb0
# ╠═51d37b9d-f630-4ed3-9ec4-699cd68470cd
# ╟─a3397a22-3917-4782-a4b4-ea330293b7cf
# ╠═666f5e87-5e14-4cd0-8c44-497d11562414
# ╠═5d9eea1e-3f09-4634-9a8a-91000fe9bdde
# ╠═3473b870-4e8d-443f-b9eb-ece08da11790
# ╠═11efb440-cf18-4e8a-9751-f92a0a85f96e
# ╠═87a56c3a-1e2e-489e-a790-783180e6cc21
# ╠═ae65a5fd-c90f-4277-93eb-32dbdfff9273
# ╟─d488f5d3-149c-4ce5-892b-7d113b712dfe
# ╠═a42fcc5d-2998-48cd-a5c6-aa97be940af0
# ╠═b8061445-404d-46c6-a811-4f4cb566fb25
# ╠═341e2132-520c-4cbc-8fc7-82aa2e18c707
# ╠═2046420f-ad09-4143-9072-0320d20b3ef3
# ╠═d29e9d34-2a67-49e8-9cf8-fd279df01015
# ╠═e125a1af-ce81-491b-b7a2-c3e7e0ee8216
# ╟─060bc6c4-cb85-4ee8-98f8-91656a478631
# ╟─6caf7a73-7377-4e6f-9858-b9cdc141746d
# ╟─fe9a68ee-d59b-4b33-a720-c426f3577d37
# ╟─d64bdfdb-50d5-476d-81ae-2543e0e246da
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
