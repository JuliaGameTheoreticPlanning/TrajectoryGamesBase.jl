Base.@kwdef struct TrajectoryGame{T1<:AbstractDynamics,T2,T3,T4,T5}
    "An object that describes the dynamics of this trajectory game"
    dynamics::T1
    "A cost function taking (xs, us, [context]) with states `xs` and inputs `us` in Blocks and an
    optional `context` information. Returns a collection of cost values; one per player."
    cost::T2
    "The environment object that characerizes static constraints of the problem and can be used for
    visualization."
    env::T3
    "An object which encodes the constraints between different players. It must be callable as
    `con(xs, us) -> gs`: returning a collection of scalar constraints `gs` each of which is negative
    if the corresponding contraint is active."
    coupling_constraints::T4 = nothing
    "
    A function callable as `con(x) -> gs` returning a collection of scalar constraints for a single
    state `x`.

    TODO: think about the exact layout here:

    - how it relates to the other constraints (dynamics, coupling_constraints, etc.). Are any of
    these maybe redundant now?
    - maybe this should also return a label with each constraint wether this constraint is shared
    with other players.
    - should this also take in dynamics, and the whole trajectory (xs, us) as input?
    "
    constraints::T5 = nothing
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
