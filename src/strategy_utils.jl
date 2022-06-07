#== JointStrategy ==#

struct JointStrategy{T} <: AbstractStrategy
    substrategies::T
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

Base.@kwdef mutable struct RecedingHorizonStrategy{TS,TG,TSK}
    solver::TS
    game::TG
    solve_kwargs::TSK = (;)
    receding_horizon_strategy::Any = nothing
    time_last_updated::Int = 0
    turn_length::Int
end

function (strategy::RecedingHorizonStrategy)(state, time)
    plan_exists = !isnothing(strategy.receding_horizon_strategy)
    time_along_plan = time - strategy.time_last_updated + 1
    plan_is_still_valid = 1 <= time_along_plan <= strategy.turn_length

    update_plan = !plan_exists || !plan_is_still_valid
    if update_plan
        strategy.receding_horizon_strategy =
            solve_trajectory_game!(strategy.solver, strategy.game, state; strategy.solve_kwargs...)
        strategy.time_last_updated = time
        time_along_plan = 1
    end

    strategy.receding_horizon_strategy(state, time_along_plan)
end
