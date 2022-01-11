struct JointStrategy{T} <: AbstractStrategy
    substrategies::T
end

function (strategy::JointStrategy)(x, t = nothing)
    join_actions([sub(x, t) for sub in strategy.substrategies])
end

function join_actions(actions)
    mortar(actions)
end
