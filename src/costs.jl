
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
    cost
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
    cost
end
