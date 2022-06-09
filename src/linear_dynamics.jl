"""
Single player (time-varying) linear system.
"""

"""
Time-varying linear system. `A` and `B` are indexed [time][:, :].
"""
Base.@kwdef struct LinearDynamics{TA,TB,TSB,TCB} <: AbstractDynamics
    A::TA
    B::TB
    "layout: (; lb::Vector{<:Real}, ub::Vector{<:Real})"
    state_bounds::TSB = (; lb = fill(-Inf, size(first(B), 1)), ub = fill(Inf, size(first(B), 1)))
    "layout (; lb::Vector{<:Real}, ub::Vector{<:Real})"
    control_bounds::TCB = (; lb = fill(-Inf, size(first(B), 2)), ub = fill(Inf, size(first(B), 2)))
end

function LinearDynamics(dynamics::ProductDynamics{<:AbstractVector{<:LinearDynamics}})
    (; A, B) = _block_diagonalize(
        temporal_structure_trait(dynamics),
        dynamics.subsystems,
        horizon(dynamics),
    )
    sb = state_bounds(dynamics)
    cb = control_bounds(dynamics)

    LinearDynamics(; A, B, state_bounds = sb, control_bounds = cb)
end

function _block_diagonalize(::TimeInvariant, linear_subsystems, horizon)
    A = Fill(blockdiag([sparse(sub.A.value) for sub in linear_subsystems]...), horizon)

    B = let
        B_joint = blockdiag([sparse(sub.B.value) for sub in linear_subsystems]...)
        total_xdim = sum(state_dim, linear_subsystems)
        udims = map(control_dim, linear_subsystems)
        B_joint_blocked = BlockArray(B_joint, [total_xdim], udims)
        Fill(B_joint_blocked, horizon)
    end
    (; A, B)
end

function TrajectoryGamesBase.temporal_structure_trait(::LinearDynamics{<:Fill,<:Fill})
    TimeInvariant()
end

function TrajectoryGamesBase.temporal_structure_trait(::LinearDynamics)
    TimeVarying()
end

function time_invariant_linear_dynamics(; A, B, horizon = ∞, bounds...)
    LinearDynamics(; A = Fill(A, horizon), B = Fill(B, horizon), bounds...)
end

function (sys::LinearDynamics)(x, u, t::Int)
    sys.A[t] * x + sys.B[t] * u
end

function (sys::LinearDynamics)(x, u, ::Nothing = nothing)
    temporal_structure_trait(sys) isa TimeInvariant ||
        error("Only time-invariant systems can ommit the `t` argument.")
    sys.A.value * x + sys.B.value * u
end

function state_dim(sys::LinearDynamics)
    size(first(sys.A), 1)
end

function control_dim(sys::LinearDynamics)
    size(first(sys.B), 2)
end

function control_dim(sys::LinearDynamics, ii)
    blocksizes(first(sys.B), 2)[ii]
end

function state_bounds(sys::LinearDynamics)
    sys.state_bounds
end

function control_bounds(sys::LinearDynamics)
    sys.control_bounds
end

function horizon(sys::LinearDynamics)
    length(sys.B)
end

function num_players(sys::LinearDynamics)
    blocksize(sys.B.value, 2)
end
