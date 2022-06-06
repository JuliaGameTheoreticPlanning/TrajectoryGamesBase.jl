#== Cost structure traits ==#
"""
A cost structure hint that may be used to admitfurther optimization.
"""
abstract type AbstractCostStructure end
struct ZeroSumCostStructure <: AbstractCostStructure end
struct GeneralSumCostStructure <: AbstractCostStructure end

"""
    cost_structure_trait(cost)

Returns the cost structure trait associated with the cost.
"""
function cost_structure_trait end

"""
    TrajectoryGameCost(f, structure)

A generic cost representation for a `TrajectoryGame`.

The cost is callable as `cost(xs, us, context) -> cost_per_player` to map a sequence of states `xs`
and inputs `us` as well as a `context` object to a collection of costs, one scalar value for each
player.
"""
struct TrajectoryGameCost{T1,T2}
    """
    A function `(xs, us, context) -> cs` that maps a sequence of states `xs` and inputs `us`
    and `context` information to a tuple of scalar costs per player.
    """
    _f::T1
    """
    A cost structure hint. See the docstring of `AbstractCostStructure` for further details.
    """
    structure::T2
end

(c::TrajectoryGameCost)(args...; kwargs...) = c._f(args...; kwargs...)
cost_structure_trait(c::TrajectoryGameCost) = c.structure

struct TimeSeparableTrajectoryGameCost{T1,T2,T3}
    """
    A function `(x, u, t, context_state) -> sc` which maps the joint state `x` and input `u` for a
    given time step and surrounding context information `t` to a tuple of scalar costs `sc` for each
    player *at that time*.
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
    "A discount factor γ ∈ (0, 1] that exponentially decays the weight of future stage costs."
    discount_factor::Float64
end

function (c::TimeSeparableTrajectoryGameCost)(xs, us, context_state)
    ts = Iterators.eachindex(xs)
    Iterators.map(xs, us, ts) do x, u, t
        c.discount_factor^(t - 1) .* c.stage_cost(x, u, t, context_state)
    end |> c.reducer
end

cost_structure_trait(c::TimeSeparableTrajectoryGameCost) = c.structure
