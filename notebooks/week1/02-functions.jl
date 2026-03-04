### A Pluto.jl notebook ###
# v0.20.23

using Markdown
using InteractiveUtils

# ╔═╡ 79f8d0eb-736f-4526-9fb3-27c8dbc94631
using Dates

# ╔═╡ 88b27144-068b-42ed-b4b0-d12f5ca8c53c
using PlutoUI

# ╔═╡ 91562a82-8741-11ec-1332-7db3016c8b30
md"""
# Julia Bootcamp - Programming Constructs

Florian Oswald, $(Dates.format(Dates.today(), "dd u yyyy"))

> Iteration, Loops, Functions, and Variable Scope
"""

# ╔═╡ d84057df-f233-4630-bd84-8c2d6e91353e
html"<button onclick='present()'>present</button>"

# ╔═╡ 8424693a-4445-4309-ba54-549ba861838b
md"""
#

We have seen how we can assign a variable already:
"""

# ╔═╡ a28fea67-89e7-452d-96b5-ee94efd14217
y = 5

# ╔═╡ 4fd7c57b-b579-49a6-84dc-06869cdf8b64
md"""
We can be more elaborate and assign multiple variables with a `begin...end` block. Notice that in this example, the result is bound to variable `n`, whereas both `b` and `a` *leak* out from the `begin...end` block.
"""

# ╔═╡ a16ca545-83be-4ef3-8946-4e79012042f3
y2 = begin
	b = 3
	a = 2
	a * b - 12
end;

# ╔═╡ 05eda001-588f-49e0-b589-a22a6195994e
(a,b)

# ╔═╡ b780b7ed-7b0c-4464-a8aa-23b3a4180f64
y2

# ╔═╡ bb502134-a506-4c86-898b-f84a74f0c1a5
md"""
## Loops

Like all julia syntax which introduces a local scope (i.e. a region where local variables can be defined, and used), a standard `for` loop ends with the `end` keyword:

```julia
for itervar in iterable
	# the loop body:
    # do stuff with itervar
	g(itervar)  # for example
    # itervar only exists inside this loop!
end
```
"""

# ╔═╡ 312e4383-3c67-4ec0-9f5b-7fbee4c237e5
for i ∈ 1:3
	println(i)
end

# ╔═╡ ac4917fe-446a-40b1-a6ca-ba00e4428e40
i  # does not exist outside of the loop

# ╔═╡ e281b82e-e99e-4f70-a6bd-b675f4944bc0
md"""
#
"""

# ╔═╡ b88de86f-f510-4c5c-a52c-5e66fb27d517
md"""
What's quite cool with julia iteration is that you can iterate over multiple things at once. Suppose we had this `Dict`:
"""

# ╔═╡ cf992726-f7d9-42f8-a0db-108861ebae8f
di = Dict(:a => 1.1, :b => 3.2)

# ╔═╡ a48694a3-7b90-4811-a860-0620b604bf77
for (k,v) in di
	println("the key is $k, the value is $v")
end

# ╔═╡ 8f5f7cc0-6122-45c0-bf3c-59ac878c2567
md"""
similarly, the `enumerate` function is quite handy
"""

# ╔═╡ 1db1fcf2-d8c2-4fd4-a84d-ec4ef48cb95d
for (ix,v) in enumerate(rand(3))
	println("index number $ix has value $v")
end

# ╔═╡ 142d25a9-e122-4253-8736-cdb10b123fc9
md"""
#

similarly, we have a standard *while* loop:

```julia
julia> while n < 4
		   n += 1
		   println("n is currently = $n")
       end
n is currently = 1
n is currently = 2
n is currently = 3
n is currently = 4

julia> n
4
```
"""

# ╔═╡ 6cdd5994-b881-47f4-add7-1b6ac7349c76
m = 4

# ╔═╡ b3b3b926-72ff-482a-900d-20a8a5595e6c
md"""
*if-else* constructs are very standard (never forget the `end` to close the block!)
"""

# ╔═╡ 681733ec-046d-49fe-ae65-ec36e7b62509
if m < 4
	md"m is less than 4"   # i use a Markdown string such that this shows in Pluto
else
	md"m is greater or equal 4"
end

