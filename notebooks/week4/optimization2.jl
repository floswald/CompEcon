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

# ╔═╡ cdfd0cac-4c43-441d-bfb4-21ea5653a3a1
begin
	using Plots
	using Optim
	using OptimTestProblems
	using Roots
	using LineSearches
	using BenchmarkTools
	using PlutoUI
end

# ╔═╡ e6358a3b-f1d0-463c-a362-0451f0a20a8f
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

# ╔═╡ 110bde78-7381-4e0d-8ac8-4b878bd4de9b
md"""
# Optimization 2: Algorithms and some `Optim.jl` Applications

Florian Oswald, 2025
"""

# ╔═╡ 200201fd-1c4e-4242-9863-4970137d472a
html"<button onclick='present()'>present</button>"

# ╔═╡ e40bdc58-43a9-11ec-2c84-492ead8ce7c5
md"""


## Bracketing

* A derivative-free method for *univariate* $f$
* works only on **unimodal** function $f$
* We can find a *bracket* in which the global minimum exists if we can find points $a < b < c$ such that

$$f(a) \geq f(b) < f(c) \text{ or } f(a) > f(b) \leq f(c)$$
"""

# ╔═╡ a691d7e0-84d4-4a69-ba41-68147254ff16
PlutoUI.LocalResource("./optimization2/unimodal.png")

# ╔═╡ b7f8381c-3a9b-452e-9fc5-b7c9d4d69323
md"""
## Initial bracket

* To start with, we need to identify first a region where bracketing will work.
* Once we found a valid interval, we shrink it until we find the optimimum.
* Here is an algorithm which will find a valid bracket, taking successive steps into a direction.
* The function `bracket_minimum` (next slide) in action:
"""

# ╔═╡ d2a1181a-1146-478b-bcb2-cc763d6f211f
PlutoUI.LocalResource("./optimization2/bracketing.png")

# ╔═╡ 8db8d806-a6d1-4b98-9153-a92280de174a
# algo 3.1 from Kochenderfer and Wheeler
function bracket_minimum(f, x=0; s=1e-2, k=2.0) 
    a, ya = x, f(x)
    b, yb = a + s, f(a + s) 
    if yb > ya
        a, b = b, a
        ya, yb = yb, ya 
        s = -s
    end
    while true
    c, yc = b + s, f(b + s) 
        if yc > yb
            return a < c ? (a, c) : (c, a) 
        end
        a, ya, b, yb = b, yb, c, yc
        s *= k 
    end
end

# ╔═╡ 46533fde-5d5c-4a1a-a535-923672956f46
plot(sin,-5,10)

# ╔═╡ 25c0a22e-af50-4455-93fd-d23f26b23d52
bracket_minimum(sin, -3)

# ╔═╡ 08d053d9-c865-4ff3-a551-823b5fb41524
md"""
## Fibonacci Search

* Suppose we have a bracket $[a,b]$ on $f$ and that we can only evaluate $f$ twice.
* Where to evaluate it?
* Let's split the interval into 3 equal pieces:
(The next few pictures are ©️ Kochenderfer and Wheeler)



"""

# ╔═╡ df826745-a4c4-4301-af27-066fe8e634f5
PlutoUI.LocalResource("./optimization2/fibo1.png")

# ╔═╡ 4cf52278-d871-4eb2-967d-d6368d01b0c8
md"""

If we move the points to the center, we can do better:

"""

# ╔═╡ 62ed62ba-ce10-4d6d-b65f-0eb349465970
PlutoUI.LocalResource("./optimization2/fibo2.png")

# ╔═╡ d2ce25bc-0aa8-419d-832e-4582ac83ba86
md"""
* for $n$ queries of $f$, we get the following sequence
* This can be determined analytically as $F_n = \frac{\psi^n - (1-\psi)^n}{\sqrt{5}}$
* and $\psi = (1+\sqrt{5})/2$ is called the *golden ratio*, which determines successive steps in the *Fibonacci Sequence*:

$$\frac{F_n}{F_{n-1}} = \psi \frac{1-s^{n+1}}{1-s^n}, \quad s=\frac{1-\sqrt{5}}{1+\sqrt{5}}\approx-0.382$$
"""

# ╔═╡ 39170a86-c216-447a-b6fc-367f0c1c82a8
PlutoUI.LocalResource("./optimization2/fibo3.png")

# ╔═╡ 8e7d4e57-578a-4c25-8c37-65a3fcda7b40
md"""
* *Golden Section Search* uses the *golden ratio* to approximate the Fibonacci sequence.
* This trades off a minimal number of function evaluations with the best placement of evaluation points.
"""

# ╔═╡ dbac8440-659e-4a8d-a4b7-16bfd6d22c15
PlutoUI.LocalResource("./optimization2/golden1.png")

# ╔═╡ d0b6dacf-8c13-4e31-a4a6-d4b5ee6a2f69
PlutoUI.LocalResource("./optimization2/golden2.png")

# ╔═╡ adcd9256-650f-4d0e-8fe8-9b842b6b4c34
md"""
## `Optim.jl`

Let's optimize a simple function with optim. 
"""

# ╔═╡ a32820d0-5d91-4808-b942-202b760aec18
begin
	f(x) = exp(x) - x^4
	plot(f,0,2, leg = :bottomleft, xlab = "x", ylab = "f(x)")
end

# ╔═╡ fd1fba34-1c4f-48f7-83b4-fd60c796ac17
md"""
typically, we have a setup like 

```julia
function your_function(x) ... end
using Optim
optimize(your_function,from,to,which_method_to_use)
```
"""

# ╔═╡ 1a3b8f05-aae9-4975-b8b5-9268145c1e82
begin
	minf(x) = -f(x)
	brent = optimize(minf,0,2,Brent())
	golden = optimize(minf,0,2,GoldenSection())
	vline!([Optim.minimizer(brent)],label = "brent")
	vline!([Optim.minimizer(golden)], label = "golden")
end

# ╔═╡ f127562c-d6c9-42c6-8cca-b1fd33ad4fbe
md"""
* Using Bracketing methods on non-unimodal functions is a *bad idea*
* We identify a different optimum depending on where we start to search.
"""

