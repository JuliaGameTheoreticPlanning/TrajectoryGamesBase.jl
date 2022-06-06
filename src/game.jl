Base.@kwdef struct TrajectoryGame{TD<:AbstractDynamics,TC,TE,TS}
    "A cost function taking (xs, us, [context]) with states `xs` and inputs `us` in Blocks and an
    optional `context` information. Returns a collection of cost values; one per player."
    cost::TC
    "An object that describes the dynamics of this trajectory game"
    dynamics::TD
    "The environment object that characerizes static constraints of the problem and can be used for visualization."
    env::TE
    """
    An object which encodes the constraints between different players. It must be callable as
    `con(xs, us) -> gs`: returning a collection of scalar constraints `gs` each of which is negative
    if the corresponding contraint is active.
    """
    coupling_constraints::TS = nothing
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