# ╔═╡ b5274ca3-07d5-4340-ae5f-8609d0c190e0
md"""
We can have the terse *ternary* notation `condition ? if true : if false` as well:
"""

# ╔═╡ 4983b419-ca26-486a-a5ce-4af1901c625c
m < 4 ? md"m < 4 is true" :  md"m ≥ 4 is true"

# ╔═╡ 8604c932-8add-4c81-891e-5b24e54acbb0
md"""
## A Running Example: Winsorized Mean

> I have taken this example from [Julia for Data Analysis](https://www.manning.com/books/julia-for-data-analysis), which I **highly** recommend.

The [Winsorized Mean](https://en.wikipedia.org/wiki/Winsorized_mean) is an outlier-robust estimator for the central tendency of a distribution. We use it fairly often in applied work. For example, working with income data, it is quite frequent that we need to deal with unrealistically large (like 1.2 million Euros per month) or small (like -10000 Euros) values. To fix ideas, the $k=1$ winsorized mean for 10 numbers  $x_{(i)} <x_{(i+1)}$ is

$$\frac{x_{(2)} + x_{(2)} + x_{(3)} + \dots + x_{(8)} + x_{(9)} + x_{(9)}}{10}$$

i.e. we *replace* the $k$ smallest and largest numbers by their adjacent (higher or lower) neighbors.
"""

# ╔═╡ 6a945894-780f-482b-9bfa-d6730fb1dcae
md"""
##
"""

# ╔═╡ dd10f06d-c8a5-4e14-ac7d-7d5a4c3ab364
md"""
##
"""

# ╔═╡ df65a4fd-f310-4673-9bde-9ce37e390ec2
let
	x = [10,1,6,4,5]
	y = sort(x)
	k = 1
	for i in 1:k
		y[i] = y[i + 1]  # replace lowest values
		y[end - i + 1] = y[end - k]  # replace highest values
	end
	y
end

# ╔═╡ c9d30e25-29a8-4a9c-9803-150391cfe046
md"""
##
"""

# ╔═╡ 549ff760-d912-4118-80c4-969a8f04e696
let
	x = [10,1,6,4,5]
	y = sort(x)
	k = 1
	for i in 1:k
		y[i] = y[i + 1]
		y[end - i + 1] = y[end - k]
	end
	s = 0
	for v in y
		s += v
	end
	s / length(y)
end

# ╔═╡ 06101a96-097a-4cba-955a-a54ac48b24db
md"""
## Functions

* Very important in julia: put all your work inside functions. 
* The compiler will be able to properly optimize your code only if you give it functions to analyse.
* Always keep in mind the [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/) section!

**Two ways** to define your own functions:
"""

# ╔═╡ 12024ae2-c9cd-45d9-9bda-305e69cd6054
function f(x)   # `function` keyword, function name (f), args (if any) enclosed in ()
	y = x ^ 2  # function body
	# again, a local scope: y only visible in here
	# y  # by default, returns the last value

end

# ╔═╡ 4de3eb6d-c728-4d8d-aa79-38b06a3292c7
f2(x) = x ^ 2  # same function, but shorter to define

# ╔═╡ 83ab78f0-6160-4f4d-aa5c-d1d7322461a9
md"""
#

We *execute* function (we *call* the function) by typing its name and supplying the required arguments (again, if any, otherwise empty `()`):
"""

# ╔═╡ c465539c-e923-480d-abc7-cc9206f8f49a
f(2)

# ╔═╡ fe13c7cd-bb36-450d-8865-08a53a915311
f(2) == f2(2)

# ╔═╡ 95261af6-ad68-4987-bbfc-0d0ed79adfe5
md"""
#

### Keyword and Positional Arguments

1. You can have multiple arguments by position
2. We can set default values for positional arguments 
3. We can give keyword arguments (difference to 2.: you **must** use the keyword in the function call)
"""

# ╔═╡ 7e63209b-1574-4439-b943-f18a5889ceb0
function g(x, y = 2; z = 3)
	x * y * z
end

# ╔═╡ 07e96264-f3d3-44ce-a2a5-1547eb149af5
md"""
#
"""

# ╔═╡ bf892497-3d34-409f-a9ac-c6cba4874863
g(1)

# ╔═╡ 50976b94-ac8d-4c90-8f59-52c210ff96a1
g(1) == 1 * 2 * 3 # default values for y and z

