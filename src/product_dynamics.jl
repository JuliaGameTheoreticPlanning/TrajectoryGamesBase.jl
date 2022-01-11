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
    mortar([sub(x̂, u, t) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), block(u))])
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

function linearize(sys::ProductDynamics, x, u)
    error("Not Implemented")
    linearized_subsystems = map(eachindex(subsystems)) do ii
        sub = sys.subsystems
        x_sub = [xt[Block(ii)] for xt in x]
        u_sub = [ut[Block(ii)] for ut in u]
        linearize(sub, x_sub, u_sub)
    end

    @assert false
end

function temporal_structure_trait(dynamics::ProductDynamics)
    if all(sub -> temporal_structure_trait(sub) isa TimeInvariant, dynamics.subsystems)
        return TimeInvariant()
    end
    TimeVarying()
end

#=== utils ===#

"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.
"""
function rollout(dynamics::AbstractDynamics, strategy, x1, T = horizon(dynamics))
    x = sizehint!([x1], T)
    u = sizehint!([strategy(x1, 1)], T)

    for tt in 1:(T - 1)
        xp = dynamics(x[tt], u[tt], tt)
        push!(x, xp)
        up = strategy(xp, tt)
        push!(u, up)
    end

    x, u
end
