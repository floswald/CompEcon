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

Florian Oswald, 2026
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
    surf = surface(xs, ys, f; color = :jet)
    plt = contourf(xs, ys, f; color = :jet)
    

    # add an empty plot
    plot!(Float64[], Float64[]; line = (4, :arrow, :white), label = "")

    # extract the last plot series
    plt_path = plt.series_list[end]

    # # create the animation and save it
    anim = Animation()
    for x in eachcol(solver_trace)
        push!(plt_path, x[1], x[2]) # add a new point
        frame(anim)
    end
    return( gif(anim; fps = fps, show_msg = false), surf)
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

# ╔═╡ e129c042-4e39-4997-b253-f53a73cd7002
z[2]

# ╔═╡ 32d814d0-3658-4ab3-bdb8-88e988bc4603
z[1]

# ╔═╡ 5222b1f9-73ef-4f85-b346-e6499f068a15
md"""
## What about another function?
"""

# ╔═╡ 7bf422f2-6a51-4fdb-920a-461ad7b6727f
begin
	fsgd(x) = x[1]^2 + x[2]^2 - cos(4*x[1]) - cos(4*x[2])            
	gsgd(x)  = [2*x[1] + 4*sin(4*x[1]); 2*x[2] + 4*sin(4*x[2])]
	fsgd(x1, x2) = fsgd([x1; x2])
end

# ╔═╡ e66e1b22-afba-44ad-994e-c256b23e7efe
function runanim(f,g,x0, α)
	trace = our_gd(f,g,x0, α)
	xlims = (-3, 1)
	ylims = (-2, 1)
	create_anim(f, trace, xlims, ylims)
end

# ╔═╡ 44479374-3d7f-4073-a046-21e3ba7a2a71
z1 = runanim(fsgd,gsgd,[-3; -1],0.1)

# ╔═╡ 00aa155d-0986-46ab-abf0-4038c6cab42d
z1[2]

# ╔═╡ 5e17ea32-8034-4c26-be90-c697371e5f52
z1[1]

# ╔═╡ d3a78fd5-cf3e-4357-9471-6cc1cafb14fd
md"""
## Gradient Descent is like a ball 

This method is like a all rolling down a surface to the lowest (local) point. Susceptible to local minima.
"""

# ╔═╡ 5bac0d52-e645-48c7-ab85-7b7576be0170
begin
	# 1D function with a few local minima — nice "hill" landscape
	fball(x)  = 0.5x^2 - 1.5*cos(2x)
	dfball(x) = x + 3*sin(2x)
	
	# Center of a ball of radius r sitting on the curve at x.
	# Offset from the curve point along the outward unit normal to the tangent.
	# Tangent direction: (1, f'(x))  →  normal: (-f'(x), 1) / ‖·‖
	function ball_center(x, r=0.12)
	    s = dfball(x)
	    n = sqrt(1 + s^2)
	    return x - r*s/n,  fball(x) + r/n
	end
	
	# One gradient descent step, with slope clamped to [-0.5, 0.5] to avoid
	# big jumps on steep sections (mirrors the original Manim logic).
	function roll_step(x, dt=0.05)
	    s = clamp(dfball(x), -0.5, 0.5)
	    return x - s*dt
	end
	
	function ball_rolling_animation(; n_frames=150, fps=30)
	    curve_x = range(-3.5, 4.0; length=400)
	
	    # 11 balls spread across the domain, coloured blue→green
	    x_balls = collect(range(-2.7, 3.7; length=11))
	    ball_colors = [RGB(0, t, 1-t) for t in range(0, 1; length=11)]
	
	    anim = @animate for _ in 1:n_frames
	        x_balls .= roll_step.(x_balls)   # advance every ball one step
	
	        p = plot(curve_x, fball.(curve_x);
	                 lw=2, color=:black, legend=false,
	                 xlims=(-4, 4.5), ylims=(-2.5, 5.0),
	                 xlabel="x", ylabel="f(x)")
	
	        for (x, c) in zip(x_balls, ball_colors)
	            bx, by = ball_center(x)
	            scatter!([bx], [by];
	                     markersize=10, color=c,
	                     markerstrokecolor=:navy, markerstrokewidth=1)
	        end
	        p
	    end
	
	    gif(anim; fps=fps, show_msg=false)
	end
end

# ╔═╡ 4828233e-d8f1-420c-9e5a-02fbc58a77b9
ball_rolling_animation()

