Base.@kwdef struct TrajectoryGame{
    TD<:AbstractDynamics,
    TC<:AbstractTrajectoryGameCost,
    TE<:AbstractEnvironment,
}
    "A cost structure that holds information about the payoff structure."
    cost::TC
    "An object that describes the dynamics of this trajectory game"
    dynamics::TD
    "The environment object that characerizes static constraints of the problem and can be used for visualization."
    env::TE
end

function num_players(g::TrajectoryGame)
    num_players(g.dynamics)
end
