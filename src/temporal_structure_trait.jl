abstract type AbstractTemporalStructure end
struct TimeVarying <: AbstractTemporalStructure end
struct TimeInvariant <: AbstractTemporalStructure end

"""
    temporal_structure(::Union{AbstractDynamics, AbstractStrategy})

Returns an `AbstractTemporalStructure` to signal if a strategy of system is time varying or not.
"""
function temporal_structure end
