abstract type AbstractEnvironment end

# TODO add documentation
function to_sublevelset end

"""
    geometry(env::AbstractEnvironment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
