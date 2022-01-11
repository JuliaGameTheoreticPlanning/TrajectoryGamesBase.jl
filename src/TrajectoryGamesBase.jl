module TrajectoryGamesBase

using BlockArrays: BlockArray, Block,blocks, mortar, blocksizes, blocksize
using InfiniteArrays: Fill, ∞
using SparseArrays: blockdiag, sparse

include("temporal_structure_trait.jl")

include("dynamics.jl")
include("product_dynamics.jl")
include("linear_dynamics.jl")

include("costs.jl")
include("environment.jl")
include("game.jl")

include("strategy.jl")
include("joint_strategy.jl")

include("solver.jl")

end
