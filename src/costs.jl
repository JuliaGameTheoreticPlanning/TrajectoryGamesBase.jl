"A trait type that indicates zero sum payoff structure of a game."
abstract type AbstractCostStructure end
struct ZeroSumCostStructure <: AbstractCostStructure end
struct GeneralSumCostStructure <: AbstractCostStructure end

"""
A time-separable cost representation that supports different
"""
struct TrajectoryGameCost{TC<:AbstractCostStructure,TS,TR}
    cost_structure::TC
    "A vector of callable stage cost, where `stage_costs[ii](x, u, t) -> Real` yields the cost for \
    player `ii` at a single state `x`, input `u`, and time `t`."
    stage_costs::TS
    "A vector of callable reduction functions that combine sequence of costs. For example, `sum` \
    computs the sum of stage costs."
    reducers::TR

    function TrajectoryGameCost(
        cost_structure::ZeroSumCostStructure,
        stage_cost,
        reducer = sum,
    ) where {TS,TR}
        !(stage_cost isa AbstractVector) || error(
            "ZeroSumCostStructure does not accept vectors of costs. Pass a single callable for \
            `stage_cost` and `reducer` instead",
        )

        stage_costs = (stage_cost, (-) ∘ stage_cost)
        reducers = (reducer, reducer)
        new{ZeroSumCostStructure,typeof(stage_costs),typeof(reducers)}(
            cost_structure,
            stage_costs,
            reducers,
        )
    end
end

"""
Computes the cost over the full *sequence* of state `xs` and inputs `us`.
"""
function (cost::TrajectoryGameCost)(player_i, xs, us)
    ts = eachindex(xs)
    Iterators.map(xs, us, ts) do x, u, t
        cost.stage_costs[player_i](x, u, t)
    end |> cost.reducers[player_i]
end
