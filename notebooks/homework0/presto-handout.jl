### A Pluto.jl notebook ###
# v0.20.23

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ a1b2c3d4-1001-11ee-0001-000000000001
begin
	using Plots
	using PlutoUI
end

# ╔═╡ a1b2c3d4-1001-11ee-0002-000000000001
md"""

# **Homework 1**: _Presto Spesa — Types and Setup_
`Computational Economics`, Spring 2026, Florian Oswald

This is the first in a series of problem sets in which we will build a simulation of Esselunga's **Presto Spesa** self-scanning system. Along the way you will learn about Julia's custom data types, how to run agent-based simulations, and how to find optimal policy parameters.

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box that runs a test on your code and gives immediate feedback. Edit the code, run the cell, and the check updates automatically.

"""

# ╔═╡ a1b2c3d4-1001-11ee-0003-000000000001
# Edit the code below to set your name and student ID

student = (name = "Firstname Lastname", id = "student_id_here")

# ╔═╡ a1b2c3d4-1001-11ee-0004-000000000001
begin
	if student.name == "Firstname Lastname"
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please fill in your **name** above."]))
	elseif student.id == "student_id_here"
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please fill in your **student ID** above."]))
	else
		Markdown.MD(Markdown.Admonition("correct", "Welcome!", [md"Notebook submitted by **$(student.name)** ($(student.id))."]))
	end
end

# ╔═╡ 31f5def8-15e0-4f51-855a-e5bb7de8e65c
Resource("https://techprincess.it/wp-content/uploads/2023/03/Presto-Spesa-Esselunga.jpg")

# ╔═╡ f13c6f0e-c1c7-42da-bbdd-5e97cc3275a9
md"""
The system is attractive to customers because it reduces waiting time and gives them a running total of their spend. It is attractive to Esselunga because customers who enjoy shopping more tend to visit more frequently and spend more per visit.

### The reputation system

Because customers scan their own items, there is a risk of deliberate non-scanning (theft) or accidental omission. Esselunga manages this through **random spot-checks** at the exit: a member of staff re-scans a portion of the customer's basket. If an unscanned item is found, the customer is placed on a **blacklist** for a fixed number of subsequent visits. While blacklisted, they face **more frequent checks** — a reputational penalty. Once the blacklist period expires, the customer returns to the normal check regime.

Note that checks are clean: if you scanned everything correctly, there is nothing to find. The only way to end up on the blacklist is to have actually skipped scanning an item and then been caught. The burden on honest shoppers comes purely from the **frequency of checks** itself — being stopped and re-scanned takes time and is psychologically unpleasant, even if you are always cleared.

### What we want to model

The central question for Esselunga is: **how should the blacklist system be parametrised?**

A strict policy (long blacklist, very frequent checks while on it) deters cheating but imposes a high burden on customers — including honest ones who simply find frequent checks unpleasant. If the system becomes too burdensome, customers abandon Presto Spesa altogether and return to normal checkout, undermining the whole programme.

Let's get started.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0010-000000000001
md"""
## Exercise 1: Shopper Types

Not all customers are alike. We will model three discrete **honesty types**, which differ in their probability of (intentionally or accidentally) failing to scan an item during a trip.

| Type | Description | Skip probability |
|------|-------------|-----------------|
| `H`  | Honest | ≈ 0 |
| `M`  | Occasional offender | moderate |
| `C`  | Chronic offender | high |

In Julia, a fixed set of named values like this is best represented with an **enum**.

#### Exercise 1.1 — Define the `ShopperType` enum

👉 Define an enum called `ShopperType` with values `H`, `M`, and `C`, using the `@enum` macro.

> **Hint:** Type `?@enum` in the REPL for documentation. The syntax is:
> ```julia
> @enum MyType val1 val2 val3
> ```
"""

# ╔═╡ a1b2c3d4-1001-11ee-0011-000000000001
# your code here
# @enum ShopperType ...

# ╔═╡ a1b2c3d4-1001-11ee-0012-000000000001
let
	if !@isdefined(ShopperType)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `ShopperType` using `@enum`."]))
	else
		try
			vals = instances(ShopperType)
			names = Symbol.(vals)
			if :H in names && :M in names && :C in names
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`ShopperType` has values `H`, `M`, `C`. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Make sure your enum has values named exactly `H`, `M`, and `C`."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"Something went wrong: $(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0020-000000000001
md"""
## Exercise 2: The `Shopper` Struct

