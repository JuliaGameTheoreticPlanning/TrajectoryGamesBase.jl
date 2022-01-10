"""
    dynamics(state, actions[, t]).

Computes the next state for a collecition of player `actions` applied to the multi-player \
`dynamics`.
"""
abstract type AbstractDynamics end

# """
# The number of players in the dynamical system.
# """
# function num_players end

"Number of states."
function state_dim end

"""
    control_dim(sys)

Returns the total number of control inputs.

    control_dim(sys, i)

Returns the number of control inputs for player i.
"""
function control_dim end

"Returns a tuple `(lb, ub)` of the lower and upper bound of the state vector."
function state_bounds end

"Returns a tuple `(lb, ub)` of the lower and upper bound of the control vector."
function control_bounds end

"The number of players that control this sytem."
function num_players end

"The number of time steps the dynamics are valid for."
function horizon end

"""
    linearize(dynamics, x, u)
Linearize about a trajectory `(x, u)` with `x` and and `u` layed out as `Vector{Vector}` (time
indexed).
"""
function linearize end

#=== Product Dynamics ===#

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

function (dynamics::ProductDynamics)(x, us, t = nothing)
    mortar([sub(x̂, u, t) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), us)])
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

function temporal_structure(dynamics::ProductDynamics)
    if all(sub -> temporal_structure(sub) isa TimeInvariant, dynamics.subsystems)
        return TimeInvariant()
    end
    return TimeVarying()
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
