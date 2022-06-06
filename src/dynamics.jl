abstract type AbstractTemporalStructureTrait end
struct TimeVarying <: AbstractTemporalStructureTrait end
struct TimeInvariant <: AbstractTemporalStructureTrait end

"""
    temporal_structure_trait(object)

Returns an `AbstractTemporalStructureTrait` to signal if this object (e.g. strategy or dynamics) is
time varying or not.
"""
function temporal_structure_trait end

"""
    dynamics(state, actions[, t]).

Computes the next state for a collecition of player `actions` applied to the multi-player \
`dynamics`.
"""
abstract type AbstractDynamics end

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
    linearize(dynamics, x, u) -> LinearDynamics
Linearize about a trajectory `(x, u)` with `x` and and `u` layed out as `Vector{Vector}` (time
indexed).
"""
function linearize end
