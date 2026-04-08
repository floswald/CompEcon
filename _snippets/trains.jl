using GLPK
using JuMP
using OrderedCollections


function trains1()

    stations = Dict(zip(1:5, ["Milano","Bergamo","Brescia","Como","Pavia"]))

    # milano capacity
    p_M = 4

    # parked
    k = Dict(1=>2, 2=>4, 3=>3, 4=>3, 5=>2)

    # R[i] = tuple of passenger weights for each service on arc i→1 (Milano)
    R = OrderedDict(
        2 => (8, 6, 5),
        3 => (7,),
        4 => (5, 5),
        5 => (4,)
    )

    c = Dict(2=>2, 3=>2, 4=>2, 5=>2)

    m = Model(GLPK.Optimizer)

    # x[station][service_index] = trains dispatched on that service
    x = Dict(
        s => [@variable(m, lower_bound=0, base_name="x[$s,$i]")
              for i in eachindex(R[s])]
        for s in keys(R)
    )

    # delta[station][service_index] = shortfall on that service
    delta = Dict(
        s => [@variable(m, lower_bound=0, base_name="δ[$s,$i]")
              for i in eachindex(R[s])]
        for s in keys(R)
    )

    # Objective: minimise weighted shortfall — weights w_r are the constants from R
    @objective(m, Min, sum(
        R[s][i] * delta[s][i]                  # w_r * δ_r  (linear!)
        for s in keys(R)
        for i in eachindex(R[s])
    ))

    # (1) Fleet availability: total trains dispatched from station s ≤ parked there
    @constraint(m, fleet[s = keys(R)],
        sum(x[s]) <= k[s]
    )

    # (2) Service coverage: each service needs a train or incurs shortfall
    @constraint(m, coverage[s = keys(R), i = eachindex(R[s])],
        x[s][i] + delta[s][i] >= 1
    )

    # (3) Line capacity: total trains on arc s→Milano ≤ capacity
    @constraint(m, capacity[s = keys(R)],
        sum(x[s]) <= c[s]
    )

    @constraint(m, [s = keys(R), i = eachindex(R[s])], x[s][i] <= 1)

    # total trains arriving at Milano ≤ terminal capacity
    @constraint(m, terminus, sum(x[s][i] for s in keys(R) for i in eachindex(R[s])) <= p_M)

    optimize!(m)

    @assert termination_status(m) == MOI.OPTIMAL
    println(termination_status(m))
    println("Objective: ", objective_value(m))

    for s in keys(R)
        for i in eachindex(R[s])
            println("  x[$s,$i] = $(value(x[s][i]))  δ[$s,$i] = $(value(delta[s][i]))")
        end
    end

    return m, x, delta
end

