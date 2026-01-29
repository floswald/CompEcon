

using Distributed
nworkers()
8  # julia processes running

using SharedArrays
s = SharedArray{Float64}((10^5,)); 
# put 100K random numbers into s
s .= rand(10^5);  


@everywhere using Statistics
@everywhere n_bs_samples = 10_000  # num bootstrap samples

# a model...
@everywhere my_model(x) = rand(x, length(x))

# bootstrap sampling. heavy workload.
# creates an array of length n_bs_samples
@everywhere bs_means(x) = [mean(my_model(x)) for i in 1:n_bs_samples]

# single core version.
function f_1core(x)
    # compute the variance of those means
    # split over 8 independent batches
    var(vcat([bs_means(x) for i in 1:8]...))
end

# multi-core version
function f_multicore(x)
    # split a `promise` over 8 independent batches
    promise = [@spawn bs_means(x) for i in 1:8]
    # `fetch` triggers execution
    var(vcat([fetch(pr) for pr in promise]...))
end

# trigger compilation
f_1core(ones(80))
f_multicore(ones(80))

# measure
@time r1 = f_1core(s)
@time r2 = f_multicore(s)

@info "result 1core = $r1"
@info "result multicore = $r2"