# ╔═╡ 873ea764-5c10-4612-abe5-d5df3d4b9c85
g(1,3) == 1 * 3 * 3  # default z, y = 3

# ╔═╡ 7eda5b77-9cdd-4602-b906-1404b51989b1
g(1,3,z = 0) == 1 * 3 * 0  # y = 3, z = 0

# ╔═╡ 368d83da-92dc-4cf1-852f-8390550b6db0
md"""
notice that treating positional `y` like a keyword doesn't work, nor the other way around:
"""

# ╔═╡ ef29f3b5-0bef-4684-92c4-67e9a8f0f33d
g(1,y = 4)

# ╔═╡ 5a3802ff-85d9-4251-97f4-cca2cd00d332
g(1,3,10)

# ╔═╡ 84aedecf-03bd-4b8a-b01c-57ae5af4faa6
md"""
## Variable Scope

* Which variable is visible to the program where? 
* This is difficult and depends on many things. All languages are slightly different here, so it's important to know some general rules.
* The full set of rules are part of the [manual](https://docs.julialang.org/en/v1/manual/variables-and-scoping/#scope-of-variables), here we show a simple overview.

### Local vs Global Variables

* A variable you define in the REPL is global. That's convenient for exploration. Try this out, for example

```julia
julia> myf() = println(x)  # a function which prints object `x`
julia> x = 1  # an Int in global scope

julia> myf()
1

julia> x = :yea  
julia> myf()
yea
```

##

* it's great that we can switch the type of `x` so easily. That's what we mean with *dynamically typed* language - types of variables can change.
* However, for performance, that's a difficult problem: the compiler can't be sure of the data type of `x`, has to generate code that will work for all possible types for `x`, which means slow code. More on that later.
* 

"""

# ╔═╡ 5a03f9bd-de7d-4ff7-bd50-bc5d3f422f60
md"""
#
"""

# ╔═╡ 41575200-6e77-4541-9aba-37b496175e93
md"""
#
"""

# ╔═╡ ec1d547b-6e89-40fc-a277-7fe2665d0533
# some scoping examples
function sfun1()
	x = 1  # define local variable x
	return x + 1  # can read x here and add 1
end

# ╔═╡ f979bb46-5de5-4a11-a0ca-10698740e4d6
x  # x is not visible outside the function

# ╔═╡ c52f8754-0560-44a3-999a-099d22dd967d
md"""
#
"""

# ╔═╡ 2963d95e-9834-4ed8-9421-d82b3c7e05a5
function sfun2()
	if true
		x = 19
	end
	# if block does *not* add a local scope. `x` leaks and is visible...
	return x + 2 # here...
end

# ╔═╡ c91c31d0-9659-4b17-ae80-a8a214070904
sfun2()

# ╔═╡ 7106827a-62ce-4177-aedc-933ae4b7efa4
md"""
#
"""

# ╔═╡ b3924371-89cb-486e-a90d-311f2957bca1
function sfun3()
	x = 0  # create local var x
	for i in 1:3
		# local scope!
		if i == 3
			x = i   # but knows about x in the enclosing scope and modifies that!
		end
	end
	return x # visible here
end

# ╔═╡ 51748430-ec8c-4daf-abb6-766cd20a362c
sfun3()

# ╔═╡ fc58b09d-c169-41ad-9cae-b317968765ca
md"""
#
"""

# ╔═╡ 5c04114e-4bf0-46a9-80ee-a3b5216db8d6
function sfun4()
	for i in 1:3
		# local scope!
		if i == 3
			x = i   # but knows about x in the enclosing scope and modifies that!
		end
	end
	return x # error here
end

# ╔═╡ b7072f99-fd39-428b-9ec9-5fe52532fb8d
sfun4()

# ╔═╡ 8792f536-6265-4943-b0b1-671ee763f149
md"""
#
"""

# ╔═╡ 0c54578e-2462-4ade-abb5-6f320ba83d5e
function sfun5()
	for i in 1:3
		# local scope!
		x = i
		println("current x is $x")  #x exists here!
	end
	return x # but not  here
end

# ╔═╡ cfe0fac1-20ed-4fde-89c1-1752c30de477
sfun5()

