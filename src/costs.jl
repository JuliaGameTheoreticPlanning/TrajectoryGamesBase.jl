"A trait type that indicates the payoff structure of a game."
abstract type AbstractTrajectoryGameCost end

"""
Game cost for a game with zero-sum cost struture.
Requires that only a single stage_cost and reducer is passed for construction
"""
struct ZeroSumTrajectoryGameCost{TS,TR} <: AbstractTrajectoryGameCost
    stage_cost::TS
    reducer::TR
end

function (cost::ZeroSumTrajectoryGameCost)(xs, us)
    ts = eachindex(xs)
    reduced = Iterators.map(xs, us, ts) do x, u, t
        cost.stage_cost(x, u, t)
    end |> cost.reducer
    (reduced, -reduced)
end

struct GeneralSumTrajectoryGameCost{TS,TR} <: AbstractTrajectoryGameCost
    stage_costs::TS
    reducers::TR
end

function (cost::GeneralSumTrajectoryGameCost)(xs, us)
    ts = eachindex(xs)
    map(cost.reducers, cost.stage_costs) do reducer, stage_cost
        Iterators.map(xs, us, ts) do x, u, t
            stage_cost(x, u, t)
        end |> reducer
    end
end
