module TrajectoryGamesBase

using BlockArrays: Block, blocks, mortar

include("temporal_structure_trait.jl")

include("solver.jl")
include("strategy.jl")
include("costs.jl")
include("dynamics.jl")
include("environment.jl")
include("game.jl")

end
