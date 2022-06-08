"""
    get_constraints(object)

Returns the constraints imposed by the `object` (e.g. environment or obstacle) imposed on
the state. The returned constraints are callable as `constraints(state) -> gs` where `gs` is a
real-valued vector of constraint evaluations where `gs[i] >= 0` indicates that the ith constraint is
satisfied by the given `state`.
"""
function get_constraints end

#== PolygonEnvironment ==#

struct PolygonEnvironment{T}
    set::T
end

function PolygonEnvironment(sides::Int = 4, radius = 4)
    r = radius
    N = sides
    points = map(1:N) do n
        θ = 2π * n / N + pi / sides
        [r * cos(θ), r * sin(θ)]
    end
    PolygonEnvironment(LazySets.VPolytope(points))
end

function visualize!(canvas, env; color = :lightgray)
    geometry = GeometryBasics.Polygon(GeometryBasics.Point{2}.(env.set.vertices))
    Makie.poly!(canvas, geometry; color)
end

function get_constraints(env::PolygonEnvironment)
    constraints = LazySets.constraints_list(env.set)
    function (state)
        position = state[1:2]
        mapreduce(vcat, constraints) do c
            -c.a' * position + c.b
        end
    end
end
