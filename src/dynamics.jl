# TODO: not sure if this abstract type is really needed
abstract type AbstractSinglePlayerDynamics end

"""
    dynamics(state, strategies[, t]).

Computes the next state for the (potentially non-deterministic) `strategies` applied to the \
multi-player `dynamics`. Some of the `strategies` may be non-deterministic. Hence, the call to this \
function may modify `strategy` and subsequent calls of this function on the same `state` may thus \
yield different next states unless the `strategy` is seeded to the same state before each call.
"""
abstract type AbstractMultiPlayerDynamics end

"""
The number of players in the dynamical system.
"""
function num_players end

"Number of states."
function state_dim end

"Number of control inputs."
function control_dim end

"Returns a tuple `(lb, ub)` of the lower and upper bound of the state vector."
function state_bounds end

"Returns a tuple `(lb, ub)` of the lower and upper bound of the control vector."
function control_bounds end

#=== Product Dynamics ===#

"""
AbstractMultiPlayerDynamics which are the Cartesian product of several single player systems.
"""
Base.@kwdef struct ProductDynamics{T} <: AbstractMultiPlayerDynamics
    subsystems::T
end

function (dynamics::ProductDynamics)(x, us, t = nothing)
    mortar([sub(x̂, u, t) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), us)])
end

function state_dim(dynamics::ProductDynamics)
    sum(state_dim(sub) for sub in dynamics.subsystems)
end

function control_dim(dynamics::ProductDynamics, player)
    control_dim(dynamics.subsystems[player])
end

function control_dim(dynamics::ProductDynamics)
    sum(control_dim(sub) for sub in dynamics.subsystems)
end

function state_bounds(dynamics::ProductDynamics)
    mortar([state_bounds(sub) for sub in dynamics.subsystems])
end

function control_bounds(dynamics::ProductDynamics)
    mortar([control_bounds(sub) for sub in dynamics.subsystems])
end

function num_players(dynamics::ProductDynamics)
    length(dynamics.subsystems)
end