# ╔═╡ dc4c2888-8ff1-417d-a3bd-c133fb3bbbff
begin
	f2 = x->sin(x) + 0.1*abs(x)
	x_arr = collect(range(3π/2-8.5, stop=3π/2+5.5, length=151))
	y_arr = f2.(x_arr) 
	plot(x_arr,y_arr,legend = false)
end

# ╔═╡ 59b26c7c-f6c5-4ba6-a067-9d07f179fc12
md"""
ub = $(@bind ub Slider(0:0.05:10, show_value = true, default = 3))
"""

# ╔═╡ f615768b-f212-4f40-ac9c-9eb96c0d6ea1
function pbrent(ub)
	plot(x_arr,y_arr,legend = false)
	ob = optimize(f2, -2.5,ub,Brent())
	scatter!([Optim.minimizer(ob)], [Optim.minimum(ob)], ms = 5, color = :red)
end

# ╔═╡ 1df4c4f2-6856-4431-afbb-df16541d22f7
pbrent(ub)

# ╔═╡ fc015791-cd9e-4a1c-b6ea-4c70284bef64
md"""
## Bisection Methods

* Root finding: `Roots.jl` finds points where a function equals 0.
* Root finding in multivariate functions: [`IntervalRootFinding.jl`](https://github.com/JuliaIntervals/IntervalRootFinding.jl/)
"""

# ╔═╡ 32898baf-25d3-44cf-b92a-92e8ee320935
md"""
up = $(@bind ubr Slider([3,4,5], show_value = true, default = 3))
"""

# ╔═╡ 20664b8a-59d7-4d80-9926-7a982f72b276
let  # if I write `let` it creates a "local scope", i.e. upon exiting at `end`, all objects are deleted
	f(x) = exp(x) - x^3
	plot(f, -2,5,leg = false)
	hline!([0.0], ls = :dash, color=:black)
	xx = fzero(f,ubr-3,ubr)  # from Roots.jl
	scatter!([xx],[f(xx)], color = :red, ms = 5)
end

# ╔═╡ 625e38ee-04c1-4792-bf3e-8689bdb4df3b
md"""
## Running a Rosenbrock Banana through Optim

* Let's get the rosenbrock banana and test it on several different algorithms!

### Comparison Methods

* We will now look at a first class of algorithms, which are very simple, but sometimes a good starting point.
* They just *compare* function values.
* *Grid Search* : Compute the objective function at $G=\{x_1,\dots,x_N\}$ and pick the highest value of $f$. 
  * This is very slow.
  * It requires large $N$.
  * But it's robust (will find global optimizer for large enough $N$)
"""

# ╔═╡ adb4ee25-44cb-4294-b410-f357e26336e1
collect(range(0, 3, length= 100))

# ╔═╡ 4a0dc0c1-ce50-425b-84ca-657c93b10966
begin
	prob = UnconstrainedProblems.examples["Rosenbrock"]
	ro = prob.f
	g! = prob.g!
	h! = prob.h!
	grid = collect(-1.0:0.03:3);  # grid spacing is important!
	grid2D = [[i;j] for i in grid,j in grid];
	val2D = map(ro,grid2D);
	r = findmin(val2D);
	md"""
	optimizer is at ($(grid2D[r[2]][1]), $(grid2D[r[2]][2])).
	"""
end

# ╔═╡ 7a8a9f51-49bc-4b6d-b68d-20f06dd7e350
md"""
## Local Descent Methods

* Applicable to multivariate problems
* We are searching for a *local model* that provides some guidance in a certain region of $f$ over **where to go to next**.
* Gradient and Hessian are informative about this.

### Local Descent Outline

All descent methods follow more or less this structure. At iteration $k$,

1. Check if candidate $\mathbf{x}^{(k)}$ satisfies stopping criterion:
    * if yes: stop
    * if no: continue
2. Get the local *descent direction*  $\mathbf{d}^{(k)}$, using gradient, hessian, or both.
3. Set the *step size*, i.e. the length of the next step, $\alpha^k$
4. Get the next candidate via

$$\mathbf{x}^{(k+1)} \longleftarrow \alpha^k\mathbf{d}^{(k)}$$

### The Line Search Strategy

* An algorithm from the line search class  chooses a direction $\mathbf{d}^{(k)} \in \mathbb{R}^n$ and searches along that direction starting from the current iterate $x_k \in \mathbb{R}^n$ for a new iterate $x_{k+1} \in \mathbb{R}^n$ with a lower function value.
* After deciding on a direction $\mathbf{d}^{(k)}$, one needs to decide the *step length* $\alpha$ to travel by solving
$$\min_{\alpha>0} f(x_k + \alpha \mathbf{d}^{(k)})$$
* In practice, solving this exactly is too costly, so algos usually generate a sequence of trial values $\alpha$ and pick the one with the lowest $f$.
"""

# ╔═╡ a6f1e909-9b87-42c7-b47a-d7190ba245bf
PlutoUI.LocalResource("./optimization2/line-search.png")

# ╔═╡ 2f970459-c1b1-418a-bab2-615aeba2e6c4
begin
	algo_hz = Newton(linesearch = HagerZhang())   # one particular linesearch
	optimize(ro, g!, h!, prob.initial_x, method=algo_hz)
end

# ╔═╡ 962e1fef-5ea1-4037-9e59-6b56c3f60909
md"""
### The Trust Region Strategy

* First choose max step size, then the direction
* Finds the next step $\mathbf{x}^{(k+1)}$ by minimizing a model of $\hat{f}$ over a *trust region*, centered on $\mathbf{x}^{(k)}$
    * 2nd order Tayloer approx of $f$ is common.
* Radius $\delta$ of trust region is changed based on how well $\hat{f}$ fits $f$ in trust region.
* Get $\mathbf{x'}$ via

$$\begin{align}
    \min_{\mathbf{x'}} &\quad \hat{f}(\mathbf{x'}) \\
    \text{subject to } &\quad \Vert \mathbf{x}-\mathbf{x'} \leq \delta \Vert
\end{align}$$
"""

# ╔═╡ c031fe39-0f8c-4f6a-b851-266deb8f5b55
PlutoUI.LocalResource("./optimization2/trust-region.png")

# ╔═╡ 3dab6ba2-7dd7-4f41-b1f3-e34d52211afb
begin
	# Optim.jl has a TrustRegion for Newton (see below for Newton's Method)
