Base.@kwdef struct TrajectoryGame{TD<:AbstractDynamics,TC,TE,TS}
    "An object that describes the dynamics of this trajectory game"
    dynamics::TD
    "A cost function taking (xs, us, context) with states `xs` and inputs `us` in Blocks and an
    optional `context` information. Returns a collection of cost values; one per player."
    cost::TC
    "The environment object that characerizes static constraints of the problem and can be used for
    visualization."
    environment::TE
    "An object which encodes the constraints between different players. It must be callable as
    `con(state, control, context) -> gs`: returning a collection of scalar constraints `gs` each of which non-negative
    when the constraint is satisfied."
    coupling_constraints::TS = nothing
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
