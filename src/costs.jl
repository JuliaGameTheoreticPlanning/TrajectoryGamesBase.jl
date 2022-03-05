#== Cost structure traints ==#
struct ZeroSumCostStructure end
struct GeneralSumCostStructure end

struct TrajectoryGameCost{T1,T2}
    """
    A function `(xs, us) -> cs` that maps a sequence of joint states `xs` and inputs `us` to a tuple
    of scalar costs per player.
    """
    _f::T1
    """
    An additional structure hint for further optimization. For example if `_f` has zero-sum cost
    structure (i.e. we have that `c1, c2 = cs` and `c1 == -c2` for arbitray inputs to `_f`) then we
    can pass the `ZeroSumCostStructure` trait type here.
    """
    structure::T2
    # Note, an additional field here could later indicate time-separability
end

function (c::TrajectoryGameCost)(args...; kwargs...)
    c._f(args...; kwargs...)
end

"""
Constructs a cost function for a game with zero-sum time-separable cost struture.
Requires that only a single stage_cost and reducer is passed for construction.
Returns a cost function evaluating a trajectory pairing for both players.
"""
function zero_sum_time_separable_trajectory_game_cost(stage_cost, reducer)
    function cost(xs, us)
        ts = eachindex(xs)
        reduced = Iterators.map(xs, us, ts) do x, u, t
            stage_cost(x, u, t)
        end |> reducer
        (reduced, -reduced)
    end
    TrajectoryGameCost(cost, ZeroSumCostStructure())
end

"""
Constructs a cost function for a game with general-sum time-separable cost struture.
Requires that a stage_cost and reducer is passed for each player.
Returns a cost function evaluating a trajectory pairing for both players.
"""
function general_sum_time_separable_trajectory_game_cost(stage_costs, reducers)
    function cost(xs, us)
        ts = eachindex(xs)
        map(reducers, stage_costs) do reducer, stage_cost
            Iterators.map(xs, us, ts) do x, u, t
                stage_cost(x, u, t)
            end |> reducer
        end
    end
    TrajectoryGameCost(cost, GeneralSumCostStructure())
end
