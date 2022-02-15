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

function (cost::ZeroSumTrajectoryGameCost)(player_i, xs, us)
    ts = eachindex(xs)
    Iterators.map(xs, us, ts) do x, u, t
        cost.stage_cost(x, u, t)
    end |> cost.reducer
end

# TODO: introduce cost for geneal-sum games
struct GeneralSumTrajectoryGameCost{TS,TR} <: AbstractTrajectoryGameCost end
