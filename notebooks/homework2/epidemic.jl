### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 2dcb18d0-0970-11eb-048a-c1734c6db842
begin
	using Plots
	using PlutoUI
end

# ╔═╡ 49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# WARNING FOR OLD PLUTO VERSIONS, DONT DELETE ME

html"""
<script>
const warning = html`
<h2 style="color: #800">Oopsie! You need to update Pluto to the latest version for this homework</h2>
<p>Close Pluto, go to the REPL, and type:
<pre><code>julia> import Pkg
julia> Pkg.update("Pluto")
</code></pre>
`

const super_old = window.version_info == null || window.version_info.pluto == null
if(super_old) {
	return warning
}
const version_str = window.version_info.pluto.substring(1)
const numbers = version_str.split(".").map(Number)
console.log(numbers)

if(numbers[0] > 0 || numbers[1] > 12 || numbers[2] > 1) {
	
} else {
	return warning
}

</script>

"""

# ╔═╡ 181e156c-0970-11eb-0b77-49b143cc0fc0
md"""

# **Homework 2**: _Spatial Epidemic Model_
`CCA Structural Econometrics`, Spring 2025

This homework is based on [Homework 5](https://htmlpreview.github.io/?https://github.com/mitmath/18S191/blob/Fall20/homework/homework5/hw5.html) of the MIT course computational thinking. I adapted the questions slightly and added some explanations. 

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box, which runs a test case on your code, and provides feedback based on the result. Simply edit the code, run it, and the check runs again.

"""

# ╔═╡ 1f299cc6-0970-11eb-195b-3f951f92ceeb
# edit the code below to set your name and email

student = [
	(name = "Jazzy Jeff", email = "jazzy.jeff@yahoo.com"),
	(name = "Grandmaster Flash", email = "grandmaster.flash@aol.com")
	# add another row (and a comma) in this array if your team has 3 students:
	# (name = "Michael Jackson", email = "michael.jackson@gmail.com")
]


# press the ▶ button in the bottom right of this cell to run your edits
# or use Shift+Enter

# ╔═╡ 1bba5552-0970-11eb-1b9a-87eeee0ecc36
md"""

Submission by: **_$(student.name)_** ($(student.email))
"""

# ╔═╡ 28cdac74-5853-4728-9b8f-ccfa5e11a7ea
begin
	if (student[1].name == "Jazzy Jeff") 
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"You are not *really* called **Jazzy Jeff**. Please fill out name!"]))
	elseif (student[2].name == "Grandmaster Flash") 
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"You are not *really* called **Grandmaster Flash**. Please fill out name!"]))
	elseif !(contains(student[1].email, "@"))
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please enter a valid email address.  "]))
	elseif !(contains(student[2].email, "@"))
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please enter a valid email address.  "]))
	elseif (student[1].email == "jazzy.jeff@yahoo.com")
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please enter a valid email in the `student` tuple above.  "]))
	elseif (student[2].email == "grandmaster.flash@aol.com")
		Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Please enter a valid email in the `student` tuple above.  "]))
	end
end

# ╔═╡ be991b29-84ee-47ea-8628-d46c414470a0
md"""Homework 1 submitted by: $(join([s.name for s in student]," and "))"""

# ╔═╡ 2848996c-0970-11eb-19eb-c719d797c322
md"Loading required packages"

# ╔═╡ 69d12414-0952-11eb-213d-2f9e13e4b418
md"""
In this problem set, we will look at a simple **spatial** agent-based epidemic model: agents can interact only with other agents that are *nearby*.  

A simple approach is to use **discrete space**: each agent lives
in one cell of a square grid. For simplicity we will allow no more than
one agent in each cell, but this requires some care to
design the rules of the model to respect this.

Along the way, we will introduce and comment on some julia data types and features that are useful.
"""

# ╔═╡ 3e54848a-0954-11eb-3948-f9d7f07f5e23
md"""
## **Exercise 1:** _Wandering at random in 2D_

In this exercise we will implement a **random walk** on a 2D lattice (grid). At each time step, a walker jumps to a neighbouring position at random (i.e. chosen with uniform probability from the available adjacent positions).

"""

# ╔═╡ 3e623454-0954-11eb-03f9-79c873d069a0
md"""
#### Exercise 1.1
We define a struct type `Coordinate` that contains integers `x` and `y`.

Remember that you can get help about julia types and functions from the built-in help in the REPL. E.g you could type

	?struct

into your REPL to gather more info here.
"""

# ╔═╡ 0ebd35c8-0972-11eb-2e67-698fd2d311d2
struct Coordinate
	x::Int
	y::Int
end

# ╔═╡ 027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
md"""
👉 Construct a `Coordinate` located at the origin. Remember that for each data type we define, julia provides a default _constructor_ function which will fill in the element types in order.
"""

# ╔═╡ 3e858990-0954-11eb-3d10-d10175d8ca1c
md"""
👉 Write a function `make_tuple` that takes an object of type `Coordinate` and returns the corresponding tuple `(x, y)`. Boring, but useful later!
"""

