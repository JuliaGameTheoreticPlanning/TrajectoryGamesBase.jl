struct JointStrategy{T} <: AbstractStrategy
    substrategies::T
end

function (strategy::JointStrategy)(x, t = nothing)
    mortar(sub(x, t) for sub in strategy.substrategies)
end