NewtonTrustRegion(; initial_delta = 1.0, # The starting trust region radius
                    delta_hat = 100.0, # The largest allowable trust region radius
                    eta = 0.1, #When rho is at least eta, accept the step.
                    rho_lower = 0.25, # When rho is less than rho_lower, shrink the trust region.
                    rho_upper = 0.75) # When rho is greater than rho_upper, grow the trust region (though no greater than delta_hat).
res0 = Optim.optimize(ro, g!, h!, prob.initial_x, method=NewtonTrustRegion())
end

# ╔═╡ 794092bf-cd6b-4cb8-aa11-c647157a0037
PlutoUI.LocalResource("./optimization2/trust-region2.png")

# ╔═╡ 712a650d-4ada-4548-81ad-6c10b14d1a89
md"""
### Stopping criteria

1. maximum number of iterations reached
2. absolute improvement $|f(x) - f(x')| \leq \epsilon$
3. relative improvement $|f(x) - f(x')| / |f(x)| \leq \epsilon$
4. Gradient close to zero $|g(x)| \approx 0$

## Gradient Descent

The steepest descent is *opposite the gradient*.
* Here we define
    $$\mathbf{g}^{(k)} = \nabla f(\mathbf{x}^{(k)})$$
* And our descent becomes
    $$\mathbf{d}^{(k)} = -\frac{\mathbf{g}^{(k)} }{\Vert\mathbf{g}^{(k)}\Vert }$$
* Minimizing wrt step size results in a jagged path (each direction is orthogonal to previous direction!) See Kochenderfer and Wheeler chapter 5, equation (5.6)
    $$\alpha^{(k)} = \arg \min{\alpha} f(\mathbf{x}^{(k)} + \alpha \mathbf{d}^{(k)})$$
"""

# ╔═╡ 4918190d-446a-46dd-9400-03a05c85541e
md"""
## Our Implementation

Let's first build a gradient descent ourselves, and then use the one provided in the Optim.jl package. Let's call the function `our_gd` (GD: gradient descent). We will use the function from yesterday:

$$f₂(x) = \sin(x_1 + x_2) + \cos(x_1)^2$$

for which we figured out the following gradient function:

"""

# ╔═╡ caddc47a-7a4a-4f21-a524-3111f2ce2911
begin
	fgd(x) = sin(x[1] + x[2]) + cos(x[1])^2
	ggd(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]
	fgd(x1,x2) = fgd([x1;x2])  # overloading `fgd` with 2nd call
end

# ╔═╡ e4a4f604-9831-4d91-944f-6d9c0f94be8f
md"""
here is our gradient descent algorithm:
"""

# ╔═╡ 8428c078-ba7c-4322-8092-4076abad727d
function our_gd(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)  # a matrix of x values. each column is one iteration k.
    xs[:,1] = x
    for k in 1:max_iter
        x -= α*g(x)   # take step of length α opposite (the minus!) of gradient 
        xs[:,k+1] = x # save current x as iterate k
    end
    return xs
end


# ╔═╡ 3648b8ca-b9ae-48c4-8648-1fa139637805
md"""
Now, let's build an animation that shows how the optimizer will travel along the gradient towards a point where $g(x) = 0$. *This algorithm looks for stationary points*.
"""

# ╔═╡ 958e0db6-9fda-4d9b-9369-f295887d2fab
function create_anim(
    f,
    solver_trace,
    xlims,
    ylims;
    fps = 15)
	
    xs = range(xlims...; length = 100)
    ys = range(ylims...; length = 100)
    plt = contourf(xs, ys, f; color = :jet)

    # add an empty plot
    plot!(Float64[], Float64[]; line = (4, :arrow, :black), label = "")

    # extract the last plot series
    plt_path = plt.series_list[end]

    # # create the animation and save it
    anim = Animation()
    for x in eachcol(solver_trace)
        push!(plt_path, x[1], x[2]) # add a new point
        frame(anim)
    end
    gif(anim; fps = fps, show_msg = false)
end


# ╔═╡ 68a7fdd2-2810-42e0-95d1-9163bbea7455
# call gd
gd = our_gd([], ggd, [0; 0], 0.1)

# ╔═╡ f7347298-7f8b-4081-b7cd-d29601a8e389
begin
	xlims = (-3, 1)
	ylims = (-2, 1)
	z = create_anim(fgd, gd, xlims, ylims)
end

# ╔═╡ 5222b1f9-73ef-4f85-b346-e6499f068a15
md"""
### smaller steps
"""

# ╔═╡ e66e1b22-afba-44ad-994e-c256b23e7efe
gdsmall = our_gd([], ggd, [0; -1], 0.01)

# ╔═╡ a8b9e0c7-d6bf-46c5-937e-a2970286496d
let
	xlims = (-3, 1)
	ylims = (-2, 1)
	create_anim(fgd, gdsmall, xlims, ylims)
end

# ╔═╡ 8f72d4b0-147f-4a44-924f-2cfb51fe813e
md"""
## large stepsize
"""

# ╔═╡ 618c930b-cf4e-4755-abfb-4e51a5e1ceec
gdlarge = our_gd([], ggd, [0; -1], 0.8)

# ╔═╡ 636f368f-987f-404c-b39b-78b083766296
let
	xlims = (-3, 1)
	ylims = (-2, 1)
	create_anim(fgd, gdlarge, xlims, ylims)
end

# ╔═╡ 455f7670-6be7-47ba-9c31-7c3824e1bb68
md"""
## Back To Banana! 🍌
"""

# ╔═╡ 1117da28-0103-4264-95b2-07562c98103b
res_gd = optimize(ro, g!,[-4,3.], GradientDescent(), Optim.Options(store_trace=true, extended_trace=true, iterations = 5000))

# ╔═╡ 45468faf-d2c1-4a68-997f-41f9879ede0f
llevels() = exp.(range(log(0.5), stop = log(175.0), length = 20))

# ╔═╡ 11956a74-3ea2-491c-8eb1-d60db132c5c7
function plot_optim(res, start, x,y,ix; offset = 0)
	contour(x, y, (x,y)->sqrt(ro([x, y])), fill=false, 	color=:viridis, legend=false, levels = llevels())
    xtracemat = hcat(Optim.x_trace(res)...)
    plot!(xtracemat[1, (offset+1):ix], xtracemat[2, (offset+1):ix], mc = :white, lab="")
    scatter!(xtracemat[1:1,ix], xtracemat[2:2,ix], mc=:black, msc=:red, lab="")
    scatter!([1.], [1.], mc=:red, msc=:red, lab="")
    scatter!([start[1]], [start[2]], mc=:yellow, msc=:black, label="start", legend=true)