function trains_large()

    stations = Dict(
        1  => "Milano Centrale",
        2  => "Bergamo",
        3  => "Brescia",
        4  => "Como",
        5  => "Pavia",
        6  => "Varese",
        7  => "Lecco",
        8  => "Cremona",
        9  => "Lodi",
        10 => "Monza",
        11 => "Vigevano",
        12 => "Saronno",
    )

    # terminal capacity at Milano Centrale
    p_M = 80

    # trains parked overnight at each satellite station
    k = Dict(
        2  => 18,
        3  => 15,
        4  => 14,
        5  => 10,
        6  => 12,
        7  => 8,
        8  => 9,
        9  => 7,
        10 => 11,
        11 => 6,
        12 => 10,
    )
    # total fleet = 120, so ~100 can arrive given p_M = 80 and arc caps

    # R[s] = tuple of passenger weights (100s) for each scheduled service s → Milano
    # more services than capacity on each arc → genuine competition
    R = OrderedDict(
        2  => (12, 10, 9, 8, 7, 6),      # 6 Bergamo services, high demand
        3  => (11, 9, 8, 7, 6),           # 5 Brescia
        4  => (8,  7, 6, 5),              # 4 Como
        5  => (6,  5, 4),                 # 3 Pavia
        6  => (9,  7, 6, 5),              # 4 Varese
        7  => (7,  6, 5),                 # 3 Lecco
        8  => (5,  4, 4),                 # 3 Cremona
        9  => (6,  5),                    # 2 Lodi
        10 => (10, 8, 7, 6),              # 4 Monza, high demand
        11 => (4,  3),                    # 2 Vigevano
        12 => (8,  7, 5),                 # 3 Saronno
    )
    # total services = 39, total weights sum to 296 (00s passengers)

    # arc capacities s → Milano (trains per morning peak)
    # set below sum(R[s]) for most stations to force real tradeoffs
    c = Dict(
        2  => 4,
        3  => 4,
        4  => 3,
        5  => 2,
        6  => 3,
        7  => 2,
        8  => 2,
        9  => 2,
        10 => 3,
        11 => 2,
        12 => 3,
    )
    # total arc capacity = 30, well below 39 services and below p_M=80
    # so arc caps are the first bottleneck, terminus is the second

    m = Model(GLPK.Optimizer)

    x = Dict(
        s => [@variable(m, lower_bound=0, base_name="x[$s,$i]")
              for i in eachindex(R[s])]
        for s in keys(R)
    )

    delta = Dict(
        s => [@variable(m, lower_bound=0, base_name="δ[$s,$i]")
              for i in eachindex(R[s])]
        for s in keys(R)
    )

    @objective(m, Min, sum(
        R[s][i] * delta[s][i]
        for s in keys(R)
        for i in eachindex(R[s])
    ))

    # (1) fleet availability
    @constraint(m, fleet[s = keys(R)], sum(x[s]) <= k[s])

    # (2) service coverage
    @constraint(m, coverage[s = keys(R), i = eachindex(R[s])],
        x[s][i] + delta[s][i] >= 1)

    # (3) arc capacity
    @constraint(m, capacity[s = keys(R)], sum(x[s]) <= c[s])

    # (4) one train per service
    @constraint(m, one_train[s = keys(R), i = eachindex(R[s])], x[s][i] <= 1)

    # (5) Milano terminal capacity
    @constraint(m, terminus,
        sum(x[s][i] for s in keys(R) for i in eachindex(R[s])) <= p_M)

    optimize!(m)

    @assert termination_status(m) == MOI.OPTIMAL

    obj = objective_value(m)
    total_trains = sum(value(x[s][i]) for s in keys(R) for i in eachindex(R[s]))
    total_services = sum(length(R[s]) for s in keys(R))
    covered = sum(value(x[s][i]) >= 0.5 ? 1 : 0 for s in keys(R) for i in eachindex(R[s]))

    println("=== Solution ===")
    println("Trains arriving at Milano:  $(round(Int, total_trains))")
    println("Services covered:           $covered / $total_services")
    println("Weighted shortfall:         $obj")
    println()

    for s in sort(collect(keys(R)))
        xvals = [value(x[s][i]) for i in eachindex(R[s])]
        dvals = [value(delta[s][i]) for i in eachindex(R[s])]
        n_covered = sum(v >= 0.5 ? 1 : 0 for v in xvals)
        println("$(stations[s]) (cap=$(c[s]), parked=$(k[s])): $n_covered/$(length(R[s])) services covered")
        for i in eachindex(R[s])
            status = xvals[i] >= 0.5 ? "✓" : "✗"
            println("  $status service $i  w=$(R[s][i])  x=$(round(xvals[i], digits=2))  δ=$(round(dvals[i], digits=2))")
        end
    end

    println()
    println("Shadow prices (arc capacity constraints):")
    for s in sort(collect(keys(R)))
        sp = shadow_price(capacity[s])
        println("  $(stations[s]): $(round(sp, digits=2))")
    end
    println("Shadow price (terminus):  $(round(shadow_price(terminus), digits=2))")

#     More precisely the shadow price answers: if the capacity constraint were relaxed by 1 — i.e. c[2] <= 5 instead of <= 4 — by how much would the optimal objective decrease? The answer is 7, because the marginal unit of capacity would be used to cover the service with weight 7, saving exactly 7 units of weighted shortfall.
# This is why the shadow price always equals the weight of the next uncovered service on that arc (assuming the terminus isn't the binding constraint). You can verify by bumping c[2] to 5 and checking that the objective drops by exactly 7.

    return m, x, delta
end

m, x, delta = trains_large()