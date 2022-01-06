abstract type AbstractEnvironment end


function to_sublevelset end

"""
    geometry(env::AbstractEnvironment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