end

# ╔═╡ cef266b6-7913-4abd-a665-03bd491049b0
md"5000 iteration = $(@bind i5k Slider(1:5000, show_value = true, default = 1))"

# ╔═╡ 1a84b8d7-cfdc-420c-b4ff-d6cf32b82622
res_gd_zoom = optimize(ro, [-1,1.], GradientDescent(), Optim.Options(store_trace=true, extended_trace=true, iterations = 5000));

# ╔═╡ d0d68f47-95dd-4aba-8817-d015090f8c4c
md"1000 iteration = $(@bind ik Slider(1:1000, show_value = true, default = 1))"

# ╔═╡ 2cd50a99-f3d5-442d-9beb-cad56362ae1e
md"""
* pretty zig-zaggy
* it may not be a huge issue for final convergence, but we take a lot of *unncessary* steps back and forth.
* so in terms of computational cost, we incur quite a lot here.
* zoom in even more:
"""

# ╔═╡ 28726ab6-747c-4537-94fd-df4f69ff0df5
md"zoom slider = $(@bind ikzoom Slider(120:160, show_value = true))"

# ╔═╡ ca9fd4bb-f934-48df-8daf-f786013b6d69
let
	c = contour(-.85:0.01:-0.60, 0:0.01:1.2, (x,y)->sqrt(ro([x, y])), color=:viridis, legend=false, levels = exp.(range(log(1), stop = log(10.0), length = 70)))
    res = optimize(ro, [-4,-3.0], GradientDescent(), Optim.Options(store_trace=true, extended_trace=true))
    xtracemat = hcat(Optim.x_trace(res)...)
    
    plot!(xtracemat[1, 120:ikzoom], xtracemat[2, 120:ikzoom], mc = :white, legend=true, label="Gradient Descent")
    scatter!(xtracemat[1:1,ikzoom], xtracemat[2:2,ikzoom], mc=:black, msc=:red, label = "")
    scatter!(xtracemat[1:1,120], xtracemat[2:2,120], mc=:blue, msc=:blue, label="start")
end

# ╔═╡ 7728ef9f-c84d-48b0-a25d-eb534f126d65
md"""
## Conjugate Gradient Descent

* Tries to avoid the jagged path problem
* It combines several methods: it minimizes a quadratic form of $f$
* The next descent direction uses the gradient *plus* some additional info from the previous step.
"""

# ╔═╡ 08339a83-73b6-4cb4-8b59-e30324fdfc8f
md"""
## Second Order Methods

### Newton's Method

* We start with a 2nd order Taylor approx over x at step $k$:
    $$q(x) = f(x^{(k)}) + (x - x^{(k)}) f'(x^{(k)}) + \frac{(x - x^{(k)})^2}{2}f''(x^{(k)})$$
* We form first order conditions (set it's root equal to zero) and rearrange to find the next step $k+1$:

$$\begin{aligned}
    \frac{\partial q(x)}{\partial x} &= f'(x^{(k)}) + (x - x^{(k)}) f''(x^{(k)}) = 0\\
    x^{(k+1)} &= x^{(k)} - \frac{f'(x^{(k)})}{f''(x^{(k)})}
\end{aligned}$$

* The same argument works for multidimensional functions by using Hessian and Gradient
* We would get a descent $\mathbf{d}^k$ by setting:
    $$\mathbf{d}^k = -\frac{\mathbf{g}^{k}}{\mathbf{H}^{k}}$$
* There are several options to avoid (often costly) computation of the Hessian $\mathbf{H}$:
1. Quasi-Newton updates $\mathbf{H}$ starting from identity matrix
2. Broyden-Fletcher-Goldfarb-Shanno (BFGS) does better with approx linesearch
3. L-BFGS is the limited memory version for large problems
"""

# ╔═╡ 5e8a328f-3624-4401-ad7a-f19bc94dd6cd
function plot_optim(res1, res2, start, x,y,ix,lab1, lab2)
	contour(x, y, (x,y)->sqrt(ro([x, y])), fill=false, 	color=:viridis, legend=false, levels = llevels())
	xtracemat = hcat(Optim.x_trace(res1)...)
    plot!(xtracemat[1, 1:ix], xtracemat[2, 1:ix], mc = :white,  label=lab1, legend=true,lw=2)
    scatter!(xtracemat[1:1,ix], xtracemat[2:2,ix], mc=:black, msc=:red, label="")
    
    xtracemat2 = hcat(Optim.x_trace(res2)...)
    plot!(xtracemat2[1, 1:ix], xtracemat2[2, 1:ix], c=:blue, label=lab2,lw=2)
    scatter!(xtracemat2[1:1,ix], xtracemat2[2:2,ix], mc=:black, msc=:blue, label="")
    scatter!([1.], [1.], mc=:red, msc=:red, label="")
    scatter!([start[1]], [start[2]], mc=:yellow, msc=:black, label="start", legend=true)

end

# ╔═╡ 5a508717-8a42-466e-9415-ea6447290d19
plot_optim(res_gd, [-4,3.], -4.1:0.01:2, -4.5:0.01:4.1,i5k)

# ╔═╡ e992331a-a739-45f7-9820-7ba6a6603cf9
plot_optim(res_gd_zoom, [-1,1], -2.5:0.01:2, -1.5:0.01:2,ik)

# ╔═╡ 86c1c1df-9ee4-47a0-a40a-69fa3c245a94
begin
	res_newton = optimize(ro, g!, h!, [-1.,-1], Optim.Newton(), Optim.Options(store_trace=true, extended_trace=true))
	res_gd_2 = optimize(ro, [-1.,-1], GradientDescent(), Optim.Options(store_trace=true, extended_trace=true, iterations = 10000));
end

# ╔═╡ 37e8339e-cedc-46e4-8bcc-cae6bf2384a8
md"newton slider = $(@bind ikn Slider(1:20, show_value = true))"

# ╔═╡ 6e297fb4-cf31-4928-9ec3-38b389fa6b58
plot_optim(res_gd_2, res_newton,[-1.,-1],-2.5:0.01:2, -1.5:0.01:2,ikn,"Gradient Descent", "Newton")

