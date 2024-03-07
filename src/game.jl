"""
Problem definition for a trajectory game.
"""
Base.@kwdef struct TrajectoryGame{TD<:AbstractDynamics,TC,TE,TS}
    "An object that describes the dynamics of this trajectory game"
    dynamics::TD
    "A cost function taking (xs, us, parameters) with states `xs` and inputs `us` in Blocks and an
    optional `parameters` information. Returns a collection of cost values; one per player."
    cost::TC
    "The environment object that characerizes static constraints of the problem and can be used for
    visualization."
    environment::TE
    "An object which encodes the constraints between different players. It must be callable as
    `constraint_function(state, control, parameters) -> gs`: returning a vector of constraints `gs`.

    Sign convention: `gs[i]` which is non-negative when the `i`th constraint is satisfied."
    coupling_constraints::TS = nothing
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
