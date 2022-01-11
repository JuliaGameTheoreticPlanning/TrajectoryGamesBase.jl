Base.@kwdef struct TrajectoryGame{
    TCS<:AbstractCostStructure,
    TC<:TrajectoryGameCost{TCS},
    TD<:AbstractDynamics,
    TE<:AbstractEnvironment
}
    "A cost structure that holds information about the payoff structure."
    cost::TC
    "The environment object that characerizes static constraints of the problem and can be used \
    for visualization."
    dynamics::TD
    "An environment object that holds information about constraints and can be used over visualization"
    env::TE
end

function num_players(g::TrajectoryGame)
    length(g.cost.reducers)
end