# ╔═╡ 2306607b-0090-4764-9bcd-a65dadc2779a
md"""
#
"""

# ╔═╡ fb61fd7f-aabf-442b-a6c8-3077cb2e8207
md"""


We can return more than one values by returning a tuple (or any other container like a dict or an array):
"""

# ╔═╡ 2962bf2a-dbee-4ca7-b3e6-e9df1a2d0bb4
g₂(x) = (x,x^2,x^3)

# ╔═╡ b1f4f5ef-5f56-4ee8-8def-5c87b71be658
g₂(2)

# ╔═╡ 719682fd-9a6d-43e7-b8b4-ba6a27a6f500
function g3(x)
	Dict(:x => x, :xsquared => x^2, :xcube => x^3)
end

# ╔═╡ 3ab95641-080a-4d5d-84b6-4654e4900019
g3(2)

# ╔═╡ ab45b171-475c-410e-9d81-6e4c29f9e755
md"""
#
"""

# ╔═╡ ea10a64b-ce38-46b3-b66b-0845cfc296ce
md"""
#
"""

# ╔═╡ 34b13c95-a56b-4678-9d7d-9807c974bf30
function winsorized_mean(x,k)
	y = sort(x)
	for i in 1:k
		y[k-i+1] = y[k + 1]
		y[end - i + 1] = y[end - k]
	end
	println(y)
	s = 0
	for v in y
		s += v
	end
	s / length(y)
end

# ╔═╡ b1ffb3ff-6cd0-40f8-b1a4-f44333846492
winsorized_mean([10,1,6,4,5], 2)

# ╔═╡ 871fec18-0ed4-4717-ad85-ac477e918886
md"""
#
"""

# ╔═╡ 6e4d8075-3303-4967-9a81-9d497bfd3068
md"""
## Duck-Typing

Julia will always use the most appropriate version (*method*) of a function. Notice that we didn't specify any particular input type for function `g` above. Let's try to give it a matrix:
"""

# ╔═╡ 9bfe0644-de15-4322-8bb0-31636e26afc1


# ╔═╡ 1b4be433-4e34-4b8c-91cd-7548e7377333
A = rand(2,2)

# ╔═╡ b2faa599-d962-4479-97b9-98aacac6c209
g(A)

# ╔═╡ be3f68c9-72ea-436b-9c28-47f8857d71ea
g(A,A)

# ╔═╡ 99f45b26-1d42-44d4-8107-58454ad80b37
g(A,A, z = A)

# ╔═╡ 276d64cb-e27f-4bdb-a964-bcf36c9a46d9
md"""
Or a string!
"""

# ╔═╡ fe561c2c-fb7f-4e67-9e49-546041112c50
g("oh ","my ", z = "word!")

# ╔═╡ 4524cc39-4d8f-4496-b0d1-8302c5614f47
md"""
All of those worked because the function `*` is defined for Floats (simple multiplication), conformable matrices (matrix multiplication), and strings (concatenate). Look at that:
"""

# ╔═╡ da7c60f7-a95b-44d4-96a6-8d3e22dc538f
md"""
#
"""

# ╔═╡ 679a6875-44a4-4e7d-85cc-f5ea90ead8ff
g(2,"oh")  # oh. that does not work, because see above...

# ╔═╡ 5d85f558-1b4e-4be7-a530-72a6705f58ec
md"""
So that's kind of interesting. There are all of these *methods* of the function `*` around, and depending on what input you give, it will do different things. This is a first preview of a core julia concept called 

> Multiple Dispatch: A function `f` can be *specialized* for certain input types.
"""

# ╔═╡ 1d68be68-1064-425b-baaf-da76ec7af76a
md"""
### Argument Passing Behaviour

* Julia passes arguments to functions *by reference*
* In particular, if what we give is a **mutable** object (like an array, for example), then the function changes the supplied object *in the caller*!
* This is quite cool, because we can modify objects *in-place* : think about a large array. It would be expensive to copy all the data from the caller into the function, do the job, then copy all the data back into the caller. Much better: leave the data where it is (in the caller), *modify it* as required in the function body, and copy nothing back and forth!
"""

# ╔═╡ 2bfaffab-300b-467d-95c9-f0b81d66c231
function addtofirst!(x,y)
	x[1] += y  
	return nothing # not required, but clearer
