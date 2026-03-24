using Plots

# gradient descent
fgd(x) = sin(x[1] + x[2]) + cos(x[1])^2
ggd(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]
fgd(x1,x2) = fgd([x1;x2])  # overloading `fgd` with 2nd call


function our_gd(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)  # a matrix of x values. each column is one iteration k.
    xs[:,1] = x
    for k in 1:max_iter
        x -= α*g(x)   # take step of length α opposite (the minus!) of gradient 
        xs[:,k+1] = x # save current x as iterate k
    end
    return xs
end

# stochastic gradient descent   
fsgd(x) = x[1]^2 + x[2]^2 - cos(4*x[1]) - cos(4*x[2])            
gsgd(x)  = [2*x[1] + 4*sin(4*x[1]); 2*x[2] + 4*sin(4*x[2])]
fsgd(x1, x2) = fsgd([x1; x2])

function our_sgd(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    xs[:,1] = x
    n = length(x)
    for k in 1:max_iter
        i = rand(1:n)
        g_full = g(x)
        g_stoch = zeros(n)
        g_stoch[i] = g_full[i]
        x -= α * n * g_stoch
        xs[:,k+1] = x
    end
    return xs
end

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

function runanim(f,g,x0, α)
	trace = our_gd(f,g,x0, α)
	xlims = (-3, 1)
	ylims = (-2, 1)
	create_anim(f, trace, xlims, ylims)
end


function runanim_sgd(f, g, x0, α)
    trace = our_sgd(f, g, x0, α ; max_iter = 200)
    create_anim(f, trace, (-3,1), (-2,1))                                  
end   