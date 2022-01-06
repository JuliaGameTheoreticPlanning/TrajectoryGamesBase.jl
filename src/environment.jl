abstract type AbstractEnvironment end

# TODO don't disptach on solver here. All of them should be able to use the same representation.
# Potentially, even all of themcould use Symbolics.jl
# TODO: add docs
function setup_environmental_constraints end

"""
    geometry(env::AbstractEnvironment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
