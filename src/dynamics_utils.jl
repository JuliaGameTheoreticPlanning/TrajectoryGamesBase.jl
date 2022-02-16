"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.

Kwargs:

- `getinfo` is a callback that can be passed to extract additional info from the strategy `γ` for
each rollout state `x` and time `t`.

Returns a tuple of collections over states `xs`, inputs `us`, and extra information `infos`.
"""
function rollout(dynamics, strategy, x1, T = horizon(dynamics); getinfo = (γ, x, t)- > nothing)
    xs = sizehint!([x1], T)
    us = sizehint!([strategy(x1, 1)], T)
    infos = sizehint!([getinfo(strategy, x1, 1)], T)

    for tt in 1:(T - 1)
        xp = dynamics(xs[tt], us[tt], tt)
        push!(xs, xp)
        up = strategy(xp, tt + 1)
        push!(us, up)
        infop = getinfo(strategy, x1, tt + 1)
        push!(infos, infop)
    end

    xs, us, infos
end
