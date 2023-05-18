"""
    get_constraints(object, player_index)

Returns the constraints imposed by the `object` (e.g. environment or obstacle) on the state for a
given `player_index`. The returned constraints are callable as `constraints(state) -> gs` where `gs`
is a real-valued vector of constraint evaluations where `gs[i] >= 0` indicates that the ith
constraint is satisfied by the given `state`.
"""
function get_constraints end

#== PolygonEnvironment ==#

struct PolygonEnvironment{T}
    set::T
end

function PolygonEnvironment(sides::Int = 4, radius = 4)
    r = radius
    N = sides
    vertices = map(1:N) do n
        θ = 2π * n / N + pi / sides
        [r * cos(θ), r * sin(θ)]
    end
    PolygonEnvironment(vertices)
end

function PolygonEnvironment(vertices::AbstractVector{<:AbstractVector{<:Real}})
    PolygonEnvironment(LazySets.VPolytope(vertices))
end

function get_constraints(environment::PolygonEnvironment, player_index = nothing)
    constraints = LazySets.constraints_list(environment.set)
    function (state)
        positions = (substate[1:2] for substate in blocks(state))
        mapreduce(vcat, Iterators.product(constraints, positions)) do (constraint, position)
            -constraint.a' * position + constraint.b
        end
    end
end
