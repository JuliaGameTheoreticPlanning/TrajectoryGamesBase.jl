"""
    strategy(state, time)

Computes an `action` for this player for the given `state` and `time`. Note that the `strategy` may
be non-deterministic. Hence, unless it is seeded to the same pseudo-random state, it subsequent
calls of `strategy` may yield different actions.
"""
abstract type AbstractStrategy end

(s::AbstractStrategy)(x, ::Nothing) = s(x)

"""
    visualize_strategy!(fig, strategy, player_color)

Visualize the strategy `strategy` on a Makie canvas `fig` with a given `player_color`.
"""
function visualize_strategy! end
