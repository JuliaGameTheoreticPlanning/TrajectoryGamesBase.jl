Base.@kwdef struct TrajectoryGame{
    TC<:AbstractCostStructure,
    TD<:AbstractDynamics,
    TE<:AbstractEnvironment,
    TH,
}
    "A cost structure that holds information about the payoff structure."
    cost_structure::TC
    "The environment object that characerizes static constraints of the problem and can be used \
    for visualization."
    dynamics::TD
    "An environment object that holds information about constraints and can be used over visualization"
    env::TE
    "The number of time steps in the game"
    horizon::TH
end

function num_players(g::TrajectoryGame)
    length(g.cost_structure.cost)
end