# ╔═╡ 189bafac-0972-11eb-1893-094691b2073c
function make_tuple(c::Coordinate)
	
end

# ╔═╡ 73ed1384-0a29-11eb-06bd-d3c441b8a5fc
md"""
#### Exercise 1.2
In Julia, operations like `+` and `*` are just functions, and they are treated like any other function in the language. The only special property you can use the _infix notation_: you can write
```julia
1 + 2
```
instead of 
```julia
+(1, 2)
```
_(There are [lots of special 'infixable' function names](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm#L23-L24) that you can use for your own functions!)_

When you call it with the prefix notation, it becomes clear that it really is 'just another function', with lots of predefined methods.
"""

# ╔═╡ 9c9f53b2-09ea-11eb-0cda-639764250cee
md"""
> #### Extending + in the wild
> Because it is a function, we can add our own methods to it! This feature is super useful in general languages like Julia and Python, because it lets you use familiar syntax (`a + b*c`) on objects that are not necessarily numbers!
> 
> One example is the `RGB` type which defines _colors_ of a pixel for instance. It would define the intensity of `RED`, `GREEN` and `BLUE` of any given pixel. In Julia you are able to do:
> ```julia
> 0.5 * RGB(0.1, 0.7, 0.6)
> ```
> to multiply each color channel by $0.5$. This is possible because `Images.jl` [wrote a method](https://github.com/JuliaGraphics/ColorVectorSpace.jl/blob/master/src/ColorVectorSpace.jl#L131):
> ```julia
> *(::Real, ::AbstractRGB)::AbstractRGB
> ```

This an example of *function overloading*, or - more julian - of extending a method to a new type so that we can rely on _multiple dispatch_. Whatever happens when you do `a + b` will depend on what precisly `a` and `b` are. And now we are teaching julia how to do an operation on our new datatype. Cool, right?

👉 Your turn! Implement `addition` on two `Coordinate` structs by adding a method to `Base.:+`. Notice that `Base.` means that function `+` is part of the `Base` module, i.e. core julia. The `:` in front of the `+` makes a _quoted expression_ out of the simple function name `+`. This a way to address the function without calling it.

"""

# ╔═╡ e24d5796-0a68-11eb-23bb-d55d206f3c40
function Base.:+(a::Coordinate, b::Coordinate)

end

# ╔═╡ 96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
+(1, 2)

# ╔═╡ b0337d24-0a29-11eb-1fab-876a87c0973f
+

# ╔═╡ ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
Coordinate(3,4) + Coordinate(10,10) # uncomment to check + works

# ╔═╡ 71c358d8-0a2f-11eb-29e1-57ff1915e84a
md"""
#### Exercise 1.3
In our model, agents will be able to walk in 4 directions: up, down, left and right. We can define these directions as `Coordinate`s.
"""

# ╔═╡ 5278e232-0972-11eb-19ff-a1a195127297
# uncomment this:

# possible_moves = [
# 	Coordinate( 1, 0), 
# 	Coordinate( 0, 1), 
# 	Coordinate(-1, 0), 
# 	Coordinate( 0,-1),
# ]

# ╔═╡ 71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
md"""
👉 `rand(possible_moves)` gives a random possible move. Add this to the coordinate `Coordinate(4,5)` and see that it moves to a valid neighbor.
"""

# ╔═╡ 69151ce6-0aeb-11eb-3a53-290ba46add96
# Coordinate(4,5) + rand(possible_moves)

# ╔═╡ 3eb46664-0954-11eb-31d8-d9c0b74cf62b
md"""
We are able to make a `Coordinate` perform one random step, by adding a move to it. Great!

👉 Write a function `trajectory` that calculates a trajectory of a `Wanderer` `w` when performing `n` steps., i.e. the sequence of positions that the walker finds itself in.

Possible steps:
- Use `rand(possible_moves, n)` to generate a vector of `n` random moves. Each possible move will be equally likely.
- To compute the trajectory you can use either of the following two approaches:
  1. 🆒 Use the function `accumulate` (see the live docs for `accumulate`). Use `+` as the function passed to `accumulate` and the `w` as the starting value (`init` keyword argument). 
  1. Use a `for` loop calling `+`. 

"""

# ╔═╡ edf86a0e-0a68-11eb-2ad3-dbf020037019
function trajectory(w::Coordinate, n::Int)

	
end

# ╔═╡ 44107808-096c-11eb-013f-7b79a90aaac8
# test_trajectory = trajectory(Coordinate(4,4), 30) # uncomment to test

