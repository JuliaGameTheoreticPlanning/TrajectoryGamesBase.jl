"""
    strategy(state, time)

Computes an `action` for the given `state` and `time`. Note that the `strategy` may be \
non-deterministic. Hence, unless it is seeded to the same pseudo-random state, it subsequent calls \
of `strategy` may yield different actions.
"""
abstract type AbstractStrategy end

#== OpenLoopStrategy ==#
#
struct OpenLoopStrategy{T1,T2}
    xs::T1
    us::T2
end

function (strategy::OpenLoopStrategy)(state, time)
    strategy.us[time]
end

#== JointStrategy ==#

struct JointStrategy{T1,T2} <: AbstractStrategy
    substrategies::T1
    info::T2
end

function JointStrategy(substrategies)
    info = nothing
    JointStrategy(substrategies, info)
end

function (strategy::JointStrategy)(x, t = nothing)
    join_actions([sub(x, t) for sub in strategy.substrategies])
end

function join_actions(actions)
    mortar(actions)
end

function visualize!(
    canvas,
    strategy::Makie.Observable{<:JointStrategy};
    colors = range(colorant"red", colorant"blue", length = length(strategy[].substrategies)),
    weight_offset = 0.0,
)
    for player_i in 1:length(strategy[].substrategies)
        color = colors[player_i]
        γ = Makie.@lift $strategy.substrategies[player_i]
        visualize!(canvas, γ; color, weight_offset)
    end
end

#== RecedingHorizonStrategy ==#

Base.@kwdef mutable struct RecedingHorizonStrategy{T1,T2,T3}
    solver::T1
    game::T2
    solve_kwargs::NamedTuple = (;)
    receding_horizon_strategy::Any = nothing
    time_last_updated::Int = 0
    turn_length::Int
    generate_initial_guess::T3 = (last_strategy, state, time) -> nothing
end

function (strategy::RecedingHorizonStrategy)(state, time)
    plan_exists = !isnothing(strategy.receding_horizon_strategy)
    time_along_plan = time - strategy.time_last_updated + 1
    plan_is_still_valid = 1 <= time_along_plan <= strategy.turn_length

    update_plan = !plan_exists || !plan_is_still_valid
    if update_plan
        initial_guess =
            strategy.generate_initial_guess(strategy.receding_horizon_strategy, state, time)
        warm_start_kwargs = isnothing(initial_guess) ? (;) : (; initial_guess)
        strategy.receding_horizon_strategy = solve_trajectory_game!(
            strategy.solver,
            strategy.game,
            state;
            strategy.solve_kwargs...,
            warm_start_kwargs...,
        )
        strategy.time_last_updated = time
        time_along_plan = 1
    end

    strategy.receding_horizon_strategy(state, time_along_plan)
end
