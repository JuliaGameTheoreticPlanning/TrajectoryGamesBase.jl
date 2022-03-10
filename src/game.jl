Base.@kwdef struct TrajectoryGame{
    TD<:AbstractDynamics,
    TC,
    TE<:AbstractEnvironment,
    TS
}
    "A cost function taking a trajectory pairing (xs, us) in Blocks and gives the cost per player in a tuple."
    cost::TC
    "An object that describes the dynamics of this trajectory game"
    dynamics::TD
    "The environment object that characerizes static constraints of the problem and can be used for visualization."
    env::TE
    """
    TODO: this probably should have the same interface as `cost`.

    An iterable collection of intra-trajectory constraints. Each intra-trajectory constraint
    `con(τs...) -> gs` maps a variable number trajectories to an iterable collection of scalars `gs`
    which are positive non-negative when all constraints between these trajectories are satsifies.
    """
    shared_constraints::TS
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
