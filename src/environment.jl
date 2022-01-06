abstract type AbstractEnvironment end


function g_position end

"""
    geometry(env::AbstractEnvironment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