end

# ╔═╡ ccb84f7e-b76f-4797-978a-ce670b0a13f6
v = ones(4) # a mutable object: an array

# ╔═╡ 09a05e9f-1ee0-4364-b835-ffe8ab510afd
addtofirst!(v,2)

# ╔═╡ 36df9bd8-a924-4107-b9c2-e04d2db4ea28
v

# ╔═╡ 1d3b4411-0eeb-4f6e-bc0e-7f9b493885f5
md"""
By convention, we add a `!` to the end of the function name to signal that our function will *modify* the first given argument (`x` in the definition), usually *not returning anything*. 

There are many built-in functions like that, often with two versions: 
1. one version that *makes a copy and returns a new object*
2. another version that does the same operation *in-place*:
"""

# ╔═╡ 725ba4ba-95ea-4d07-b7da-206784ba6ab6
v2 = sort(v)  # v2 is a new array

# ╔═╡ 17af5ec9-3713-489b-abd7-437cb0fac71c
sort!(v)   # that's the same v

# ╔═╡ c4ab1742-9e0c-41f1-8a3a-762eb3757a93
md"""
in particular, `v` here occupies the same *memory address on your computer* as it did when we created it above! Look at that:
"""

# ╔═╡ 971a0406-d84f-44ee-be02-9675328bd790
v2 == v   # look at the help for == vs === !

# ╔═╡ 2df8f30b-1798-49cd-957b-1aeb6f70fde3
v2 === v # egal 

# ╔═╡ bfa6b7c7-d2f8-44f6-8f51-30cd73a58efc
v3 = copy(v)

# ╔═╡ 7a064adf-e9ba-42ba-b08a-343b7dd5054a
y

# ╔═╡ b7bc5672-bb76-43d3-a8ee-3caa7c0e7f4d
y3 = y

# ╔═╡ 04edb9d7-7ddd-4e04-aa97-7daafc5a01e4
md"""
## Function Library
"""

# ╔═╡ b7960f1b-93ed-4bf5-85d5-3e37aa0297a4
tip(text) = Markdown.MD(Markdown.Admonition("tip", "Question", [text]));

# ╔═╡ 0788133c-1796-4d44-8fb1-3b65f66f934e
tip(md"""
## First Implementation

Let's do the following in the `julia` REPL:

Suppose we have $$x = [10,1,6,4,5]$$, and $k=1$.
1. Create vector `x` by using the `[]` operators
2. Sort the vector from smallest to largest and save as `y`.
3. Use a loop to replace the smallest $k$ values by the $k+1$ smallest value and the largest $k$ values by the $N-k$ largest value, where $N$ is the length of `y`.
3. Inspect `y`.
4. Compute the mean of `y` by first creating variable `s = 0` to which we add all components of `y`, and then and dividing by $N$. This number is the $k$-times winsorized mean of input $x$.

 
""")

# ╔═╡ 5d44a00b-8cb2-432b-a58b-01dd9bf72882
tip(md"Notice that julia says it defined *two* methods here! A *method* is a specific *version of a function*. Can you think of a reason for this here? Try calling `methods(g)` to see what was defined!")

# ╔═╡ 982c1fee-5f3e-45bf-97b5-443d00a25e2b
info(text) = Markdown.MD(Markdown.Admonition("info", "Info", [text]));

# ╔═╡ 5142b680-af06-4100-b355-3c900d0e6dcc
q(text) = Markdown.MD(Markdown.Admonition("tip", "Question", [text]));

# ╔═╡ 95ec149b-9dbe-4b39-af66-0d9cf03c34d4
q(md"""
## Wrapping Winsor in a Function

1. Copy our code from above into a function called `winsorized_mean(x,k)`.
2. Check that your function returns the correct (i.e. same) result as above when called with `winsorized_mean([10,1,6,4,5],1)`.
""")

