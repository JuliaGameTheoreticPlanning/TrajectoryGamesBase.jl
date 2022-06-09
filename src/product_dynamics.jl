"""
AbstractDynamics which are the Cartesian product of several single player systems.
"""
Base.@kwdef struct ProductDynamics{T} <: AbstractDynamics
    subsystems::T

    function ProductDynamics(subsystems::T) where {T}
        h = horizon(first(subsystems))
        all(sub -> horizon(sub) == h, subsystems) ||
            error("ProductDynamics can only be constructed from subsystems with the same horizon.")
        new{T}(subsystems)
    end
end

function (dynamics::ProductDynamics)(x::AbstractBlockArray, u::AbstractBlockArray, t = nothing)
    mortar([sub(x̂, u, t) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), blocks(u))])
end

function state_dim(dynamics::ProductDynamics)
    sum(state_dim(sub) for sub in dynamics.subsystems)
end

function control_dim(dynamcs::ProductDynamics)
    sum(control_dim(sub) for sub in dynamcs.subsystems)
end

function control_dim(dynamcs::ProductDynamics, ii)
    control_dim(dynamcs.subsystems[ii])
end

function _mortar_bounds(dynamics::ProductDynamics, get_bounds)
    lbs = [Float64[] for _ in dynamics.subsystems]
    ubs = [Float64[] for _ in dynamics.subsystems]

    for ii in eachindex(dynamics.subsystems)
        sub = dynamics.subsystems[ii]
        bounds = get_bounds(sub)
        push!(lbs, bounds.lb)
        push!(ubs, bounds.ub)
    end

    (; lb = mortar(lbs), ub = mortar(ubs))
end

function state_bounds(dynamics::ProductDynamics)
    _mortar_bounds(dynamics, state_bounds)
end

function control_bounds(dynamics::ProductDynamics)
    _mortar_bounds(dynamics, control_bounds)
end

function num_players(dynamics::ProductDynamics)
    length(dynamics.subsystems)
end

function horizon(dynamics::ProductDynamics)
    horizon(first(dynamics.subsystems))
end

function temporal_structure_trait(dynamics::ProductDynamics)
    if all(sub -> temporal_structure_trait(sub) isa TimeInvariant, dynamics.subsystems)
        return TimeInvariant()
    end
    TimeVarying()
end
