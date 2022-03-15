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

#== RecedingHorizonStrategy ==#

Base.@kwdef struct RecedingHorizonStrategy{TS,TG,TSK}
    solver::TS
    game::TG
    solve_kwargs::TSK = (;)
    receding_horizon_strategy::Ref{Any} = Ref{Any}()
    time_last_updated::Ref{Int} = Ref{Int}(0)
    turn_length::Int = 10
end

function (strategy::RecedingHorizonStrategy)(state, time)
    plan_exists = isdefined(strategy.receding_horizon_strategy, 1)
    plan_is_still_valid = (
        strategy.time_last_updated[] <=
        time <=
        strategy.time_last_updated[] + strategy.turn_length - 1
    )

    update_plan = !plan_exists || !plan_is_still_valid
    if update_plan
        strategy.receding_horizon_strategy[] =
            solve_trajectory_game!(strategy.solver, strategy.game, state; strategy.solve_kwargs...)
        strategy.time_last_updated[] = time
    end

    time_along_plan = time - strategy.time_last_updated[] + 1
    strategy.receding_horizon_strategy[](state, time_along_plan)
end
