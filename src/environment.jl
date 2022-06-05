"""
    get_constraints(object)

Returns the constraints imposed by the `object` (e.g. environment or obstacle) imposed on
the state. The returned constraints are callable as `constraints(state) -> gs` where `gs` is a
real-valued vector of constraint evaluations where `gs[i] >= 0` indicates that the ith constraint is
satisfied by the given `state`.
"""
function get_constraints end

"""
    geometry(environment)

Returns a geometry object that supports visualization with Makie.jl.
"""
function geometry end
