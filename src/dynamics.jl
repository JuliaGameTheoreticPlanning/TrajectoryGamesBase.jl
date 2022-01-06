# TODO: not sure if this abstract type is really needed
abstract type AbstractSinglePlayerDynamics end

"""
May be called as dynamics(state, strategies).

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

#=== Product Dynamics ===#

"""
AbstractMultiPlayerDynamics which are the Cartesian product of several single player systems.
"""
Base.@kwdef struct ProductDynamics{T} <: AbstractMultiPlayerDynamics
    subsystems::T
end

function (dynamics::ProductDynamics)(x, us, t)
    mortar([sub(x̂, u, t) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), us)])
end

state_dim(dynamics::ProductDynamics) = sum(state_dim(sub) for sub in dynamics.subsystems)
control_dim(dynamics::ProductDynamics, player) = control_dim(dynamics.subsystems[player])
control_dim(dynamics::ProductDynamics) = sum(control_dim(sub) for sub in dynamics.subsystems)
num_players(dynamics::ProductDynamics) = length(dynamics.subsystems)

"""
Returns the indices for a given `player` index into the joint `x`.
"""
function state_indices(dynamics::ProductDynamics, player::Integer)
    #    start_idx = sum(1:(player - 1); init = 0) do ii
    #        state_dim(dynamics.subsystems[ii])
    #    end + 1
    # TODO: Fix Zygote diff issues
    if player == 1
        start_idx = 1
    elseif player == 2
        start_idx = 5
    end
    start_idx:(start_idx + state_dim(dynamics.subsystems[player]) - 1)
end