# ╔═╡ bfdf1dfb-7f42-451c-8de3-36b1625398c6
q(md"""
Newton's square root algorithm says that in order to compute $\sqrt{a} , a> 0$ up to arbitrary precision, you start with *any* given estimate $x >0$ of $\sqrt{a}$, and then you update your guess via

$$x \leftarrow \frac{1}{2}\left(x + \frac{a}{x}\right)$$

you will very quickly find the correct result of $\sqrt{a}$. 

1. in a `.jl` file, define function `mysqrt_step(a,x)`, which returns the next guess for `x` as in the above formula.
2. Try out your function manually in the REPL to compute $\sqrt{4}$, by calling `mysqrt_step(4,6)`, and then repeatedly using the output of the function to replace the second argument (so, instead of the `6` you put what comes out of your function).
3. define a second function, `mysqrt(a,x; tol = 1e-8)`, which *iterates* on `mysqrt_step(a,x)` for *as long as the absolute distance* between two successive guesses for `x` is larger than the value set in keyword argument `tol`. Make the function return a tuple `(x,iters)`, where `iters` is the number of iterations the function needed to converge to the true value.
4. Finally, 😓, write a function `sqrt_table()` which takes values for `a = 2:10`, and uses initial guesses `x = a^2`, and prints the output of `mysqrt(a,x)` to the following table, and onto your terminal. You want to get this output:
```
julia> sqrt_table()
 a     mysqrt       sqrt Iterations 
 2   1.414214   1.414214          6 
 3   1.732051   1.732051          7 
 4   2.000000   2.000000          8 
 5   2.236068   2.236068          8 
 6   2.449490   2.449490          9 
 7   2.645751   2.645751          9 
 8   2.828427   2.828427          9 
 9   3.000000   3.000000         10 
10   3.162278   3.162278         10 
```
Let me help you a bit to get that table output printed nicely. Here is what I did, which uses standard [formatted printing](https://docs.julialang.org/en/v1/stdlib/Printf/): the `%2s` would mean *2 string characters*, the `%10d` means 10 digits, the `\n` means *new line*, etc...

```julia
using Printf  # use the Printf package (built-in)
function sqrt_table()
    @printf("%2s %10s %10s %10s \n", "a", "mysqrt", "sqrt", "Iterations")
    for a in 2:10
        tmp = mysqrt(a,a^2)
        @printf("%2d %10f %10f %10d \n", a, tmp[1], sqrt(a), tmp[2])
    end
end
```
"""
)

# ╔═╡ 58974c53-3a1b-4df0-9465-6d9c1c032ace
info(title,text) = Markdown.MD(Markdown.Admonition("info", title, [text]));

# ╔═╡ 49ad6a05-78a4-44f4-a57d-71a75543d497
info("Summary",md"""

1. Positional arguments can have default values (like `y` here)
2. Keyword arguments **must be given with the keyword** when calling
3. Keyword arguments are given after a semicolon in the definition in a `name = value` fashion.
4. You can have as many (keyword) arguments as you want.
""")

# ╔═╡ c0c37eff-7e3c-40db-ad91-37a296161bd6
info(md"**Local Variables**, are visible only *locally*, i.e. inside a *scope*. As a general rule, all of your code should be inside functions to help the compiler generate fast code.")

# ╔═╡ 72e8e018-dd16-4d4c-a763-54c93509628f
info(md"""
Local scopes are introduced by the following:
1. Functions and anonymous functions and `do...end` blocks
1. `for` and `while` loops
1. `try...catch` blocks
1. Comprehensions

It's important to know that `if...end` blocks as well as `begin...end` blocks do **not** introduce a local scope, hence variables will *leak* outside of that construct. Of course, having an `if...end` block *inside* a function does no harm at all.

""")

