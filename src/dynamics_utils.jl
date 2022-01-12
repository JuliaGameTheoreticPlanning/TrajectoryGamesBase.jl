"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.
"""
function rollout(dynamics, strategy, x1, T = horizon(dynamics))
    x = sizehint!([x1], T)
    u = sizehint!([strategy(x1, 1)], T)

    for tt in 1:(T - 1)
        xp = dynamics(x[tt], u[tt], tt)
        push!(x, xp)
        up = strategy(xp, tt)
        push!(u, up)
    end

    x, u
end
