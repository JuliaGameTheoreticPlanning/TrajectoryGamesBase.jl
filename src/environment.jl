abstract type AbstractEnvironment end

# TODO add documentation
function get_position_constraints end

"""
    geometry(env::AbstractEnvironment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
