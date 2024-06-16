module TrajectoryGamesBase

using BlockArrays:
    BlockArrays, AbstractBlockArray, BlockArray, Block, blocks, mortar, blocksizes, blocksize
using InfiniteArrays: Fill, ∞
using SparseArrays: blockdiag, sparse
using LazySets: LazySets
using GeometryBasics: GeometryBasics
using Polyhedra: Polyhedra

include("visualize.jl")
export visualize!

include("dynamics.jl")
export AbstractTemporalStructureTrait,
    control_bounds,
    control_dim,
    get_constraints_from_box_bounds,
    horizon,
    num_players,
    rollout,
    state_bounds,
    state_dim,
    temporal_structure_trait,
    TimeInvariant,
    TimeVarying

include("product_dynamics.jl")
export ProductDynamics

include("linear_dynamics.jl")
export LinearDynamics, time_invariant_linear_dynamics

include("costs.jl")
export AbstractCostStructure,
    ZeroSumCostStructure,
    GeneralSumCostStructure,
    cost_structure_trait,
    TrajectoryGameCost,
    TimeSeparableTrajectoryGameCost

include("environment.jl")
export get_constraints, PolygonEnvironment

include("game.jl")
export TrajectoryGame

include("strategy.jl")
export AbstractStrategy, #
    OpenLoopStrategy,
    JointStrategy,
    RecedingHorizonStrategy,
    join_actions

include("solve.jl")
export solve_trajectory_game!

include("trajectory_utils.jl")
export to_blockvector,
    to_vector_of_vectors,
    to_vector_of_blockvectors,
    unstack_trajectory,
    stack_trajectories,
    flatten_trajectory,
    unflatten_trajectory

if !isdefined(Base, :get_extension)
    include("../ext/MakieExt.jl")
end

end
