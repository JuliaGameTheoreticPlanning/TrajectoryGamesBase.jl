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

function (dynamics::ProductDynamics)(
    x::AbstractBlockArray,
    u::AbstractBlockArray,
    t = nothing,
    parameters = nothing,
)
    mortar([
        sub(x̂, u, t, parameters) for (sub, x̂, u) in zip(dynamics.subsystems, blocks(x), blocks(u))
    ])
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
    bounds_per_subsystem = [get_bounds(sub) for sub in dynamics.subsystems]
    lb = mortar([bounds.lb for bounds in bounds_per_subsystem])
    ub = mortar([bounds.ub for bounds in bounds_per_subsystem])
    (; lb, ub)
end

function state_bounds(dynamics::ProductDynamics)
    _mortar_bounds(dynamics, state_bounds)
end

function control_bounds(dynamics::ProductDynamics)
    _mortar_bounds(dynamics, control_bounds)
end

function TrajectoryGamesBase.state_dim(dynamics::TrajectoryGamesBase.ProductDynamics, player_index)
    TrajectoryGamesBase.state_dim(dynamics.subsystems[player_index])
end

function TrajectoryGamesBase.state_dim(game, player_index)
    TrajectoryGamesBase.state_dim(game.dynamics, player_index)
end

function TrajectoryGamesBase.control_dim(game, player_index)
    TrajectoryGamesBase.control_dim(game.dynamics, player_index)
end

function num_players(dynamics::ProductDynamics)
    length(dynamics.subsystems)
end

function horizon(dynamics::ProductDynamics)
    horizon(first(dynamics.subsystems))
end