# ╔═╡ fe351528-85a9-4837-87f0-5be9c050d90a
md"""
## Stochastic Gradient Descent

Here is an idea. Instead of going the direction of the *full* gradient, we could randomly pick one coordinate at a time, and only go into that direction. This might avoid falling into local minima (by chance). We would have to make sure this still preserves the overall direction of the gradient though. Here is how:

We pick index i uniformly from $\{1, ..., n\}$, so $P(i = j) = 1/n$ for each $j$. Define:

$$\hat{g}(x) = n \times e_i \times g_i(x)$$

where $e_i$ is the i-th standard basis vector and $g_i(x) = \frac{\partial f}{\partial x_i}$ Then:

$$\begin{align}
\mathbb{E}[\hat{g}(x)] &= \sum_{j=1}^{n} P(i=j) \cdot n \cdot e_j \cdot g_j(x) \\
&= \sum_{j=1}^{n} \frac{1}{n} \cdot n \cdot e_j \cdot g_j(x) \\
&= \sum_{j=1}^{n} e_j \cdot g_j(x) \\
&= g(x)
\end{align}$$

So, in order to preserve the overall direction of the gradient, we need to scale our stochastic version of it (i.e. picking a corrdinate $i$ randomly) by the number of coordinates, $n$. Let's modifiy our code:

"""