# ╔═╡ c48f1189-ee68-42bb-85cb-0c759f8ff098
danger(text) = Markdown.MD(Markdown.Admonition("danger", "Caution", [text]));

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.34"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "0ea47602218944927343a4fa9bc424492dcf3f24"

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
# ╠═79f8d0eb-736f-4526-9fb3-27c8dbc94631
# ╟─91562a82-8741-11ec-1332-7db3016c8b30
# ╟─d84057df-f233-4630-bd84-8c2d6e91353e
# ╟─88b27144-068b-42ed-b4b0-d12f5ca8c53c
# ╟─8424693a-4445-4309-ba54-549ba861838b
# ╠═a28fea67-89e7-452d-96b5-ee94efd14217
# ╟─4fd7c57b-b579-49a6-84dc-06869cdf8b64
# ╠═a16ca545-83be-4ef3-8946-4e79012042f3
# ╠═05eda001-588f-49e0-b589-a22a6195994e
# ╠═b780b7ed-7b0c-4464-a8aa-23b3a4180f64
# ╟─bb502134-a506-4c86-898b-f84a74f0c1a5
# ╠═312e4383-3c67-4ec0-9f5b-7fbee4c237e5
# ╠═ac4917fe-446a-40b1-a6ca-ba00e4428e40
# ╟─e281b82e-e99e-4f70-a6bd-b675f4944bc0
# ╟─b88de86f-f510-4c5c-a52c-5e66fb27d517
# ╠═cf992726-f7d9-42f8-a0db-108861ebae8f
# ╠═a48694a3-7b90-4811-a860-0620b604bf77
# ╟─8f5f7cc0-6122-45c0-bf3c-59ac878c2567
# ╠═1db1fcf2-d8c2-4fd4-a84d-ec4ef48cb95d
# ╟─142d25a9-e122-4253-8736-cdb10b123fc9
# ╠═6cdd5994-b881-47f4-add7-1b6ac7349c76
# ╟─b3b3b926-72ff-482a-900d-20a8a5595e6c
# ╠═681733ec-046d-49fe-ae65-ec36e7b62509
# ╟─b5274ca3-07d5-4340-ae5f-8609d0c190e0
# ╠═4983b419-ca26-486a-a5ce-4af1901c625c
# ╟─8604c932-8add-4c81-891e-5b24e54acbb0
# ╟─6a945894-780f-482b-9bfa-d6730fb1dcae
# ╟─0788133c-1796-4d44-8fb1-3b65f66f934e
# ╟─dd10f06d-c8a5-4e14-ac7d-7d5a4c3ab364
# ╠═df65a4fd-f310-4673-9bde-9ce37e390ec2
# ╟─c9d30e25-29a8-4a9c-9803-150391cfe046
# ╠═549ff760-d912-4118-80c4-969a8f04e696
# ╟─06101a96-097a-4cba-955a-a54ac48b24db
# ╠═12024ae2-c9cd-45d9-9bda-305e69cd6054
# ╠═4de3eb6d-c728-4d8d-aa79-38b06a3292c7
# ╟─83ab78f0-6160-4f4d-aa5c-d1d7322461a9
# ╠═c465539c-e923-480d-abc7-cc9206f8f49a
# ╠═fe13c7cd-bb36-450d-8865-08a53a915311
# ╟─95261af6-ad68-4987-bbfc-0d0ed79adfe5
# ╠═7e63209b-1574-4439-b943-f18a5889ceb0
# ╟─5d44a00b-8cb2-432b-a58b-01dd9bf72882
# ╟─07e96264-f3d3-44ce-a2a5-1547eb149af5
# ╠═bf892497-3d34-409f-a9ac-c6cba4874863
# ╠═50976b94-ac8d-4c90-8f59-52c210ff96a1
# ╠═873ea764-5c10-4612-abe5-d5df3d4b9c85
# ╠═7eda5b77-9cdd-4602-b906-1404b51989b1
# ╟─368d83da-92dc-4cf1-852f-8390550b6db0
# ╠═ef29f3b5-0bef-4684-92c4-67e9a8f0f33d
# ╠═5a3802ff-85d9-4251-97f4-cca2cd00d332
# ╟─49ad6a05-78a4-44f4-a57d-71a75543d497
# ╟─84aedecf-03bd-4b8a-b01c-57ae5af4faa6
# ╟─c0c37eff-7e3c-40db-ad91-37a296161bd6
# ╟─5a03f9bd-de7d-4ff7-bd50-bc5d3f422f60
# ╟─72e8e018-dd16-4d4c-a763-54c93509628f
# ╟─41575200-6e77-4541-9aba-37b496175e93
# ╠═ec1d547b-6e89-40fc-a277-7fe2665d0533
# ╠═f979bb46-5de5-4a11-a0ca-10698740e4d6
# ╟─c52f8754-0560-44a3-999a-099d22dd967d
# ╠═2963d95e-9834-4ed8-9421-d82b3c7e05a5
# ╠═c91c31d0-9659-4b17-ae80-a8a214070904
# ╟─7106827a-62ce-4177-aedc-933ae4b7efa4
# ╠═b3924371-89cb-486e-a90d-311f2957bca1
# ╠═51748430-ec8c-4daf-abb6-766cd20a362c
# ╟─fc58b09d-c169-41ad-9cae-b317968765ca
# ╠═5c04114e-4bf0-46a9-80ee-a3b5216db8d6
# ╠═b7072f99-fd39-428b-9ec9-5fe52532fb8d
# ╟─8792f536-6265-4943-b0b1-671ee763f149
# ╠═0c54578e-2462-4ade-abb5-6f320ba83d5e
# ╠═cfe0fac1-20ed-4fde-89c1-1752c30de477
# ╟─2306607b-0090-4764-9bcd-a65dadc2779a
# ╟─fb61fd7f-aabf-442b-a6c8-3077cb2e8207
# ╠═2962bf2a-dbee-4ca7-b3e6-e9df1a2d0bb4
# ╠═b1f4f5ef-5f56-4ee8-8def-5c87b71be658
# ╠═719682fd-9a6d-43e7-b8b4-ba6a27a6f500
# ╠═3ab95641-080a-4d5d-84b6-4654e4900019
# ╟─ab45b171-475c-410e-9d81-6e4c29f9e755
# ╟─95ec149b-9dbe-4b39-af66-0d9cf03c34d4
# ╟─ea10a64b-ce38-46b3-b66b-0845cfc296ce
# ╠═34b13c95-a56b-4678-9d7d-9807c974bf30
# ╠═b1ffb3ff-6cd0-40f8-b1a4-f44333846492
# ╟─871fec18-0ed4-4717-ad85-ac477e918886
# ╟─bfdf1dfb-7f42-451c-8de3-36b1625398c6
# ╟─6e4d8075-3303-4967-9a81-9d497bfd3068
# ╠═9bfe0644-de15-4322-8bb0-31636e26afc1
# ╠═1b4be433-4e34-4b8c-91cd-7548e7377333
# ╠═b2faa599-d962-4479-97b9-98aacac6c209
# ╠═be3f68c9-72ea-436b-9c28-47f8857d71ea
# ╠═99f45b26-1d42-44d4-8107-58454ad80b37
# ╟─276d64cb-e27f-4bdb-a964-bcf36c9a46d9
# ╠═fe561c2c-fb7f-4e67-9e49-546041112c50
# ╟─4524cc39-4d8f-4496-b0d1-8302c5614f47
# ╟─da7c60f7-a95b-44d4-96a6-8d3e22dc538f
# ╠═679a6875-44a4-4e7d-85cc-f5ea90ead8ff
# ╟─5d85f558-1b4e-4be7-a530-72a6705f58ec
# ╟─1d68be68-1064-425b-baaf-da76ec7af76a
# ╠═2bfaffab-300b-467d-95c9-f0b81d66c231
# ╠═ccb84f7e-b76f-4797-978a-ce670b0a13f6
# ╠═09a05e9f-1ee0-4364-b835-ffe8ab510afd
# ╠═36df9bd8-a924-4107-b9c2-e04d2db4ea28
# ╟─1d3b4411-0eeb-4f6e-bc0e-7f9b493885f5
# ╠═725ba4ba-95ea-4d07-b7da-206784ba6ab6
# ╠═17af5ec9-3713-489b-abd7-437cb0fac71c
# ╟─c4ab1742-9e0c-41f1-8a3a-762eb3757a93
# ╠═971a0406-d84f-44ee-be02-9675328bd790
# ╠═2df8f30b-1798-49cd-957b-1aeb6f70fde3
# ╠═bfa6b7c7-d2f8-44f6-8f51-30cd73a58efc
# ╠═7a064adf-e9ba-42ba-b08a-343b7dd5054a
# ╠═b7bc5672-bb76-43d3-a8ee-3caa7c0e7f4d
# ╟─04edb9d7-7ddd-4e04-aa97-7daafc5a01e4
# ╟─b7960f1b-93ed-4bf5-85d5-3e37aa0297a4
# ╠═982c1fee-5f3e-45bf-97b5-443d00a25e2b
# ╠═5142b680-af06-4100-b355-3c900d0e6dcc
# ╠═58974c53-3a1b-4df0-9465-6d9c1c032ace
# ╠═c48f1189-ee68-42bb-85cb-0c759f8ff098
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
