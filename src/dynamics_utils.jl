"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.
"""
function rollout(dynamics, strategy, x1, T = horizon(dynamics))
    xs = sizehint!([x1], T)
    us = sizehint!([strategy(x1, 1)], T)

    for tt in 1:(T - 1)
        xp = dynamics(xs[tt], us[tt], tt)
        push!(xs, xp)
        up = strategy(xp, tt + 1)
        push!(us, up)
    end

    xs, us
end
