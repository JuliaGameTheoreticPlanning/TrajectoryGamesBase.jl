using TrajectoryGamesBase
using Test: @testset
using BlockArrays: eachblock, mortar
using LinearAlgebra: norm

function setup_tag_example(; Δt = 0.1)
    dynamics = let
        A = [
            1 0 Δt 0
            0 1 0 Δt
            0 0 1 0
            0 0 0 1
        ]
        B = [
            0 0
            0 0
            Δt 0
            0 Δt
        ]
        single_player_dynamics = LinearDynamics(; A, B)
        ProductDynamics([single_player_dynamics for _ in 1:2])
    end

    # construct a cost function with an additional hint on the cost structure
    cost = TrajectoryGameCost(ZeroSumCostStructure()) do xs, us, context
        # cost from the perspective of player 1: minimize the distance to the evader (p2) and
        # minimize their own control effort
        c1 = sum(zip(xs, us)) do (x, u)
            # substate per player (one pointmass per player)
            x1, x2 = eachblock(x)
            u1, u2 = eachblock(u)
            # position per player
            p1, p2 = x1[1:2], x2[1:2]
            norm(p1 - p2) + norm_sqr(u1) - norm_sqr(u2)
        end
        # the cost returns a tuple: one scalar per player. Because have a zero-sum game, c2 is
        # simply -c1
        c2 = -c1
        (c1, c2)
    end

    env = PolygonEnvironment()

    TrajectoryGame(; dynamics, cost, env)
end

@testset "TrajectoryGamesBase.jl" begin
    # TODO: add unit tests. For now we only have integration tests of downstream packages.
    game = setup_tag_example()
end
