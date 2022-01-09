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

#=== Product Dynamics ===#

"""
AbstractDynamics which are the Cartesian product of several single player systems.
"""
Base.@kwdef struct ProductDynamics{T} <: AbstractDynamics
    subsystems::T
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

function state_bounds(dynamics::ProductDynamics)
    mortar([state_bounds(sub) for sub in dynamics.subsystems])
end

function control_bounds(dynamics::ProductDynamics)
    mortar([control_bounds(sub) for sub in dynamics.subsystems])
end

function num_players(dynamics::ProductDynamics)
    length(dynamics.subsystems)
end

#=== utils ===#

"""
Simulates a `strategy` by evolving the `dynamics` for `T` time steps starting from state `x1` and
applying the inputs dictated by the strategy.
"""
function rollout(dynamics::AbstractDynamics, strategy, x1, T)
    x = sizehint!([x1], T)
    us = sizehint!([strategy(x1, 1)], T)

    for tt in 2:T
        xp = dynamics(x[tt], us[tt], tt)
        push!(x, xp)
        usp = strategy(xp, tt)
        push!(us, usp)
    end

    x, us
end
