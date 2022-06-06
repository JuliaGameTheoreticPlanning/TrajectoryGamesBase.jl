"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.

Kwargs:

- `get_info` is a callback `(γ, x, t) -> info` that can be passed to extract additional info from \
the strategy `γ` for each rollout state `x` and time `t`.

Returns a tuple of collections over states `xs`, inputs `us`, and extra information `infos`.
"""
function rollout(dynamics, strategy, x1, T = horizon(dynamics); get_info = (γ, x, t) -> nothing)
    xs = sizehint!([x1], T)
    us = sizehint!([strategy(x1, 1)], T)
    infos = sizehint!([get_info(strategy, x1, 1)], T)

    for tt in 1:(T - 1)
        xp = dynamics(xs[tt], us[tt], tt)
        push!(xs, xp)
        up = strategy(xp, tt + 1)
        push!(us, up)
        infop = get_info(strategy, xs[tt], tt + 1)
        push!(infos, infop)
    end

    (; xs, us, infos)
end