# ╔═╡ f83909b6-6638-11eb-0d9b-33285b7557b4
md"
> ### Keyword Arguments and Splatting
>
>In the next cell we define a function to plot a trajectory. Notice how we supply a set of _keyword arguments_ `kwargs` after the semicolon `;` . This will allow us to pass on `Plots.jl`-specific keywords (like `title`, or `xlabs` etc) down to the `plot!` function. 
>
> The splatting operator `...` will insert the elements of `kwargs`, whatever that is (a `Dict` or a `NamedTuple` etc) one by one as keywords in a `key = value` fashion. Read more about this [here](https://docs.julialang.org/en/v1/devdocs/functions/#Keyword-arguments).
>
> ### Splatting Arrays
> When combining arrays splatting is also useful, for example in here:
>
>	julia> a = rand(2)
>	2-element Array{Float64,1}:
>	 0.5249866328372776
>	 0.24650744117037426
>	
>	julia> [1.1,a]
>	2-element Array{Any,1}:
>	 1.1
>	  [0.5249866328372776, 0.24650744117037426]
>	
>	julia> [1.1,a...]
>	3-element Array{Float64,1}:
>	 1.1
>	 0.5249866328372776
>	 0.24650744117037426

"


# ╔═╡ 478309f4-0a31-11eb-08ea-ade1755f53e0
function plot_trajectory!(p::Plots.Plot, trajectory::Vector; kwargs...)
	plot!(p, make_tuple.(trajectory); 
		label=nothing, 
		linewidth=2, 
		linealpha=LinRange(1.0, 0.2, length(trajectory)),
		kwargs...)
end

# ╔═╡ 87ea0868-0a35-11eb-0ea8-63e27d8eda6e
try
	p = plot(ratio=1, size=(650,200))
	plot_trajectory!(p, test_trajectory; color="black", showaxis=false, axis=nothing, linewidth=4)
	p
catch
end

# ╔═╡ 51788e8e-0a31-11eb-027e-fd9b0dc716b5
# 	let
# 		long_trajectory = trajectory(Coordinate(4,4), 1000)

# 		p = plot(ratio=1)
# 		plot_trajectory!(p, long_trajectory)
# 		p
# 	end

# ^ uncomment to visualize a trajectory

# ╔═╡ 3ebd436c-0954-11eb-170d-1d468e2c7a37
md"""
#### Exercise 1.4
👉 Plot 10 trajectories of length 1000 on a single figure, all starting at the origin. Use the function `plot_trajectory!` as demonstrated above.

Remember from that you can compose plots like this:

```julia
let
	# Create a new plot with aspect ratio 1:1
	p = plot(ratio=1)

	plot_trajectory!(p, test_trajectory)      # plot one trajectory
	plot_trajectory!(p, another_trajectory)   # plot the second one
	...

	p
end
```
"""

# ╔═╡ dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
let
# your code here
end

# ╔═╡ b4d5da4a-09a0-11eb-1949-a5807c11c76c
md"""
#### Exercise 1.5
Agents live in a box of side length $2L$, centered at the origin. We need to decide (i.e. model) what happens when they reach the walls of the box (boundaries), in other words what kind of **boundary conditions** to use.

One relatively simple boundary condition is a **collision boundary**:

> Each wall of the box is a wall, modelled using "collision": if the walker tries to jump beyond the wall, it ends up at the position inside the box that is closest to the goal.

👉 Write a function `collide_boundary` which takes a `Coordinate` `c` and a size $L$, and returns a new coordinate that lies inside the box (i.e. ``[-L,L]\times [-L,L]``), but is closest to `c`. This is similar to `extend_mat` from Homework 1.
"""

# ╔═╡ 0237ebac-0a69-11eb-2272-35ea4e845d84
function collide_boundary(c::Coordinate, L::Number)

end

# ╔═╡ ad832360-0a40-11eb-2857-e7f0350f3b12
# collide_boundary(Coordinate(-12,-90), 10) # uncomment to test

# ╔═╡ b4ed2362-09a0-11eb-0be9-99c91623b28f
md"""
#### Exercise 1.6
👉  Implement a 3-argument method  of `trajectory` where the third argument is a size. The trajectory returned should be within the boundary (use `collide_boundary` from above). You can still use `accumulate` with an anonymous function that makes a move and then reflects the resulting coordinate, or use a for loop.

"""

# ╔═╡ 0665aa3e-0a69-11eb-2b5d-cd718e3c7432
function trajectory(c::Coordinate, n::Int, L::Number)

	
end

# ╔═╡ 0e5d9cc6-6601-11eb-32c2-7bb422b4ea25
# trajectory(Coordinate(0,0), 1000, 30)

# ╔═╡ 77e2f2d8-6636-11eb-14c5-532f59a119d7
md"""
#### Exercise 1.7
👉  Reproduce the plot from exercise 1.4 above where $L$ (_box size_) is bound to the slider `📦size`, defined below. Use your new `trajector` function from exercise 1.6 and use it like in 1.4. You should add a `title` argument to the initial `plot` call that shows how big the grid is.

"""

# ╔═╡ 799e6252-6603-11eb-194a-a7a42ccb9508
@bind 📦size Slider(20:60)

# ╔═╡ ecc9448e-6600-11eb-33fe-af85c472b2a8
let

	# plot here
end

# ╔═╡ 98ccb7fa-6603-11eb-386a-ad7c066df1f3


# ╔═╡ 3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
md"""
## **Exercise 2:** _Wanderering Agents_

In this exercise we will create Agents which have a location as well as some infection state information.

Let's define a type `Agent`. `Agent` contains a `position` (of type `Coordinate`), as well as a `status` of type `InfectionStatus`.)
"""

# ╔═╡ 35537320-0a47-11eb-12b3-931310f18dec
@enum InfectionStatus S I R

# ╔═╡ cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# define agent struct here:
mutable struct Agent
	position::Coordinate
	status::InfectionStatus # will be one of S,I,R
end
	

# ╔═╡ 814e888a-0954-11eb-02e5-0964c7410d30
md"""
#### Exercise 2.1
👉 Write a function `initialize` that takes parameters $N$ and $L$, where $N$ is the number of agents and $2L$ is the side length of the square box where the agents live.

It returns a `Vector` of `N` randomly generated `Agent`s. Their coordinates are randomly sampled in the ``[-L,L] \times [-L,L]`` box, and the agents are all susceptible, except one, chosen at random, which is infectious. I called him _patient zero_.
"""

# ╔═╡ 0cfae7ba-0a69-11eb-3690-d973d70e47f4
function initialize(N::Number, L::Number)

	
end

# ╔═╡ 7b93c2be-6637-11eb-36f8-13a2fde90a17
md"Defining some useful functions here for you..."

# ╔═╡ e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# Color based on infection status
color(s::InfectionStatus) = if s == S
	"blue"
elseif s == I
	"red"
else
	"green"
end

# ╔═╡ b5a88504-0a47-11eb-0eda-f125d419e909
# position(a::Agent) = a.position # uncomment this line

# ╔═╡ 87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# color(a::Agent) = color(a.status) # uncomment this line

# ╔═╡ 49fa8092-0a43-11eb-0ba9-65785ac6a42f
md"""
#### Exercise 2.2
👉 Write a function `visualize` that takes in a collection of agents as argument, and the box size `L`. It should plot a point for each agent at its location, coloured according to its status.

You can use the keyword argument `c=color.(agents)` inside your call to the plotting function make the point colors correspond to the infection statuses. Don't forget to use `ratio=1` to get a square plot. Also, remember the function `make_tuple` from above! 😉)
"""


# ╔═╡ 1ccc961e-0a69-11eb-392b-915be07ef38d
# function visualize(agents::Vector, L)
	
# 	return missing
# end

# ╔═╡ 634974d8-6621-11eb-0fed-b7190f40946d
# make_tuple.(position.(ags))

# ╔═╡ c2770f7a-6620-11eb-2c62-133d69041f6e
function visualize(agents::Vector, L; title = "")

end

# ╔═╡ 1f96c80a-0a46-11eb-0690-f51c60e57c3f
let
	N = 25
	L = 10
	# visualize(initialize(N, L), L) # uncomment this line!
end

# ╔═╡ f953e06e-099f-11eb-3549-73f59fed8132
md"""

### Exercise 3: Spatial epidemic model -- Dynamics

Last week we wrote a function `interact!` that takes two agents, `agent` and `source`, and an infection of type `InfectionRecovery`, which models the interaction between two agent, and possibly modifies `agent` with a new status.

This week, we define a new infection type, `CollisionInfectionRecovery`, and a new method that is the same as last week, except it **only infects `agent` if `agents.position==source.position`**.
"""	

# ╔═╡ e6dd8258-0a4b-11eb-24cb-fd5b3554381b
abstract type AbstractInfection end

# ╔═╡ de88b530-0a4b-11eb-05f7-85171594a8e8
struct CollisionInfectionRecovery <: AbstractInfection
	p_infection::Float64
	p_recovery::Float64
end

# ╔═╡ 80f39140-0aef-11eb-21f7-b788c5eab5c9
md"""

Write a function `interact!` that takes two `Agent`s and a `CollisionInfectionRecovery`, and:

- If the agents are at the same spot, causes a susceptible agent to communicate the desease from an infectious one with the correct probability.
- if the first agent is infectious, it recovers with some probability
"""

# ╔═╡ 3c49b96a-662b-11eb-0486-f34f8fe5119a
infect!(a::Agent) = a.status = I

# ╔═╡ 892abf8c-662a-11eb-33d8-7dda5618e7d2
infectuous(a::Agent) = a.status == I

# ╔═╡ b4e8892e-662f-11eb-3be3-89d65c9bdc69
susceptible(a::Agent) = a.status == S

# ╔═╡ fd78bba8-6631-11eb-1734-5f3d1ffe4a27
recovered(a::Agent) = a.status == R

# ╔═╡ e6f6669e-662e-11eb-210b-219ea0df4d33
maybe_recovers!(a::Agent, inf::CollisionInfectionRecovery) = rand() < inf.p_recovery ? a.status = R : nothing

# ╔═╡ 3e3811c8-662a-11eb-1863-ff3666ff96ed
function interact!(target::Agent, source::Agent, 
		infection::CollisionInfectionRecovery)
	# if source is infectuous, we need to worry about whether they meet
	# and whether they recover
	if infectuous(source)
		# If the agents are at the same spot and
		if position(target) == position(source)
			# target is susceptible
			if susceptible(target)
				# transmission happens
				 if (rand() < infection.p_infection)
					infect!(target)  # communicate disease
				end
			end
		end
		# see if the source recovers
		maybe_recovers!(source,infection)
	else
		# nothing to do
		
	end
	return nothing   # we operate on the inputs directly
end

# ╔═╡ 34778744-0a5f-11eb-22b6-abe8b8fc34fd
md"""
#### Exercise 3.1
Your turn!

👉 Write a function `step!` that takes a vector of `Agent`s, a box size `L` and an `infection`. This that does one step of the dynamics on a vector of agents. 

- Choose an Agent `source` at random.

- Move the `source` one step, and use `collide_boundary` to ensure that our agent stays within the box.

- For all _other_ agents, call `interact!(other_agent, source, infection)`.

- return the array `agents` again.
"""

# ╔═╡ 126359d0-662d-11eb-10f8-5fb1a16914d6
function random_walk!(a::Agent,L::Number)
	a.position = collide_boundary(a.position + rand(possible_moves), L)
end

# ╔═╡ bb659f88-662c-11eb-0478-e5ddaa4cbe28
function step!(agents::Vector, L::Number, infection::AbstractInfection)

end

# ╔═╡ 1fc3271e-0a45-11eb-0e8d-0fd355f5846b
md"""
#### Exercise 3.2
If we call `step!` `N` times, then every agent will have made one step, on average. Let's call this one _sweep_ of the simulation.

👉 Create a before-and-after plot of ``k_{sweeps}=1000`` sweeps. 

- Initialize a new vector of agents (`N=50`, `L=40`, `infection` is given as `pandemic` below). 
- Plot the state using `visualize`, and save the plot as a variable `plot_before`.
- Run `k_sweeps` sweeps.
- Plot the state again, and store as `plot_after`.
- Combine the two plots into a single figure using
```julia
plot(plot_before, plot_after)
```
"""

# ╔═╡ 18552c36-0a4d-11eb-19a0-d7d26897af36
pandemic = CollisionInfectionRecovery(0.5, 0.0001)

# ╔═╡ 4e7fd58a-0a62-11eb-1596-c717e0845bd5
@bind k_sweeps Slider(1:10000, default=1000)

# ╔═╡ 778c2490-0a62-11eb-2a6c-e7fab01c6822
# let
# 	N = 50
# 	L = 40
	
# 	plot_before = plot(1:3) # replace with your code
# 	plot_after = plot(1:3)
	
# 	plot(plot_before, plot_after)
# end

# ╔═╡ 189d24e2-662e-11eb-32bd-3f839039b5f4
let
	N = 50
	L = 10
	agents = initialize(N, L)
	plot_before = visualize(agents, L)
	for k in 1:k_sweeps
		step!(agents, L, pandemic)
	end
	plot_after = visualize(agents, L, title = "After $k_sweeps sweeps")
	if L < 11
		plot(plot_before, plot_after, xticks = -L:L, yticks = -L:L)
	else
		plot(plot_before, plot_after)
	end
end

# ╔═╡ e964c7f0-0a61-11eb-1782-0b728fab1db0
md"""
#### Exercise 3.3

Every time that you move the slider, a completely new simulation is created an run. This makes it hard to view the progress of a single simulation over time. So in this exercise, we we look at a single simulation, and plot the S, I and R curves.

👉 Plot the SIR curves of a single simulation, with the same parameters as in the previous exercise. Use `k_sweep_max = 10000` as the total number of sweeps.
"""

# ╔═╡ 4d83dbd0-0a63-11eb-0bdc-757f0e721221
k_sweep_max = 10000

# ╔═╡ ef27de84-0a63-11eb-177f-2197439374c5
let

	
end

# ╔═╡ 201a3810-0a45-11eb-0ac9-a90419d0b723
md"""
#### Exercise 3.4 (optional)
Let's make our plot come alive! There are two options to make our visualization dynamic:

👉1️⃣ Precompute one simulation run and save its intermediate states using `deepcopy`. You can then write an interactive visualization that shows both the state at time $t$ (using `visualize`) and the history of $S$, $I$ and $R$ from time $0$ up to time $t$. $t$ is controlled by a slider.

👉2️⃣ Use `@gif` from Plots.jl to turn a sequence of plots into an animation. Be careful to skip about 50 sweeps between each animation frame, otherwise the GIF becomes too large.

This an optional exercise, and our solution to 2️⃣ is given below.
"""

# ╔═╡ e5040c9e-0a65-11eb-0f45-270ab8161871
# let
# 	N = 50
# 	L = 30
	
# 	missing
# end

# ╔═╡ 1ca4a5d8-6647-11eb-1ac1-db32e5abb575
let    

end

# ╔═╡ 0e6b60f6-0970-11eb-0485-636624a0f9d7
if student.name == "Jazzy Doe"
	md"""
	!!! danger "Before you submit"
	    Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
	"""
end

# ╔═╡ 0a82a274-0970-11eb-20a2-1f590be0e576
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 0aa666dc-0970-11eb-2568-99a6340c5ebd
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 3ffedb0a-663b-11eb-0e76-3366590392a5
hint(md"""
	
## Broadcasting

We mentioned in class that julia can _broadcast_ functions over collections (like vectors). This also works for our own created functions (if it's sufficiently straightforward to know _how_ to map your function over a vector it's automatic, otherwise we need to implement a special `broadcast` method for it). More details [in the manual](https://docs.julialang.org/en/v1/manual/arrays/#Broadcasting).

You should remember for this exercise that just attaching a dot `.` to the end of your own function will _broadcast_ it over a vector argument! `color.` above clearly does that, but you'll need it somewhere else too!
""")

# ╔═╡ 8475baf0-0a63-11eb-1207-23f789d00802
hint(md"""
After every sweep, count the values $S$, $I$ and $R$ and push! them to 3 arrays. 
""")

# ╔═╡ f9b9e242-0a53-11eb-0c6a-4d9985ef1687
hint(md"""
```julia
let
	N = 50
	L = 40

	x = initialize(N, L)
	
	# initialize to empty arrays
	Ss, Is, Rs = Int[], Int[], Int[]
	
	Tmax = 200
	
	@gif for t in 1:Tmax
		for i in 1:50N
			step!(x, L, pandemic)
		end

		#... track S, I, R in Ss Is and Rs
		
		left = visualize(x, L)
	
		right = plot(xlim=(1,Tmax), ylim=(1,N), size=(600,300))
		plot!(right, 1:t, Ss, color=color(S), label="S")
		plot!(right, 1:t, Is, color=color(I), label="I")
		plot!(right, 1:t, Rs, color=color(R), label="R")
	
		plot(left, right)
	end
end
```
""")

# ╔═╡ 0acaf3b2-0970-11eb-1d98-bf9a718deaee
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 0afab53c-0970-11eb-3e43-834513e4632e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 0b21c93a-0970-11eb-33b0-550a39ba0843
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 0b470eb6-0970-11eb-182f-7dfb4662f827
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 0b6b27ec-0970-11eb-20c2-89515ee3ab88
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
let
	# we need to call Base.:+ instead of + to make Pluto understand what's going on
	# oops
	if @isdefined(Coordinate)
		result = Base.:+(Coordinate(3,4), Coordinate(10,10))

		if result isa Missing
			still_missing()
		elseif !(result isa Coordinate)
			keep_working(md"Make sure that your return a `Coordinate`. 🧭")
		elseif result.x != 13 || result.y != 14
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 0b901714-0970-11eb-0b6a-ebe739db8037
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 66663fcc-0a58-11eb-3568-c1f990c75bf2
if !@isdefined(origin)
	not_defined(:origin)
else
	let
		if origin isa Missing
			still_missing()
		elseif !(origin isa Coordinate)
			keep_working(md"Make sure that `origin` is a `Coordinate`.")
		else
			if origin == Coordinate(0,0)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ ad1253f8-0a34-11eb-265e-fffda9b6473f
if !@isdefined(make_tuple)
	not_defined(:make_tuple)
else
	let
		result = make_tuple(Coordinate(2,1))
		if result isa Missing
			still_missing()
		elseif !(result isa Tuple)
			keep_working(md"Make sure that you return a `Tuple`, like so: `return (1, 2)`.")
		else
			if result == (2,1)
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ 058e3f84-0a34-11eb-3f87-7118f14e107b
if !@isdefined(trajectory)
	not_defined(:trajectory)
else
	let
		c = Coordinate(8,8)
		t = trajectory(c, 100)
		
		if t isa Missing
			still_missing()
		elseif !(t isa Vector)
			keep_working(md"Make sure that you return a `Vector`.")
		elseif !(all(x -> isa(x, Coordinate), t))
			keep_working(md"Make sure that you return a `Vector` of `Coordinate`s.")
		else
			if length(t) != 100
				almost(md"Make sure that you return `n` elements.")
			elseif 1 < length(Set(t)) < 90
				correct()
			else
				keep_working(md"Are you sure that you chose each step randomly?")
			end
		end
	end
end

# ╔═╡ 4fac0f36-0a59-11eb-03d0-632dc9db063a
if !@isdefined(initialize)
	not_defined(:initialize)
else
	let
		N = 200
		result = initialize(N, 1)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Vector) || length(result) != N
			keep_working(md"Make sure that you return a `Vector` of length `N`.")
		elseif any(e -> !(e isa Agent), result)
			keep_working(md"Make sure that you return a `Vector` of `Agent`s.")
		elseif length(Set(result)) != N
			keep_working(md"Make sure that you create `N` **new** `Agent`s. Do not repeat the same agent multiple times.")
		elseif sum(a -> a.status == S, result) == N-1 && sum(a -> a.status == I, result) == 1
			if 8 <= length(Set(a.position for a in result)) <= 9
				correct()
			else
				keep_working(md"The coordinates are not correctly sampled within the box.")
			end
		else
			keep_working(md"`N-1` agents should be Susceptible, 1 should be Infectious.")
		end
	end
