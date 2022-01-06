abstract type AbstractCostStructure end

"A trait type that indicates zero sum payoff structure of a game."
struct ZeroSumCostStructure{TC} <: AbstractCostStructure
    cost::TC
end

struct GeneralSumCostStructure{TC<:Vector} <: AbstractCostStructure
    cost::TC
end

