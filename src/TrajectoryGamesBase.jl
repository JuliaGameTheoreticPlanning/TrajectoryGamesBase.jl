module TrajectoryGamesBase

using BlockArrays: BlockArray, Block, blocks, mortar, blocksizes, blocksize

include("temporal_structure_trait.jl")

include("solver.jl")
include("strategy.jl")
include("costs.jl")
include("dynamics.jl")
include("environment.jl")
include("game.jl")

end