end

# ╔═╡ d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
bigbreak = html"<br><br><br><br>";

# ╔═╡ fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
bigbreak

# ╔═╡ ed2d616c-0a66-11eb-1839-edf8d15cf82a
bigbreak

# ╔═╡ e84e0944-0a66-11eb-12d3-e12ae10f39a6
bigbreak

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.40.1"
PlutoUI = "~0.7.55"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "88b2a21e3f9bf15e4f63dfd4a1af9cbf23349185"

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
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "403f2d8e209681fcbd9468a8514efff3ea08452e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.29.0"

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
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

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
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "0ff136326605f8e06e9bcf085a356ab312eef18a"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.13"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "9cb62849057df859575fc1dda1e91b82f8609709"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.13+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

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
git-tree-sha1 = "cd714447457c660382fe634710fb56eb255ee42e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.6"

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
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

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
git-tree-sha1 = "a9697f1d06cc3eb3fb3ad49cc67f2cfabaac31ea"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.16+0"

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
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "dae01f8c2e069a683d3a6e17bbae5070ab94786f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.9"

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

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

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
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

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
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

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
# ╟─1bba5552-0970-11eb-1b9a-87eeee0ecc36
# ╟─49567f8e-09a2-11eb-34c1-bb5c0b642fe8
# ╟─181e156c-0970-11eb-0b77-49b143cc0fc0
# ╠═1f299cc6-0970-11eb-195b-3f951f92ceeb
# ╠═28cdac74-5853-4728-9b8f-ccfa5e11a7ea
# ╠═be991b29-84ee-47ea-8628-d46c414470a0
# ╟─2848996c-0970-11eb-19eb-c719d797c322
# ╠═2dcb18d0-0970-11eb-048a-c1734c6db842
# ╟─69d12414-0952-11eb-213d-2f9e13e4b418
# ╟─fcafe15a-0a66-11eb-3ed7-3f8bbb8f5809
# ╟─3e54848a-0954-11eb-3948-f9d7f07f5e23
# ╟─3e623454-0954-11eb-03f9-79c873d069a0
# ╠═0ebd35c8-0972-11eb-2e67-698fd2d311d2
# ╟─027a5f48-0a44-11eb-1fbf-a94d02d0b8e3
# ╟─66663fcc-0a58-11eb-3568-c1f990c75bf2
# ╟─3e858990-0954-11eb-3d10-d10175d8ca1c
# ╠═189bafac-0972-11eb-1893-094691b2073c
# ╟─ad1253f8-0a34-11eb-265e-fffda9b6473f
# ╟─73ed1384-0a29-11eb-06bd-d3c441b8a5fc
# ╠═96707ef0-0a29-11eb-1a3e-6bcdfb7897eb
# ╠═b0337d24-0a29-11eb-1fab-876a87c0973f
# ╟─9c9f53b2-09ea-11eb-0cda-639764250cee
# ╠═e24d5796-0a68-11eb-23bb-d55d206f3c40
# ╟─ec8e4daa-0a2c-11eb-20e1-c5957e1feba3
# ╟─ec576da8-0a2c-11eb-1f7b-43dec5f6e4e7
# ╟─71c358d8-0a2f-11eb-29e1-57ff1915e84a
# ╠═5278e232-0972-11eb-19ff-a1a195127297
# ╟─71c9788c-0aeb-11eb-28d2-8dcc3f6abacd
# ╠═69151ce6-0aeb-11eb-3a53-290ba46add96
# ╟─3eb46664-0954-11eb-31d8-d9c0b74cf62b
# ╠═edf86a0e-0a68-11eb-2ad3-dbf020037019
# ╠═44107808-096c-11eb-013f-7b79a90aaac8
# ╟─87ea0868-0a35-11eb-0ea8-63e27d8eda6e
# ╟─058e3f84-0a34-11eb-3f87-7118f14e107b
# ╟─f83909b6-6638-11eb-0d9b-33285b7557b4
# ╠═478309f4-0a31-11eb-08ea-ade1755f53e0
# ╠═51788e8e-0a31-11eb-027e-fd9b0dc716b5
# ╟─3ebd436c-0954-11eb-170d-1d468e2c7a37
# ╠═dcefc6fe-0a3f-11eb-2a96-ddf9c0891873
# ╟─b4d5da4a-09a0-11eb-1949-a5807c11c76c
# ╠═0237ebac-0a69-11eb-2272-35ea4e845d84
# ╠═ad832360-0a40-11eb-2857-e7f0350f3b12
# ╟─b4ed2362-09a0-11eb-0be9-99c91623b28f
# ╠═0665aa3e-0a69-11eb-2b5d-cd718e3c7432
# ╠═0e5d9cc6-6601-11eb-32c2-7bb422b4ea25
# ╟─77e2f2d8-6636-11eb-14c5-532f59a119d7
# ╠═799e6252-6603-11eb-194a-a7a42ccb9508
# ╠═ecc9448e-6600-11eb-33fe-af85c472b2a8
# ╠═98ccb7fa-6603-11eb-386a-ad7c066df1f3
# ╟─ed2d616c-0a66-11eb-1839-edf8d15cf82a
# ╟─3ed06c80-0954-11eb-3aee-69e4ccdc4f9d
# ╠═35537320-0a47-11eb-12b3-931310f18dec
# ╠═cf2f3b98-09a0-11eb-032a-49cc8c15e89c
# ╟─814e888a-0954-11eb-02e5-0964c7410d30
# ╠═0cfae7ba-0a69-11eb-3690-d973d70e47f4
# ╟─4fac0f36-0a59-11eb-03d0-632dc9db063a
# ╟─7b93c2be-6637-11eb-36f8-13a2fde90a17
# ╠═e0b0880c-0a47-11eb-0db2-f760bbbf9c11
# ╠═b5a88504-0a47-11eb-0eda-f125d419e909
# ╠═87a4cdaa-0a5a-11eb-2a5e-cfaf30e942ca
# ╟─49fa8092-0a43-11eb-0ba9-65785ac6a42f
# ╟─3ffedb0a-663b-11eb-0e76-3366590392a5
# ╠═1ccc961e-0a69-11eb-392b-915be07ef38d
# ╠═634974d8-6621-11eb-0fed-b7190f40946d
# ╠═c2770f7a-6620-11eb-2c62-133d69041f6e
# ╠═1f96c80a-0a46-11eb-0690-f51c60e57c3f
# ╟─f953e06e-099f-11eb-3549-73f59fed8132
# ╠═e6dd8258-0a4b-11eb-24cb-fd5b3554381b
# ╠═de88b530-0a4b-11eb-05f7-85171594a8e8
# ╟─80f39140-0aef-11eb-21f7-b788c5eab5c9
# ╠═3c49b96a-662b-11eb-0486-f34f8fe5119a
# ╠═892abf8c-662a-11eb-33d8-7dda5618e7d2
# ╠═b4e8892e-662f-11eb-3be3-89d65c9bdc69
# ╠═fd78bba8-6631-11eb-1734-5f3d1ffe4a27
# ╠═e6f6669e-662e-11eb-210b-219ea0df4d33
# ╠═3e3811c8-662a-11eb-1863-ff3666ff96ed
# ╟─34778744-0a5f-11eb-22b6-abe8b8fc34fd
# ╠═126359d0-662d-11eb-10f8-5fb1a16914d6
# ╠═bb659f88-662c-11eb-0478-e5ddaa4cbe28
# ╟─1fc3271e-0a45-11eb-0e8d-0fd355f5846b
# ╠═18552c36-0a4d-11eb-19a0-d7d26897af36
# ╠═4e7fd58a-0a62-11eb-1596-c717e0845bd5
# ╠═778c2490-0a62-11eb-2a6c-e7fab01c6822
# ╠═189d24e2-662e-11eb-32bd-3f839039b5f4
# ╟─e964c7f0-0a61-11eb-1782-0b728fab1db0
# ╠═4d83dbd0-0a63-11eb-0bdc-757f0e721221
# ╠═ef27de84-0a63-11eb-177f-2197439374c5
# ╟─8475baf0-0a63-11eb-1207-23f789d00802
# ╟─201a3810-0a45-11eb-0ac9-a90419d0b723
# ╠═e5040c9e-0a65-11eb-0f45-270ab8161871
# ╠═1ca4a5d8-6647-11eb-1ac1-db32e5abb575
# ╟─f9b9e242-0a53-11eb-0c6a-4d9985ef1687
# ╟─e84e0944-0a66-11eb-12d3-e12ae10f39a6
# ╟─0e6b60f6-0970-11eb-0485-636624a0f9d7
# ╟─0a82a274-0970-11eb-20a2-1f590be0e576
# ╟─0aa666dc-0970-11eb-2568-99a6340c5ebd
# ╟─0acaf3b2-0970-11eb-1d98-bf9a718deaee
# ╟─0afab53c-0970-11eb-3e43-834513e4632e
# ╟─0b21c93a-0970-11eb-33b0-550a39ba0843
# ╟─0b470eb6-0970-11eb-182f-7dfb4662f827
# ╟─0b6b27ec-0970-11eb-20c2-89515ee3ab88
# ╟─0b901714-0970-11eb-0b6a-ebe739db8037
# ╟─d5cb6b2c-0a66-11eb-1aff-41d0e502d5e5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
