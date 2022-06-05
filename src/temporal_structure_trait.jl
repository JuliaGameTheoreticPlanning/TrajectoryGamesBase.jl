abstract type AbstractTemporalStructureTrait end
struct TimeVarying <: AbstractTemporalStructureTrait end
struct TimeInvariant <: AbstractTemporalStructureTrait end

"""
    temporal_structure_trait(object)

Returns an `AbstractTemporalStructureTrait` to signal if this object (e.g. strategy or dynamics) is
time varying or not.
"""
function temporal_structure_trait end
