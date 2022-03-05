#== Cost structure traints ==#
"""
An additional structure hint for further optimization. For example if `_f` has zero-sum cost
structure (i.e. we have that `c1, c2 = cs` and `c1 == -c2` for arbitray inputs to `_f`) then we
can pass the `ZeroSumCostStructure` trait type here.
"""
abstract type AbstractCostStructure end
struct ZeroSumCostStructure <: AbstractCostStructure end
struct GeneralSumCostStructure <: AbstractCostStructure end

struct TrajectoryGameCost{T1,T2}
    """
    A function `(xs, us) -> cs` that maps a sequence of joint states `xs` and inputs `us` to a tuple
    of scalar costs per player.
    """
    _f::T1
    """
    An aditional structure hint for further optimization. See the docstring of
    `AbstractCostStructure` for further details.
    """
    structure::T2
    # Note, an additional field here could later indicate time-separability
end

function (c::TrajectoryGameCost)(args...; kwargs...)
    c._f(args...; kwargs...)
end

struct TimeSeparableTrajectoryGameCost{T1,T2,T3}
    """
    A function `(x, u, t) -> sc` which maps the joint state `x` and input `u` for a given time step
    `t` to a tuple of scalar costs `sc` for each player at that time.
    """
    stage_cost::T1
    """
    A function `(scs -> cs)` that reduces a sequence of stage cost tuples to a tuple of costs `cs`
    for all players. In the simplest case, this reduction operation may simply be the sum of elemnts
    (e.g. `reducer = scs -> reduce(.+, scs)`).
    """
    reducer::T2
    """
    An aditional structure hint for further optimization. See the docstring of
    `AbstractCostStructure` for further details.
    """
    structure::T3
end

function (c::TimeSeparableTrajectoryGameCost)(xs, us)
    ts = Iterators.eachindex(xs)
    Iterators.map((x, u, t) -> c.stage_cost(x, u, t), xs, us, ts) |> c.reducer
end