# ╔═╡ 9ac7bf69-d1e2-46a4-96e8-4a8cb0ed3781
md"""
## Performance

Let's look at some timings.
"""

# ╔═╡ c798c1a9-0f64-46fa-8844-3678c63708ef
@benchmark optimize(ro, [0.0, 0.0], Optim.Newton(),Optim.Options(show_trace=false))

# ╔═╡ b62d94d4-4f64-4d3f-ae30-06e84013d3c7
@benchmark optimize(ro, g!, h!, [0.0, 0.0], Optim.Newton(),
	Optim.Options(show_trace=false))

# ╔═╡ 691f4695-c307-408f-892d-587b0b29a832
@benchmark optimize(ro, g!, h!,  [-1.0, 3.0], BFGS())

# ╔═╡ e09184ba-da9d-43a2-bd6e-1a739e0722f5
@benchmark optimize(ro, g!, h!,  [-1.0, 3.0], LBFGS())  # low memory

# ╔═╡ 6d9670cf-5257-48af-8f62-3de6a88cbc51
md"""
## Direct Methods

* No derivative information is used - *derivative free*
* If it's very hard / impossible to provide gradient information, this is our only chance.
* Direct methods use other criteria than the gradient to inform the next step (and ulimtately convergence).

### Cyclic Coordinate Descent -- Taxicab search

* We do a line search over each dimension, one after the other
* *taxicab* because the path looks like a NYC taxi changing direction at each block.
* given $\mathbf{x}^{(1)}$, we proceed
    
$$\begin{aligned}
    \mathbf{x}^{(2)} &= \arg \min_{x_1} f(x_1,x_2^{(1)},\dots,x_n^{(1)}) \\
    \mathbf{x}^{(3)} &= \arg \min_{x_2} f(x_1^{(2)},x_2,x_3^{(2)}\dots,x_n^{(2)}) \\    
    \end{aligned}$$

* unfortunately this can easily get stuck because it can only move in 2 directions.

```julia
©️ Kochenderfer and Wheeler
# start to setup a basis function, i.e. unit vectors to index each direction:
basis(i, n) = [k == i ? 1.0 : 0.0 for k in 1 : n]

function cyclic_coordinate_descent(f, x, ε) 
	Δ, n = Inf, length(x)
	while abs(Δ) > ε
		x′ = copy(x) 
			for i in 1 : n
				d = basis(i, n)
				x = line_search(f, x, d) 
			end
		Δ = norm(x - x′) 
	end
	return x 
end  
```
"""

# ╔═╡ 92212ec0-b822-4464-b346-dd221ad6f669
md"""
### General Pattern Search

* We search according to an arbitrary *pattern* $\mathcal{P}$ of candidate points, anchored at current guess $\mathbf{x}$.
* With step size $\alpha$ and set $\mathcal{D}$ of directions

$$\mathcal{P} = {\mathbf{x} + \alpha \mathbf{d} \text{ for } \mathbf{d}\in\mathcal{D} }$$
* Convergence is guaranteed under the condition: $\mathcal{D}$ must be a positive spanning set: at least one $\mathbf{d}\in\mathcal{D}$ has a non-zero gradient.
* We check for a distance $\alpha$ into the $\mathbf{d}$ direction for whether we can improve the objective.
"""

# ╔═╡ 4738c3b3-5c67-4ec6-8291-6426485a7832
PlutoUI.LocalResource("./optimization2/spanning-set.png")

# ╔═╡ 27e77174-2232-4d67-ba8f-d9d944cce543
# ©️ Kochenderfer and Wheeler
function generalized_pattern_search(f, x, α, D, ε, γ=0.5) 
    y, n = f(x), length(x)
    evals = 0
    while α > ε
        improved = false
        for (i,d) in enumerate(D)
            x′ = x + α*d 
            y′ = f(x′) 
            evals += 1
            if y′ < y
                x, y, improved = x′, y′, true
                D = pushfirst!(deleteat!(D, i), d) 
                break
            end 
        end
        if !improved 
            α *= γ
        end 
    end
    # println("$evals evaluations")
    return (x,evals) 
end

# ╔═╡ 496a4d17-0a31-4b6c-bae0-1461603b92e9
let
	D = [[1,0],[0,1],[-1,-0.5]] # 3 different directions
	generalized_pattern_search(ro,zeros(2),0.8,D,1e-6 )
end

# ╔═╡ 5e289cc6-5528-42d9-a3cb-a0d9dac6a849
md"""
## Bracketing for Multidimensional Problems: Nelder-Mead

* The Goal here is to find the simplex containing the local minimizer $x^*$
* In the case where $f$ is n-D, this simplex has $n+1$ vertices
* In the case where $f$ is 2-D, this simplex has $2+1$ vertices, i.e. it's a triangle.
* The method proceeds by evaluating the function at all $n+1$ vertices, and by replacing the worst function value with a new guess.
* this can be achieved by a sequence of moves:
  * reflect
  * expand
  * contract
  * shrink
  movements.


"""

# ╔═╡ 4921b275-6773-4efa-91ce-02869c527dba
PlutoUI.LocalResource("./optimization2/nelder-mead.png")

# ╔═╡ b9d44daa-8781-4c55-b8ef-f0a8b1c92406
md"""
* this is a very popular method. The matlab functions `fmincon` and `fminsearch` implements it.
* When it works, it works quite fast.
* No derivatives required.
"""

# ╔═╡ 9e0b8149-482d-4323-9670-a9756236fbeb
@benchmark optimize(ro, [0.0, 0.0], NelderMead())

# ╔═╡ 51fa22fd-9d3b-40f1-a428-f0cdd8bb2374
md"""
## Stochastic Optimization Methods

* Gradient based methods like steepest descent may be susceptible to getting stuck at local minima.
* Randomly shocking the value of the descent direction may be a solution to this.
* For example, one could modify our gradient descent from before to become

$$\mathbf{x}^{(k+1)} \longleftarrow \mathbf{x}^{(k)} +\alpha^k\mathbf{g}^{(k)} + \mathbf{\varepsilon}^{(k)}$$

* where $\mathbf{\varepsilon}^{(k)} \sim N(0,\sigma_k^2)$, decreasing with $k$.
* This *stochastic gradient descent* is often used when training neural networks.

"""

