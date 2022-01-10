abstract type AbstractTemporalStructureTrait end
struct TimeVarying <: AbstractTemporalStructureTrait end
struct TimeInvariant <: AbstractTemporalStructureTrait end

"""
    temporal_structure_trait(::Union{AbstractDynamics, AbstractStrategy})

Returns an `AbstractTemporalStructureTrait` to signal if a strategy of system is time varying or not.
"""
function temporal_structure_trait end
