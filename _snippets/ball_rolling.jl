using Plots

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