# ╔═╡ 2f6abe0f-43f5-40af-af51-561b76fcb29c
md"""
### Simulated Annealing

* We specify a *temperature* that controls the degree of randomness.
* At first the temperature is high, letting the search jump around widely. This is to escape local minima.
* The temperature is gradually decreased, reducing the step sizes. This is to find the local optimimum in the *best* region.
* At every iteration $k$, we accept new point $\mathbf{x'}$ with

$$\Pr(\text{accept }\mathbf{x'}) = \begin{cases}
1 & \text{if }\Delta y \leq0 \\
\min(e^{-\Delta y / t},1) & \text{if }\Delta y > 0 
\end{cases}$$

* here $\Delta y = f(\mathbf{x'}) - f(\mathbf{x})$, and $t$ is the *temperature*.
* We call $\Pr(\text{accept }\mathbf{x'})$ the **Metropolis Criterion**, building block of *Accept/Reject* algorithms.
"""

# ╔═╡ 7ff00636-cb5d-45a5-b3d3-011054902f8e
# ©️ Kochenderfer and Wheeler
# f: function
# x: initial point
# T: transition distribution
# t: temp schedule, k_max: max iterations
function simulated_annealing(f, x, T, t, k_max) 
    y = f(x)
    ytrace = zeros(typeof(y),k_max)
    x_best, y_best = x, y 
    for k in 1 : k_max
        x′ = x + rand(T)
        y′ = f(x′)
        Δy = y′ - y
        if Δy ≤ 0 || rand() < exp(-Δy/t(k))
            x, y = x′, y′ 
        end
        if y′ < y_best
            x_best, y_best = x′, y′
        end 
        ytrace[k] = y_best
    end
    return x_best,ytrace
end

# ╔═╡ 3cc0c7d6-0bd7-435c-abde-2c70f51d437e
# enough banana. here is a function for big boys and girls to optimize!
function ackley(x, a=20, b=0.2, c=2π) 
    d = length(x)
    return -a*exp(-b*sqrt(sum(x.^2)/d)) - exp(sum(cos.(c*xi) for xi in x)/d) + a + exp(1)
end

# ╔═╡ e3ba1d6c-e781-4447-948c-51b4b6bc7813
packley() = surface(-30:0.1:30,-30:0.1:30,(x,y)->ackley([x, y]),cbar=false)

# ╔═╡ fcbf2bf1-f037-4fb1-8f71-c512699173a9
packley()

# ╔═╡ fb98ac86-bb03-49a5-a1a9-0eae38889823
anneal1 = Optim.optimize(ackley, [-30.0,-30], [30.0,150.0], [15.0,150], SAMIN(), Optim.Options(iterations=10^6))

# ╔═╡ f13056dc-3f17-438c-8b77-d8e1dc613c98
md"""
* let's have Nelder Mead have a go at this as well. 😈
"""

# ╔═╡ 83299874-e44b-4be3-8778-920df01581f4
nmackley = Optim.optimize(ackley, [-30.0,-30], [30.0,150.0], [15.0,150], NelderMead(), Optim.Options(iterations=10^6))

# ╔═╡ b43f3c20-aa3d-43ba-8a50-24645bd07ef1
let
	p0 = packley()
	scatter!([Optim.minimizer(anneal1)[1]],[Optim.minimizer(anneal1)[2]],[Optim.minimum(anneal1)],ms = 3, color = :red, label = "SAMIN", leg = :right)
	scatter!([Optim.minimizer(nmackley)[1]],[Optim.minimizer(nmackley)[2]],[Optim.minimum(nmackley)],ms = 3, color = :green, label = "Nelder-Mead")
end

# ╔═╡ ec549333-676d-4409-9256-8b4a8d8bf894
begin
danger(head,text) = Markdown.MD(Markdown.Admonition("danger", head, [text]));
danger(text) = Markdown.MD(Markdown.Admonition("danger", "Attention", [text]));
info(text) = Markdown.MD(Markdown.Admonition("info", "Info", [text]));
end

# ╔═╡ 5b5c51db-e468-407a-ad7e-7ef7eeaf8daa
info(md"""
Notice how this algorithm only uses the gradient `g`, *not* the actual function `f`.
""")

# ╔═╡ 4717e637-07ab-4486-ac9a-c56b03ec7361
danger("Careful now.",md"""
Lagarias et al. (SIOPT, 1999): At present there is no function in any dimension greater than one, for which the original Nelder-Mead algorithm has been proved to converge to a minimizer.

Given all the known inefficiencies and failures of the Nelder-Mead algorithm [...], one might wonder why it is *used at all*, let alone *why it is so extraordinarily popular*.
""")

# ╔═╡ 8330b5bc-68fc-4d34-a8b3-1180e75f3d97
sb = md"""
#
"""

# ╔═╡ dd1dc5d8-37c6-4263-9478-6112386d1b6e
sb

# ╔═╡ 28802a3b-2e75-4dee-ade6-c6361161c0e0
sb

# ╔═╡ 8f45b52e-b7ce-4210-88fd-26ae5e09ae00
sb

# ╔═╡ 43a0a115-5d53-48fc-af78-66f98e4f40ba
sb

# ╔═╡ 797442cc-3978-4749-907e-0627e81f93ad
sb

# ╔═╡ c026b58b-a46a-476f-aea3-74a5cd4aa867
sb

# ╔═╡ ba6896c9-4e2e-4534-98c8-c7047db6d3fd
sb

# ╔═╡ a76474ab-056c-49f7-aff7-65d3e57417f6
sb

# ╔═╡ c30d4d0e-9e00-41fe-8b92-f7b4d178146c
sb

# ╔═╡ f7fb3b3c-7c74-45eb-b1fb-c26170056d74
sb

# ╔═╡ 29d84925-76ef-4238-8c17-fcc699daa80a
sb

# ╔═╡ f05bebbb-1635-46b2-8df2-bbefc71dcdf2
sb

# ╔═╡ 220ba78a-eab9-4a98-9275-07046a7a267b
sb

# ╔═╡ 984a0439-fcf5-488b-8e4f-3b2ffac1bb2f
sb

# ╔═╡ 552d845e-817c-4e76-b699-37f149c6b5c1
sb

# ╔═╡ 6f9b7197-cfc4-4f34-9be0-11d5578f56d7
sb