# ╔═╡ 0d37432a-f87c-42b2-bc7b-0028966b31ac
function our_sgd(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    xs[:,1] = x
    n = length(x)
    for k in 1:max_iter
        i = rand(1:n)    # randomly pick one direction
        g_full = g(x)    # get full g
        g_stoch = zeros(n)  # make zeros
        g_stoch[i] = g_full[i]   # fill out only slot i
        x -= α * n * g_stoch     # take a step on x and scale by n
        xs[:,k+1] = x
    end
    return xs
end

# ╔═╡ cddf417a-c6ee-4d48-9a4a-a21e09053d25
function runanim_sgd(f, g, x0, α)
    trace = our_sgd(f, g, x0, α ; max_iter = 200)
    create_anim(f, trace, (-3,1), (-2,1))                                  
end 

# ╔═╡ c8866019-56b4-4248-b1f1-9b7f440354ce
md"""
Remember the function:
"""

# ╔═╡ 6ed345fd-afe4-4d6a-8fcd-b5584f37cb85
z2 = runanim_sgd(fsgd,gsgd,[-3; -1],0.15)

# ╔═╡ 69ee4f6b-82ee-4e15-a2af-cc51231d1467
z2[2]

# ╔═╡ 622a1ee4-a274-4c82-b9b2-1d2a96ef9fa8
z2[1]

# ╔═╡ f1b9dced-3a72-472b-b777-afcd48831bb9
z3 = runanim_sgd(fsgd,gsgd,[-3; -1],0.12)

# ╔═╡ d80d8a97-1daf-47c4-84a2-f46c051eacd0
z3[1]

# ╔═╡ 455f7670-6be7-47ba-9c31-7c3824e1bb68
md"""
## Back To Banana! 🍌
"""

# ╔═╡ 1117da28-0103-4264-95b2-07562c98103b
res_gd =  Optim.optimize(ro,g!, [-3.0,1.1],GradientDescent(linesearch=BackTracking(order = 2)), Optim.Options(store_trace = true,extended_trace=true,iterations = 5000));

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
md"1000 iteration = $(@bind i5k Slider(1:5000, show_value = true, default = 1))"

# ╔═╡ 1a84b8d7-cfdc-420c-b4ff-d6cf32b82622
res_gd_zoom = optimize(ro, [-1,1.], GradientDescent(linesearch=LineSearches.BackTracking(order=2)), Optim.Options(store_trace=true, extended_trace=true, iterations = 5000));

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
md"zoom slider = $(@bind ikzoom Slider(1:160, show_value = true))"

# ╔═╡ ca9fd4bb-f934-48df-8daf-f786013b6d69
let
	starts = 1
	c = contour(-.85:0.01:1.20, -0.2:0.01:1.1, (x,y)->sqrt(ro([x, y])), color=:viridis, legend=false, levels = exp.(range(log(0.1), stop = log(10.0), length = 70)))
    res = optimize(ro, [-0.6,0.2], GradientDescent(linesearch=LineSearches.BackTracking(order=3)), Optim.Options(store_trace=true, extended_trace=true))
    xtracemat = hcat(Optim.x_trace(res)...)
    
    plot!(xtracemat[1, starts:ikzoom], xtracemat[2, starts:ikzoom], mc = :white, legend=true, label="Gradient Descent")
    scatter!(xtracemat[1:1,ikzoom], xtracemat[2:2,ikzoom], mc=:black, msc=:red, label = "")
    scatter!(xtracemat[1:1,starts], xtracemat[2:2,starts], mc=:blue, msc=:blue, label="start")
	scatter!([1], [1], mc=:red, msc=:blue, label="optimum")
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
plot_optim(res_gd, [-3.0,1.1], -4.1:0.01:2, -4.5:0.01:4.1,i5k)

# ╔═╡ e992331a-a739-45f7-9820-7ba6a6603cf9
plot_optim(res_gd_zoom, [-1,1], -2.5:0.01:2, -1.5:0.01:2,ik)

# ╔═╡ 86c1c1df-9ee4-47a0-a40a-69fa3c245a94
begin
	res_newton = optimize(ro, g!, h!, [-1.,-1], Optim.Newton(), Optim.Options(store_trace=true, extended_trace=true))
	res_gd_2 = optimize(ro,g!, [-1.,-1], GradientDescent(linesearch=LineSearches.BackTracking(order=2)), Optim.Options(store_trace=true, extended_trace=true, iterations = 10000));
	# res_gd_2 = optimize(ro, g!, zeros(2), ConjugateGradient())
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
@benchmark optimize(ro, g!, h!,  [-1.0, 3.0], BFGS(linesearch=LineSearches.BackTracking(order=2)))

# ╔═╡ e09184ba-da9d-43a2-bd6e-1a739e0722f5
@benchmark optimize(ro, g!, h!,  [-1.0, 3.0], LBFGS(linesearch=LineSearches.BackTracking(order=2)))  # low memory

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

[compat]
BenchmarkTools = "~1.6.3"
LineSearches = "~7.5.1"
Optim = "~1.12.0"
OptimTestProblems = "~2.0.3"
Plots = "~1.41.6"
PlutoUI = "~0.7.79"
Roots = "~2.2.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "fde1de0e4c6519d19f5c0afca88c749baed3b42b"

[[deps.ADTypes]]
git-tree-sha1 = "f7304359109c768cf32dc5fa2d371565bb63b68a"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "1.21.0"

    [deps.ADTypes.extensions]
    ADTypesChainRulesCoreExt = "ChainRulesCore"
    ADTypesConstructionBaseExt = "ConstructionBase"
    ADTypesEnzymeCoreExt = "EnzymeCore"

    [deps.ADTypes.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "856ecd7cebb68e5fc87abecd2326ad59f0f911f3"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.43"

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
git-tree-sha1 = "35ea197a51ce46fcd01c4a44befce0578a1aaeca"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.5.0"

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
git-tree-sha1 = "78b3a7a536b4b0a747a0f296ea77091ca0a9f9a3"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.23.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceAMDGPUExt = "AMDGPU"
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = ["CUDSS", "CUDA"]
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceMetalExt = "Metal"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
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
git-tree-sha1 = "7fecfb1123b8d0232218e2da0c213004ff15358d"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.3"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CommonSolve]]
git-tree-sha1 = "78ea4ddbcf9c241827e7035c3a03e2e456711470"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.6"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "21d088c496ea22914fe80906eb5bce65755e5ec8"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.1"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"

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

[[deps.DifferentiationInterface]]
deps = ["ADTypes", "LinearAlgebra"]
git-tree-sha1 = "7ae99144ea44715402c6c882bfef2adbeadbc4ce"
uuid = "a0c0ee7d-e4b9-4e03-894e-1c5f64a51d63"
version = "0.7.16"

    [deps.DifferentiationInterface.extensions]
    DifferentiationInterfaceChainRulesCoreExt = "ChainRulesCore"
    DifferentiationInterfaceDiffractorExt = "Diffractor"
    DifferentiationInterfaceEnzymeExt = ["EnzymeCore", "Enzyme"]
    DifferentiationInterfaceFastDifferentiationExt = "FastDifferentiation"
    DifferentiationInterfaceFiniteDiffExt = "FiniteDiff"
    DifferentiationInterfaceFiniteDifferencesExt = "FiniteDifferences"
    DifferentiationInterfaceForwardDiffExt = ["ForwardDiff", "DiffResults"]
    DifferentiationInterfaceGPUArraysCoreExt = "GPUArraysCore"
    DifferentiationInterfaceGTPSAExt = "GTPSA"
    DifferentiationInterfaceMooncakeExt = "Mooncake"
    DifferentiationInterfacePolyesterForwardDiffExt = ["PolyesterForwardDiff", "ForwardDiff", "DiffResults"]
    DifferentiationInterfaceReverseDiffExt = ["ReverseDiff", "DiffResults"]
    DifferentiationInterfaceSparseArraysExt = "SparseArrays"
    DifferentiationInterfaceSparseConnectivityTracerExt = "SparseConnectivityTracer"
    DifferentiationInterfaceSparseMatrixColoringsExt = "SparseMatrixColorings"
    DifferentiationInterfaceStaticArraysExt = "StaticArrays"
    DifferentiationInterfaceSymbolicsExt = "Symbolics"
    DifferentiationInterfaceTrackerExt = "Tracker"
    DifferentiationInterfaceZygoteExt = ["Zygote", "ForwardDiff"]

    [deps.DifferentiationInterface.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DiffResults = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
    Diffractor = "9f5e2b26-1114-432f-b630-d3fe2085c51c"
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FastDifferentiation = "eb9bf01b-bf85-4b60-bf87-ee5de06c00be"
    FiniteDiff = "6a86dc24-6348-571c-b903-95158fe2bd41"
    FiniteDifferences = "26cc04aa-876d-5657-8c51-4c34ba976000"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    GTPSA = "b27dd330-f138-47c5-815b-40db9dd9b6e8"
    Mooncake = "da2b9cff-9c12-43a0-ae48-6db2b0edb7d6"
    PolyesterForwardDiff = "98d1487c-24ca-40b6-b7ab-df2af84e126b"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"
    SparseMatrixColorings = "0a514795-09f3-496d-8182-132a7b665d35"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EnumX]]
git-tree-sha1 = "c49898e8438c828577f04b92fc9368c388ac783c"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.7"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "66381d7059b5f3f6162f28831854008040a4e905"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "2f979084d1e13948a3352cf64a25df6bd3b4dca3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.16.0"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStaticArraysExt = "StaticArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Setfield"]
git-tree-sha1 = "9340ca07ca27093ff68418b7558ca37b05f8aeb1"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.29.0"

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
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "afb7c51ac63e40708a3071f80f5e84a752299d4f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.39"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "b7bfd56fa66616138dfe5237da4dc13bbd83c67f"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "44716a1a667cb867ee0e9ec8edc31c3e4aa5afdc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.24"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "be8a1b8065959e24fdc1b51402f39f3b6f0f6653"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.24+0"

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
git-tree-sha1 = "51059d23c8bb67911a2e6fd5130229113735fc7e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.11.0"

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

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Printf"]
git-tree-sha1 = "9ea3422d03222c6de679934d1c08f0a99405aa03"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.5.1"

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

[[deps.NLSolversBase]]
deps = ["ADTypes", "DifferentiationInterface", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "25a6638571a902ecfb1ae2a18fc1575f86b1d4df"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.10.0"

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

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Optim]]
deps = ["Compat", "EnumX", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "31b3b1b8e83ef9f1d50d74f1dd5f19a37a304a1f"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.12.0"

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

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

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

[[deps.Profile]]
deps = ["StyledStrings"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "d7a4bff94f42208ce3cf6bc8e4e7d1d663e7ee8b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "d5b7dd0e226774cbd87e2790e34def09245c7eab"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

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

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "442b4353ee8c26756672afb2db81894fc28811f3"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.6"

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
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

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
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5acc6a41b3082920f79ca3c759acbcecf18a8d78"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.7.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

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
git-tree-sha1 = "fa95b3b097bcef5845c142ea2e085f1b2591e92c"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.7.1"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
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

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "4909eb8f1cbf6bd4b1c30dd18b2ead9019ef2fad"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.18.1+0"

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

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "63aac0bcb0b582e11bad965cef4a689905456c03"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.125+1"

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

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

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
# ╠═e129c042-4e39-4997-b253-f53a73cd7002
# ╠═32d814d0-3658-4ab3-bdb8-88e988bc4603
# ╟─5222b1f9-73ef-4f85-b346-e6499f068a15
# ╠═7bf422f2-6a51-4fdb-920a-461ad7b6727f
# ╠═e66e1b22-afba-44ad-994e-c256b23e7efe
# ╠═44479374-3d7f-4073-a046-21e3ba7a2a71
# ╠═00aa155d-0986-46ab-abf0-4038c6cab42d
# ╠═5e17ea32-8034-4c26-be90-c697371e5f52
# ╟─d3a78fd5-cf3e-4357-9471-6cc1cafb14fd
# ╟─5bac0d52-e645-48c7-ab85-7b7576be0170
# ╠═4828233e-d8f1-420c-9e5a-02fbc58a77b9
# ╟─fe351528-85a9-4837-87f0-5be9c050d90a
# ╠═0d37432a-f87c-42b2-bc7b-0028966b31ac
# ╠═cddf417a-c6ee-4d48-9a4a-a21e09053d25
# ╟─c8866019-56b4-4248-b1f1-9b7f440354ce
# ╠═69ee4f6b-82ee-4e15-a2af-cc51231d1467
# ╠═6ed345fd-afe4-4d6a-8fcd-b5584f37cb85
# ╠═622a1ee4-a274-4c82-b9b2-1d2a96ef9fa8
# ╠═f1b9dced-3a72-472b-b777-afcd48831bb9
# ╠═d80d8a97-1daf-47c4-84a2-f46c051eacd0
# ╟─455f7670-6be7-47ba-9c31-7c3824e1bb68
# ╟─1117da28-0103-4264-95b2-07562c98103b
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