Now we will define a custom type to represent an individual shopper. Each shopper has:

- A **honesty type** (one of `H`, `M`, `C`).
- A **blacklist status** — a boolean indicating whether they are currently on the blacklist.
- A **blacklist counter** — an integer counting how many more shopping trips remain on the blacklist (0 if not blacklisted).

#### Exercise 2.1 — Define the `Shopper` struct

👉 Define a **mutable** struct `Shopper` with fields:
- `type :: ShopperType`
- `blacklisted :: Bool`
- `blacklist_remaining :: Int`

> **Why mutable?** We will update a shopper's blacklist status in place during the simulation. A `mutable struct` allows field values to be changed after construction; a plain `struct` does not.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0021-000000000001
# your code here
# mutable struct Shopper
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0022-000000000001
let
	if !@isdefined(Shopper)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define the `Shopper` struct."]))
	elseif !ismutable(Shopper)
		Markdown.MD(Markdown.Admonition("danger", "Not mutable", [md"Make sure to declare `Shopper` as a `mutable struct`."]))
	else
		try
			s = Shopper(H, false, 0)
			if s.type == H && s.blacklisted == false && s.blacklist_remaining == 0
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`Shopper` is correctly defined. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Check that the fields are in order: `type`, `blacklisted`, `blacklist_remaining`."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"Could not construct a `Shopper`. Error: $(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0030-000000000001
md"""
#### Exercise 2.2 — A convenience constructor

The default constructor requires all three arguments. It would be convenient to create a shopper by specifying only their type, with the blacklist fields set to their default (not blacklisted).

👉 Write a constructor method `Shopper(t::ShopperType)` that returns a `Shopper` with `blacklisted = false` and `blacklist_remaining = 0`.

> **Hint:** An _inner constructor_ lives inside the `struct` block. An _outer constructor_ is a new method defined outside the struct, using the same name as the type. Both work here — an outer constructor is simpler. However: In this Pluto notebook you need to add this in a _single_ code block (otherwise it complains about `Shopper` being defined twice). So, modify your definition of `Shopper` in the above cell like that:

```julia
begin  # you add this line
	mutable struct Shopper
		# your definitions
	end
	# here you define the outer constructor
	# Shopper(t::ShopperType) = 

end # closes the block

```

"""

# ╔═╡ a1b2c3d4-1001-11ee-0032-000000000001
let
	if !@isdefined(Shopper)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `Shopper` first (Exercise 2.1)."]))
	else
		try
			s = Shopper(M)
			if s isa Shopper && s.type == M && s.blacklisted == false && s.blacklist_remaining == 0
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`Shopper(M)` works correctly. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Check that `blacklisted` and `blacklist_remaining` are set to their defaults."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"Could not call `Shopper(M)`. Error: $(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0040-000000000001
md"""
#### Exercise 2.3 — Custom display with `Base.show`

By default, Julia prints a struct by listing all its fields. We can override this to get a nicer, more readable display.

👉 Add a method to `Base.show` for `Shopper` so that it prints something like:

```
Shopper | type: H | blacklisted: false | remaining: 0
```

> **Hint:** The signature should be:
> ```julia
> function Base.show(io::IO, s::Shopper)
>     print(io, ...)
> end
> ```
> Use string interpolation (`\$(s.type)` etc.) to fill in the field values.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0041-000000000001
# your code here


# ╔═╡ a1b2c3d4-1001-11ee-0042-000000000001
# Run this cell to see your show method in action:
if @isdefined(Shopper) && @isdefined(ShopperType)
	try
		Shopper(C)
	catch
		md"Define the convenience constructor in 2.2 first."
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0043-000000000001
let
	if !@isdefined(Shopper)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `Shopper` first."]))
	else
		try
			s = Shopper(H)
			str = sprint(show, s)
			if occursin("Shopper", str) && occursin("H", str)
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"Your `show` method works. The output is: $(str) ✓"]))
			else
				Markdown.MD(Markdown.Admonition("warning", "Almost there!", [md"Your `show` method runs but the output doesn't clearly show the type or the word `Shopper`. Current output: `$(str)`"]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"Error in `show`: $(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0050-000000000001
md"""
## Exercise 3: The `StorePolicy` Struct

The store controls the blacklist system through a small set of parameters. We collect these into a `StorePolicy` struct.

#### Exercise 3.1 — Define `StorePolicy`

👉 Define a **mutable** struct `StorePolicy` with the following fields and an inner constructor that accepts each as a keyword argument with the default value shown:

| Field | Keyword arg | Type | Default | Meaning |
|-------|-------------|------|---------|---------|
| `p_check_normal` | `p_normal` | `Float64` | `0.1` | Probability of being checked on a given trip (not blacklisted) |
| `p_check_blacklisted` | `p_black` | `Float64` | `0.5` | Probability of being checked while blacklisted |
| `blacklist_duration` | `b_duration` | `Int` | `3` | Number of trips a customer stays on the blacklist after being caught |
| `share_H` | `share_H` | `Float64` | `0.9` | Population share of honest shoppers |
| `share_M` | `share_M` | `Float64` | `0.05` | Population share of occasional offenders |
| `p_skip_H` | `p_skip_H` | `Float64` | `0.1` | Probability a type-H shopper fails to scan an item |
| `p_skip_M` | `p_skip_M` | `Float64` | `0.3` | Probability a type-M shopper fails to scan an item |
| `p_skip_C` | `p_skip_C` | `Float64` | `0.8` | Probability a type-C shopper fails to scan an item |

The keyword argument column shows the name to use when constructing a policy, e.g. `StorePolicy(p_normal = 0.2, b_duration = 5)`. Fields not specified take their default value.

> **Note:** We do not need to store `share_C` explicitly — it is always `1 - share_H - share_M`. You will use this in Exercise 4.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0051-000000000001
# your code here
# mutable struct StorePolicy
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0052-000000000001
let
	if !@isdefined(StorePolicy)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define the `StorePolicy` struct."]))
	elseif !ismutable(StorePolicy())
		Markdown.MD(Markdown.Admonition("danger", "Should be immutable", [md"Declare `StorePolicy` as `struct`, not `mutable struct`."]))
	else
		try
			pol = StorePolicy()
			checks = all(p -> 0 ≤ p ≤ 1,
						[pol.p_check_normal,pol.p_check_blacklisted])
			if checks
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`StorePolicy` is correctly defined. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Check the field names and order."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"Could not construct a `StorePolicy`. Error: $(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0060-000000000001
md"""
#### Exercise 3.2 — A helper function: `p_skip`

We now have all the skip probabilities stored in `StorePolicy`. We need a convenient way to retrieve the right one for a given shopper.

👉 Write a function `p_skip(t::ShopperType, pol::StorePolicy) :: Float64` that returns the skip probability corresponding to type `t`.

> **Hint:** You can use a ternary chain:
> ```julia
> t == H ? pol.p_skip_H : t == M ? pol.p_skip_M : pol.p_skip_C
> ```
> or a more readable `if/elseif/else` block. In PS2, you will call this as `p_skip(shopper.type, pol)`.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0061-000000000001
# your code here
# function p_skip(t::ShopperType, pol::StorePolicy) :: Float64
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0062-000000000001
let
	if !@isdefined(p_skip)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `p_skip`."]))
	elseif !@isdefined(StorePolicy)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `StorePolicy` first."]))
	else
		try
			pol = StorePolicy()
			if p_skip(H,pol) < 1 &&
					 p_skip(H,pol) > 0 &&
					 p_skip(M,pol) < 1 &&
					 p_skip(M,pol) > 0
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`p_skip` returns the correct value for each type. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Check that each type maps to the right field."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"$(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0070-000000000001
md"""
#### Exercise 3.3 — Validation and `Base.show` for `StorePolicy`

👉 Add a method to `Base.show` for `StorePolicy` that prints a readable summary. For example:

```
StorePolicy
  check prob (normal):      0.10
  check prob (blacklisted): 0.50
  blacklist duration:       3 trips
  population shares  — H: 0.70  M: 0.20  C: 0.10
  skip probabilities — H: 0.01  M: 0.15  C: 0.60
```

Note that `share_C` should be computed on the fly as `1 - share_H - share_M`.

👉 Also write a function `is_valid(pol::StorePolicy) :: Bool` that returns `true` if and only if:
- All probabilities (`p_check_normal`, `p_check_blacklisted`, `p_skip_H`, `p_skip_M`, `p_skip_C`) are in $[0, 1]$
- `share_H + share_M ≤ 1` (and both shares are non-negative)
- `blacklist_duration ≥ 0`
"""

# ╔═╡ a1b2c3d4-1001-11ee-0071-000000000001
# your Base.show for StorePolicy here
# function Base.show(io::IO, pol::StorePolicy)
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0072-000000000001
# your is_valid function here
# function is_valid(pol::StorePolicy) :: Bool
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0073-000000000001
let
	if !@isdefined(is_valid)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `is_valid`."]))
	elseif !@isdefined(StorePolicy)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `StorePolicy` first."]))
	else
		try
			good = StorePolicy()  # all defaults are valid
			bad1 = StorePolicy(p_normal = 1.5)                      # p_check_normal > 1
			bad2 = StorePolicy(share_H = 0.8, share_M = 0.5)        # shares sum > 1
			bad3 = StorePolicy(b_duration = -1)                      # negative duration
			bad4 = StorePolicy(p_skip_C = 1.2)                      # p_skip_C > 1

			if is_valid(good) && !is_valid(bad1) && !is_valid(bad2) && !is_valid(bad3) && !is_valid(bad4)
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`is_valid` correctly validates all fields. ✓"]))
			else
				results = "good: $(is_valid(good)), bad1: $(is_valid(bad1)), bad2: $(is_valid(bad2)), bad3: $(is_valid(bad3)), bad4: $(is_valid(bad4))"
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Some checks failed. Results: $(results)"]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"$(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0074-000000000001
# Run this cell to inspect your StorePolicy display:
if @isdefined(StorePolicy)
	StorePolicy()
end

# ╔═╡ a1b2c3d4-1001-11ee-0080-000000000001
md"""
## Exercise 4: Blacklist Functions

Before we simulate shopping trips, we need a few utility functions to manage blacklist status.

#### Exercise 4.1 — `is_blacklisted`

👉 Write a function `is_blacklisted(s::Shopper) :: Bool` that returns `true` if the shopper is currently blacklisted.

> **Note:** Although `s.blacklisted` already stores this information, wrapping it in a function is good practice: it gives us a clean interface and makes the simulation code more readable.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0081-000000000001
# your code here
# function is_blacklisted(s::Shopper) :: Bool
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0082-000000000001
let
	if !@isdefined(is_blacklisted)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `is_blacklisted`."]))
	else
		try
			s1 = Shopper(H, false, 0)
			s2 = Shopper(M, true, 3)
			if is_blacklisted(s1) == false && is_blacklisted(s2) == true
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`is_blacklisted` works correctly. ✓"]))
			else
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Check: a shopper with `blacklisted = false` should return `false`, and vice versa."]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"$(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0090-000000000001
md"""
#### Exercise 4.2 — `blacklist!` and `decrement_blacklist!`

👉 Write a function `blacklist!(s::Shopper, pol::StorePolicy)` that:
- Sets `s.blacklisted = true`
- Sets `s.blacklist_remaining = pol.blacklist_duration`

The `!` suffix is a Julia convention indicating that the function **mutates** its argument in place.

👉 Write a function `decrement_blacklist!(s::Shopper)` that:
- Decreases `s.blacklist_remaining` by 1
- If `blacklist_remaining` reaches 0, sets `blacklisted = false`

This function will be called once per shopping trip for each blacklisted shopper.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0091-000000000001
# your code here
# function blacklist!(s::Shopper, pol::StorePolicy)
#     ...
# end

# ╔═╡ ac45e94f-3cef-4e32-a261-f5bf1fe2dc9c
# function decrement_blacklist!(s::Shopper)
#     ...
# end

# ╔═╡ a1b2c3d4-1001-11ee-0092-000000000001
let
	if !@isdefined(blacklist!)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `blacklist!`."]))
	elseif !@isdefined(decrement_blacklist!)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `decrement_blacklist!`."]))
	else
		try
			pol = StorePolicy()
			s = Shopper(H)

			blacklist!(s, pol)
			check1 = s.blacklisted == true && s.blacklist_remaining == 3

			decrement_blacklist!(s)
			check2 = s.blacklisted == true && s.blacklist_remaining == 2

			decrement_blacklist!(s)
			decrement_blacklist!(s)
			check3 = s.blacklisted == false && s.blacklist_remaining == 0

			if check1 && check2 && check3
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"`blacklist!` and `decrement_blacklist!` work correctly. ✓"]))
			else
				results = "blacklist!: $(check1), decrement step 1: $(check2), decrement to 0: $(check3)"
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"Some checks failed. Results: $(results)"]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"$(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0100-000000000001
md"""
## Exercise 5: Initialising a Population

We now have all the pieces to create a population of shoppers.

#### Exercise 5.1 — `initialize_population`

👉 Write a function `initialize_population(N::Int, pol::StorePolicy) :: Vector{Shopper}` that:

1. Draws each shopper's type independently from the distribution defined by `pol.share_H`, `pol.share_M`, and (implicitly) `share_C = 1 - share_H - share_M`.
2. Returns a `Vector` of `N` freshly created `Shopper`s, all starting with no blacklist.

> **Hint:** `rand()` returns a uniform draw from $[0,1)$. You can use it to assign types by checking thresholds:
> ```
> u < share_H              → type H
> u < share_H + share_M    → type M
> otherwise                → type C
> ```
> You can build the vector with a list comprehension or a `for` loop with `push!`.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0101-000000000001
# your code here
# function initialize_population(N::Int, pol::StorePolicy) :: Vector{Shopper}
#     ...
# end


# ╔═╡ a1b2c3d4-1001-11ee-0102-000000000001
let
	if !@isdefined(initialize_population)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `initialize_population`."]))
	elseif !@isdefined(StorePolicy) || !@isdefined(Shopper)
		Markdown.MD(Markdown.Admonition("danger", "Not defined", [md"Define `StorePolicy` and `Shopper` first."]))
	else
		try
			N = 10000
			pol = StorePolicy()
			pop = initialize_population(N, pol)

			type_ok   = pop isa Vector{Shopper}
			length_ok = length(pop) == N
			fresh_ok  = all(s -> !s.blacklisted && s.blacklist_remaining == 0, pop)

			n_H = count(s -> s.type == H, pop)
			n_M = count(s -> s.type == M, pop)
			n_C = count(s -> s.type == C, pop)

			# allow ±5 percentage points tolerance for sampling noise
			share_ok = abs(n_H/N - pol.share_H) < 0.05 &&
			           abs(n_M/N - pol.share_M) < 0.05 &&
			           abs(n_C/N - (1 - pol.share_H - pol.share_M)) < 0.05

			if type_ok && length_ok && fresh_ok && share_ok
				Markdown.MD(Markdown.Admonition("correct", "Got it!", [md"Population initialised correctly: $(n_H) H, $(n_M) M, $(n_C) C (out of 1000). ✓"]))
			else
				msg = "Vector type OK: $(type_ok). Length OK: $(length_ok). All fresh: $(fresh_ok). Shares approx correct: $(share_ok)."
				Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [md"$(msg)"]))
			end
		catch e
			Markdown.MD(Markdown.Admonition("danger", "Error", [md"$(e)"]))
		end
	end
end

# ╔═╡ a1b2c3d4-1001-11ee-0110-000000000001
md"""
## Exercise 6: Visualising the Population

Let's put it all together with a small visualisation.

#### Exercise 6.1 — Bar chart of type distribution

The slider below controls the population size $N$.

👉 Write a function `plot_population(N::Int, pol::StorePolicy)` that:
1. Calls `initialize_population(N, pol)` to generate a population.
2. Counts the number of shoppers of each type.
3. Returns a bar chart (using `Plots.jl`) showing the counts for H, M, and C, with horizontal dashed lines marking the expected counts implied by the population shares in `pol`.

Use the `default_policy` defined in the next cell. The chart should update automatically when you move the slider.

> **Hint:** 
> ```julia
> bar(["H", "M", "C"], [n_H, n_M, n_C], ...)
> hline!([pol.share_H * N, pol.share_M * N, (1 - pol.share_H - pol.share_M) * N], ...)
> ```
"""

# ╔═╡ a1b2c3d4-1001-11ee-0112-000000000001
md"Population size (creates 
variable `N_pop`): $(@bind N_pop Slider(50:50:2000, default=500, show_value=true))"

# ╔═╡ a1b2c3d4-1001-11ee-0113-000000000001
# your code here
# function plot_population(N::Int, pol::StorePolicy)
#     pop = initialize_population(N, pol)
#     ...
# end


# ╔═╡ 8b4b2488-46a2-4980-aedd-48f7c77adf67
plot_population(N_pop,StorePolicy())

# ╔═╡ a1b2c3d4-1001-11ee-0130-000000000001
md"""
---
## Summary

In this problem set you have:

- Defined an **enum** `ShopperType` to represent the three honesty types.
- Defined a **mutable struct** `Shopper` with a convenience constructor and a custom `show` method.
- Defined an **mutable struct** `StorePolicy` holding all policy, population, and behavioural parameters, with input validation.
- Written a helper `p_skip` to retrieve the skip probability for any shopper type.
- Written functions `is_blacklisted`, `blacklist!`, and `decrement_blacklist!` to manage reputation state.
- Written `initialize_population` to draw a heterogeneous population from the type distribution.

In **PS2** we will model a single shopping episode: the shopper decides (probabilistically, based on their type) whether to scan all items, the store decides whether to check, and the outcome updates the shopper's reputation and utility.
"""

# ╔═╡ a1b2c3d4-1001-11ee-0200-000000000001
md"### Function Library"

# ╔═╡ a1b2c3d4-1001-11ee-0201-000000000001
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ a1b2c3d4-1001-11ee-0202-000000000001
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ a1b2c3d4-1001-11ee-0203-000000000001
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ a1b2c3d4-1001-11ee-0204-000000000001
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ a1b2c3d4-1001-11ee-0205-000000000001
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ a1b2c3d4-1001-11ee-0206-000000000001
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.41.6"
PlutoUI = "~0.7.79"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "611156d6d29d62bf3c49625ded31ba8d6d63d5bc"

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
git-tree-sha1 = "a21c5464519504e41e0cbc91f0188e8ca23d7440"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "21d088c496ea22914fe80906eb5bce65755e5ec8"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.1"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e357641bb3e0638d353c4b29ea0e40ea644066a6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.3"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

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
git-tree-sha1 = "27af30de8b5445644e8ffe3bcb0d72049c089cf1"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.3+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "01ba9d15e9eae375dc1eb9589df76b3572acd3f2"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+0"

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
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "b7bfd56fa66616138dfe5237da4dc13bbd83c67f"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ee0585b62671ce88e48d3409733230b401c9775c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.22"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "7dd7173f7129a1b6f84e0f03e0890cd1189b0659"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.22+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "24f6def62397474a297bfcec22384101609142ed"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.86.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5e6fe50ae7f23d171f44e311c2960294aaa0beb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.19"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "b3ad4a0255688dcb895a52fafbaae3023b588a90"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.4.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6893345fd6658c8e475d40155789f4860ac3b21"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.4+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

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
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "97bbca976196f2a1eb9607131cb108c69ec3f8a6"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "f04133fe05eff1667d2054c53d59f9122383fe05"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.2+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d0205286d9eceadc518742860bf23f703779a3d6"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.3+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

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
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "8785729fa736197687541f7053f6d8ab7fc44f92"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.10"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ff69a2b1330bcb730b9ac1ab7dd680176f5896b8"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.1010+0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

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
version = "2025.11.4"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0662b083e11420952f2e62e17eddae7fc07d5997"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.57.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
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
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "cb20a4eacda080e517e4deb9cfb6c7c518131265"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.6"

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
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3ac7038a98ef6977d44adeadc73cc6f596c08109"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.79"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "07a921781cab75691315adc645096ed5e370cb77"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "34f7e5d2861083ec7596af8b8c092531facf2192"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.8.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "da7adf145cce0d44e892626e647f9dcbe9cb3e10"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.8.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "9eca9fc3fe515d619ce004c83c31ffd3f85c7ccf"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.8.2+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "8f528b0851b5b7025032818eb5abbeb8a736f853"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.8.2+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
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
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

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
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

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
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "28145feabf717c5d65c1d5e09747ee7b1ff3ed13"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.6.3"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

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
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

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
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9cce64c0fdd1960b597ba7ecda2950b5ed957438"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.2+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "371cc681c00a3ccc3fbc5c0fb91f58ba9bec1ecf"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.13.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e015f211ebb898c8180887012b938f3851e719ac"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.55+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"
"""

# ╔═╡ Cell order:
# ╠═a1b2c3d4-1001-11ee-0001-000000000001
# ╟─a1b2c3d4-1001-11ee-0002-000000000001
# ╟─a1b2c3d4-1001-11ee-0003-000000000001
# ╟─a1b2c3d4-1001-11ee-0004-000000000001
# ╟─31f5def8-15e0-4f51-855a-e5bb7de8e65c
# ╟─f13c6f0e-c1c7-42da-bbdd-5e97cc3275a9
# ╟─a1b2c3d4-1001-11ee-0010-000000000001
# ╠═a1b2c3d4-1001-11ee-0011-000000000001
# ╟─a1b2c3d4-1001-11ee-0012-000000000001
# ╟─a1b2c3d4-1001-11ee-0020-000000000001
# ╠═a1b2c3d4-1001-11ee-0021-000000000001
# ╟─a1b2c3d4-1001-11ee-0022-000000000001
# ╟─a1b2c3d4-1001-11ee-0030-000000000001
# ╟─a1b2c3d4-1001-11ee-0032-000000000001
# ╟─a1b2c3d4-1001-11ee-0040-000000000001
# ╠═a1b2c3d4-1001-11ee-0041-000000000001
# ╟─a1b2c3d4-1001-11ee-0042-000000000001
# ╟─a1b2c3d4-1001-11ee-0043-000000000001
# ╟─a1b2c3d4-1001-11ee-0050-000000000001
# ╠═a1b2c3d4-1001-11ee-0051-000000000001
# ╟─a1b2c3d4-1001-11ee-0052-000000000001
# ╟─a1b2c3d4-1001-11ee-0060-000000000001
# ╠═a1b2c3d4-1001-11ee-0061-000000000001
# ╟─a1b2c3d4-1001-11ee-0062-000000000001
# ╟─a1b2c3d4-1001-11ee-0070-000000000001
# ╠═a1b2c3d4-1001-11ee-0071-000000000001
# ╠═a1b2c3d4-1001-11ee-0072-000000000001
# ╟─a1b2c3d4-1001-11ee-0073-000000000001
# ╠═a1b2c3d4-1001-11ee-0074-000000000001
# ╟─a1b2c3d4-1001-11ee-0080-000000000001
# ╠═a1b2c3d4-1001-11ee-0081-000000000001
# ╟─a1b2c3d4-1001-11ee-0082-000000000001
# ╟─a1b2c3d4-1001-11ee-0090-000000000001
# ╠═a1b2c3d4-1001-11ee-0091-000000000001
# ╠═ac45e94f-3cef-4e32-a261-f5bf1fe2dc9c
# ╟─a1b2c3d4-1001-11ee-0092-000000000001
# ╟─a1b2c3d4-1001-11ee-0100-000000000001
# ╠═a1b2c3d4-1001-11ee-0101-000000000001
# ╟─a1b2c3d4-1001-11ee-0102-000000000001
# ╟─a1b2c3d4-1001-11ee-0110-000000000001
# ╟─a1b2c3d4-1001-11ee-0112-000000000001
# ╠═a1b2c3d4-1001-11ee-0113-000000000001
# ╠═8b4b2488-46a2-4980-aedd-48f7c77adf67
# ╟─a1b2c3d4-1001-11ee-0130-000000000001
# ╟─a1b2c3d4-1001-11ee-0200-000000000001
# ╠═a1b2c3d4-1001-11ee-0201-000000000001
# ╠═a1b2c3d4-1001-11ee-0202-000000000001
# ╠═a1b2c3d4-1001-11ee-0203-000000000001
# ╠═a1b2c3d4-1001-11ee-0204-000000000001
# ╠═a1b2c3d4-1001-11ee-0205-000000000001
# ╠═a1b2c3d4-1001-11ee-0206-000000000001
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