# ╔═╡ 3b1c0e0a-a9b8-4ae8-9b31-a5d70e077201
sb

# ╔═╡ 5e9ce511-f89b-437d-be55-5b0d390e3bae
sb

# ╔═╡ 7280b993-bfdd-48f4-9c1b-602e8dda8667
sb

# ╔═╡ 2f08c4df-5bf1-4111-bebb-642a36768097
sb

# ╔═╡ ed9606b8-67d6-4c44-ac39-cfb59b8fa43c
sb

# ╔═╡ 4a0129f9-7ae8-4cef-b659-97a7fe7befdd
sb

# ╔═╡ a39eb324-d215-4f0e-b5c1-c1c818e4653e
sb

# ╔═╡ 14adfaf4-8126-487d-b7f2-f42d5239464a
sb

# ╔═╡ d9452576-bf3e-49a3-937d-66b176c298cf
sb

# ╔═╡ a4c9ccc0-60a6-4016-854b-7afd9bd4859b
sb

# ╔═╡ 09001364-6d74-4ecd-a4c4-a52638995e95
sb

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
LineSearches = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
OptimTestProblems = "cec144fc-5a64-5bc6-99fb-dde8f63e154c"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Roots = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "190ebecdd08372844c9e93af59bdc536b81d68f9"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "3b86719127f50670efe356bc11073d84b4ed7a5d"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.42"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

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

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "e38fbc49a620f5d0b660d7f543db1009fe0f8336"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.0"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

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

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

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

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

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

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

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

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

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

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "c1f51f704f689f87f28b33836fd460ecf9b34583"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.11.0"

    [deps.Optim.extensions]
    OptimMOIExt = "MathOptInterface"

    [deps.Optim.weakdeps]
    MathOptInterface = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"

