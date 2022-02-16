__precompile__(false)

module TrajectoryGamesBase

using BlockArrays: AbstractBlockArray, BlockArray, Block, blocks, mortar, blocksizes, blocksize
using InfiniteArrays: Fill, ∞
using SparseArrays: blockdiag, sparse

include("temporal_structure_trait.jl")

include("dynamics.jl")
include("product_dynamics.jl")
include("linear_dynamics.jl")
include("dynamics_utils.jl")

include("costs.jl")
include("environment.jl")
include("game.jl")

include("strategy.jl")
include("strategy_utils.jl")

include("solver.jl")

end
