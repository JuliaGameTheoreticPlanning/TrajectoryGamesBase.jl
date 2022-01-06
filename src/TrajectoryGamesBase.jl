module TrajectoryGamesBase

using BlockArrays: Block, blocks, mortar

include("solver.jl")
include("strategy.jl")
include("costs.jl")
include("dynamics.jl")
include("environment.jl")
include("game.jl")

end