[[deps.OptimTestProblems]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "1b7681f1d22153d81097ae259051c34361e0c0e7"
uuid = "cec144fc-5a64-5bc6-99fb-dde8f63e154c"
version = "2.0.3"

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

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

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

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

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

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "e52cf0872526c7a0b3e1af9c58a69b90e19b022e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.5"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

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

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "c5391c6ace3bc430ca630251d02ea9687169ca68"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.2"

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

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

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
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

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
# ╟─e6358a3b-f1d0-463c-a362-0451f0a20a8f
# ╟─110bde78-7381-4e0d-8ac8-4b878bd4de9b
# ╟─200201fd-1c4e-4242-9863-4970137d472a
# ╠═cdfd0cac-4c43-441d-bfb4-21ea5653a3a1
# ╟─e40bdc58-43a9-11ec-2c84-492ead8ce7c5
# ╟─a691d7e0-84d4-4a69-ba41-68147254ff16
# ╟─b7f8381c-3a9b-452e-9fc5-b7c9d4d69323
# ╟─d2a1181a-1146-478b-bcb2-cc763d6f211f
# ╟─dd1dc5d8-37c6-4263-9478-6112386d1b6e
# ╠═8db8d806-a6d1-4b98-9153-a92280de174a
# ╟─28802a3b-2e75-4dee-ade6-c6361161c0e0
# ╠═46533fde-5d5c-4a1a-a535-923672956f46
# ╠═25c0a22e-af50-4455-93fd-d23f26b23d52
# ╟─08d053d9-c865-4ff3-a551-823b5fb41524
# ╟─df826745-a4c4-4301-af27-066fe8e634f5
# ╟─8f45b52e-b7ce-4210-88fd-26ae5e09ae00
# ╟─4cf52278-d871-4eb2-967d-d6368d01b0c8
# ╟─62ed62ba-ce10-4d6d-b65f-0eb349465970
# ╟─43a0a115-5d53-48fc-af78-66f98e4f40ba
# ╟─d2ce25bc-0aa8-419d-832e-4582ac83ba86
# ╟─39170a86-c216-447a-b6fc-367f0c1c82a8
# ╟─797442cc-3978-4749-907e-0627e81f93ad
# ╟─8e7d4e57-578a-4c25-8c37-65a3fcda7b40
# ╟─dbac8440-659e-4a8d-a4b7-16bfd6d22c15
# ╟─c026b58b-a46a-476f-aea3-74a5cd4aa867
# ╟─d0b6dacf-8c13-4e31-a4a6-d4b5ee6a2f69
# ╟─adcd9256-650f-4d0e-8fe8-9b842b6b4c34
# ╟─a32820d0-5d91-4808-b942-202b760aec18
# ╟─ba6896c9-4e2e-4534-98c8-c7047db6d3fd
# ╟─fd1fba34-1c4f-48f7-83b4-fd60c796ac17
# ╠═1a3b8f05-aae9-4975-b8b5-9268145c1e82
# ╟─a76474ab-056c-49f7-aff7-65d3e57417f6
# ╟─f127562c-d6c9-42c6-8cca-b1fd33ad4fbe
# ╟─dc4c2888-8ff1-417d-a3bd-c133fb3bbbff
# ╟─c30d4d0e-9e00-41fe-8b92-f7b4d178146c
# ╟─59b26c7c-f6c5-4ba6-a067-9d07f179fc12
# ╟─f615768b-f212-4f40-ac9c-9eb96c0d6ea1
# ╟─1df4c4f2-6856-4431-afbb-df16541d22f7
# ╟─fc015791-cd9e-4a1c-b6ea-4c70284bef64
# ╟─32898baf-25d3-44cf-b92a-92e8ee320935
# ╠═20664b8a-59d7-4d80-9926-7a982f72b276
# ╟─625e38ee-04c1-4792-bf3e-8689bdb4df3b
# ╟─f7fb3b3c-7c74-45eb-b1fb-c26170056d74
# ╠═adb4ee25-44cb-4294-b410-f357e26336e1
# ╠═4a0dc0c1-ce50-425b-84ca-657c93b10966
# ╟─7a8a9f51-49bc-4b6d-b68d-20f06dd7e350
# ╟─a6f1e909-9b87-42c7-b47a-d7190ba245bf
# ╠═2f970459-c1b1-418a-bab2-615aeba2e6c4
# ╟─29d84925-76ef-4238-8c17-fcc699daa80a
# ╟─962e1fef-5ea1-4037-9e59-6b56c3f60909
# ╟─c031fe39-0f8c-4f6a-b851-266deb8f5b55
# ╟─f05bebbb-1635-46b2-8df2-bbefc71dcdf2
# ╠═3dab6ba2-7dd7-4f41-b1f3-e34d52211afb
# ╟─220ba78a-eab9-4a98-9275-07046a7a267b
# ╟─794092bf-cd6b-4cb8-aa11-c647157a0037
# ╟─984a0439-fcf5-488b-8e4f-3b2ffac1bb2f
# ╟─712a650d-4ada-4548-81ad-6c10b14d1a89
# ╟─4918190d-446a-46dd-9400-03a05c85541e
# ╠═caddc47a-7a4a-4f21-a524-3111f2ce2911
# ╟─e4a4f604-9831-4d91-944f-6d9c0f94be8f
# ╠═8428c078-ba7c-4322-8092-4076abad727d
# ╟─5b5c51db-e468-407a-ad7e-7ef7eeaf8daa
# ╟─3648b8ca-b9ae-48c4-8648-1fa139637805
# ╠═958e0db6-9fda-4d9b-9369-f295887d2fab
# ╠═68a7fdd2-2810-42e0-95d1-9163bbea7455
# ╠═f7347298-7f8b-4081-b7cd-d29601a8e389
# ╟─5222b1f9-73ef-4f85-b346-e6499f068a15
# ╠═e66e1b22-afba-44ad-994e-c256b23e7efe
# ╠═a8b9e0c7-d6bf-46c5-937e-a2970286496d
# ╟─8f72d4b0-147f-4a44-924f-2cfb51fe813e
# ╠═618c930b-cf4e-4755-abfb-4e51a5e1ceec
# ╠═636f368f-987f-404c-b39b-78b083766296
# ╟─455f7670-6be7-47ba-9c31-7c3824e1bb68
# ╠═1117da28-0103-4264-95b2-07562c98103b
# ╟─45468faf-d2c1-4a68-997f-41f9879ede0f
# ╟─11956a74-3ea2-491c-8eb1-d60db132c5c7
# ╟─552d845e-817c-4e76-b699-37f149c6b5c1
# ╟─cef266b6-7913-4abd-a665-03bd491049b0
# ╟─5a508717-8a42-466e-9415-ea6447290d19
# ╟─1a84b8d7-cfdc-420c-b4ff-d6cf32b82622
# ╟─6f9b7197-cfc4-4f34-9be0-11d5578f56d7
# ╟─d0d68f47-95dd-4aba-8817-d015090f8c4c
# ╟─e992331a-a739-45f7-9820-7ba6a6603cf9
# ╟─3b1c0e0a-a9b8-4ae8-9b31-a5d70e077201
# ╟─2cd50a99-f3d5-442d-9beb-cad56362ae1e
# ╟─5e9ce511-f89b-437d-be55-5b0d390e3bae
# ╟─28726ab6-747c-4537-94fd-df4f69ff0df5
# ╟─ca9fd4bb-f934-48df-8daf-f786013b6d69
# ╟─7728ef9f-c84d-48b0-a25d-eb534f126d65
# ╟─08339a83-73b6-4cb4-8b59-e30324fdfc8f
# ╟─7280b993-bfdd-48f4-9c1b-602e8dda8667
# ╟─5e8a328f-3624-4401-ad7a-f19bc94dd6cd
# ╠═86c1c1df-9ee4-47a0-a40a-69fa3c245a94
# ╟─2f08c4df-5bf1-4111-bebb-642a36768097
# ╟─37e8339e-cedc-46e4-8bcc-cae6bf2384a8
# ╠═6e297fb4-cf31-4928-9ec3-38b389fa6b58
# ╟─9ac7bf69-d1e2-46a4-96e8-4a8cb0ed3781
# ╠═c798c1a9-0f64-46fa-8844-3678c63708ef
# ╠═b62d94d4-4f64-4d3f-ae30-06e84013d3c7
# ╠═691f4695-c307-408f-892d-587b0b29a832
# ╠═e09184ba-da9d-43a2-bd6e-1a739e0722f5
# ╟─6d9670cf-5257-48af-8f62-3de6a88cbc51
# ╟─92212ec0-b822-4464-b346-dd221ad6f669
# ╟─4738c3b3-5c67-4ec6-8291-6426485a7832
# ╠═27e77174-2232-4d67-ba8f-d9d944cce543
# ╠═496a4d17-0a31-4b6c-bae0-1461603b92e9
# ╟─5e289cc6-5528-42d9-a3cb-a0d9dac6a849
# ╟─4921b275-6773-4efa-91ce-02869c527dba
# ╟─b9d44daa-8781-4c55-b8ef-f0a8b1c92406
# ╠═9e0b8149-482d-4323-9670-a9756236fbeb
# ╟─ed9606b8-67d6-4c44-ac39-cfb59b8fa43c
# ╟─4717e637-07ab-4486-ac9a-c56b03ec7361
# ╟─51fa22fd-9d3b-40f1-a428-f0cdd8bb2374
# ╟─4a0129f9-7ae8-4cef-b659-97a7fe7befdd
# ╟─2f6abe0f-43f5-40af-af51-561b76fcb29c
# ╟─a39eb324-d215-4f0e-b5c1-c1c818e4653e
# ╠═7ff00636-cb5d-45a5-b3d3-011054902f8e
# ╠═3cc0c7d6-0bd7-435c-abde-2c70f51d437e
# ╠═e3ba1d6c-e781-4447-948c-51b4b6bc7813
# ╟─14adfaf4-8126-487d-b7f2-f42d5239464a
# ╠═fcbf2bf1-f037-4fb1-8f71-c512699173a9
# ╟─d9452576-bf3e-49a3-937d-66b176c298cf
# ╠═fb98ac86-bb03-49a5-a1a9-0eae38889823
# ╟─a4c9ccc0-60a6-4016-854b-7afd9bd4859b
# ╟─f13056dc-3f17-438c-8b77-d8e1dc613c98
# ╠═83299874-e44b-4be3-8778-920df01581f4
# ╟─09001364-6d74-4ecd-a4c4-a52638995e95
# ╠═b43f3c20-aa3d-43ba-8a50-24645bd07ef1
# ╠═ec549333-676d-4409-9256-8b4a8d8bf894
# ╠═8330b5bc-68fc-4d34-a8b3-1180e75f3d97
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
