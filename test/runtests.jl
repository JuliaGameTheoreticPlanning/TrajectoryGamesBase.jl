using TrajectoryGamesBase
using Test: @test, @testset
using BlockArrays: Block, eachblock, mortar, blocklength
using LinearAlgebra: norm, norm_sqr
using Makie: Makie

function setup_tag_examples(; Δt = 0.1)
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
        single_player_dynamics = time_invariant_linear_dynamics(; A, B)
        ProductDynamics([single_player_dynamics for _ in 1:2])
    end

    stage_cost_p1 = function (x, u)
        # substate per player (one pointmass per player)
        x1, x2 = eachblock(x)
        u1, u2 = eachblock(u)
        # position per player
        p1, p2 = x1[1:2], x2[1:2]
        norm(p1 - p2) + norm_sqr(u1) - norm_sqr(u2)
    end

    # construct a cost function with an additional hint on the cost structure
    generic_cost = TrajectoryGameCost(ZeroSumCostStructure()) do xs, us, context
        # cost from the perspective of player 1: minimize the distance to the evader (p2) and
        # minimize their own control effort
        c1 = sum(xu -> stage_cost_p1(xu...), zip(xs, us))
        # the cost returns a tuple: one scalar per player. Because have a zero-sum game, c2 is
        # simply -c1
        c2 = -c1
        (c1, c2)
    end

    # alternative cost formulation
    time_separable_cost = let
        discount_factor = 1.0
        TimeSeparableTrajectoryGameCost(
            cs -> reduce(.+, cs),
            ZeroSumCostStructure(),
            discount_factor,
        ) do x, u, t, context
            c1 = stage_cost_p1(x, u)
            c2 = -c1
            (c1, c2)
        end
    end

    env = PolygonEnvironment()

    generic_game = TrajectoryGame(; dynamics, cost = generic_cost, env)
    time_separable_game = TrajectoryGame(; dynamics, cost = time_separable_cost, env)

    (; generic_game, time_separable_game)
end

module Mock
using TrajectoryGamesBase: TrajectoryGamesBase
using Test: @test

const trivial_strategy = let
    xs = [ones(4) for _ in 1:20]
    us = [zeros(2) for _ in 1:20]
    TrajectoryGamesBase.OpenLoopStrategy(xs, us)
end

struct Solver end

function TrajectoryGamesBase.solve_trajectory_game!(
    solver,
    game,
    initial_state;
    initial_guess = nothing,
)
    @test !isnothing(initial_guess)
    TrajectoryGamesBase.JointStrategy([trivial_strategy, trivial_strategy])
end
end # Mock module

@testset "TrajectoryGamesBase.jl" begin
    examples = setup_tag_examples()
    last_total_costs = nothing

    for (game_name, game) in pairs(examples)
        @testset "$game_name" begin
            trivial_joint_strategy = JointStrategy([Mock.trivial_strategy, Mock.trivial_strategy])
            x1 = mortar([[1.0, 0, 0, 0], [-1.0, 0, 0, 0]])
            horizon = 20
            context = nothing

            local trivial_steps

            @testset "dynamics" begin
                linear_dynamics = LinearDynamics(game.dynamics)
                u_random = mortar([rand(2), rand(2)])
                t = 1
                trivial_steps = rollout(game.dynamics, trivial_joint_strategy, x1, horizon)
                linear_steps = rollout(linear_dynamics, trivial_joint_strategy, x1, horizon)
                @test all(x == x1 for x in trivial_steps.xs)
                @test trivial_steps == linear_steps
                @test game.dynamics(x1, u_random, t) ≈ linear_dynamics(x1, u_random, t)
                @test state_dim(linear_dynamics) == state_dim(game.dynamics) == 8
                @test control_dim(linear_dynamics) == control_dim(game.dynamics) == 4
                @test control_dim(linear_dynamics, 1) == control_dim(game.dynamics, 1) == 2
                @test num_players(linear_dynamics) == num_players(game.dynamics) == 2
                @test temporal_structure_trait(linear_dynamics) ==
                      temporal_structure_trait(game.dynamics) ==
                      TimeInvariant()
            end

            @testset "cost" begin
                @test cost_structure_trait(game.cost) isa ZeroSumCostStructure

                total_costs = game.cost(trivial_steps.xs, trivial_steps.us, context)
                @test total_costs[1] > 0
                @test total_costs[1] == -total_costs[2]
                if !isnothing(last_total_costs)
                    @test total_costs == last_total_costs
                end
                last_total_costs = total_costs
            end

            @testset "environment" begin
                constraints = get_constraints(game.env)
                # probe a feasible state
                @test all(constraints(zeros(4)) .> 0)
                # probe an infeasible state
                @test any(constraints(fill(10, 4)) .< 0)
            end

            @testset "receding horizon utils" begin
                receding_horizon_strategy = TrajectoryGamesBase.RecedingHorizonStrategy(;
                    solver = Mock.Solver(),
                    game,
                    turn_length = 2,
                    generate_initial_guess = (last_strategy, state, time) -> :foo,
                )
                receding_steps = rollout(game.dynamics, receding_horizon_strategy, x1, horizon)
                receding_steps_skipped = rollout(
                    game.dynamics,
                    receding_horizon_strategy,
                    x1,
                    horizon;
                    skip_last_strategy_call = true,
                )
                @test receding_steps == trivial_steps
                @test receding_steps_skipped.xs == trivial_steps.xs
                @test receding_steps_skipped.us == trivial_steps.us[1:(end - 1)]
            end
        end
    end

    @testset "visualization" begin
        trivial_joint_strategy = JointStrategy([Mock.trivial_strategy, Mock.trivial_strategy])

        @testset "2D visaulziation" begin
            environment = PolygonEnvironment()
            Makie.plot(environment)
            Makie.plot!(Mock.trivial_strategy)
            Makie.plot!(trivial_joint_strategy)
        end

        @testset "3D visualization" begin
            figure = Makie.Figure()
            axis3 = Makie.Axis3(figure[1, 1])
            Makie.plot!(Mock.trivial_strategy; dimensionality = 3)
            Makie.plot!(
                trivial_joint_strategy;
                substrategy_attributes = [
                    (; dimensionality = 3) for _ in trivial_joint_strategy.substrategies
                ],
            )
        end
    end

    @testset "trajectory utils" begin
        @testset "to_block_vector" begin
            x = [1, 2, 3, 4]
            to_blockvector = TrajectoryGamesBase.to_blockvector([2, 2])
            x_blocked = to_blockvector(x)
            @test x_blocked == x
            @test x_blocked[Block(1)] == [1, 2]
            @test x_blocked[Block(2)] == [3, 4]
        end

        @testset "to_vector_of_vectors" begin
            x = [1:40;]
            to_vector_of_vectors = TrajectoryGamesBase.to_vector_of_vectors(4)
            x_vector_of_vectors = to_vector_of_vectors(x)
            @test length(x_vector_of_vectors) == 10
            @test x_vector_of_vectors[1] == [1, 2, 3, 4]
        end

        @testset "to vector_of_blockvectors" begin
            x = [1:40;]
            to_vector_of_blockvectors = TrajectoryGamesBase.to_vector_of_blockvectors([2, 2])
            x_vector_of_blockvectors = to_vector_of_blockvectors(x)
            @test length(x_vector_of_blockvectors) == 10
            @test x_vector_of_blockvectors[1][Block(1)] == [1, 2]
            @test x_vector_of_blockvectors[1][Block(2)] == [3, 4]
        end

        @testset "stack and unstack trajectory" begin
            xs = 1:40 |> TrajectoryGamesBase.to_vector_of_blockvectors([2, 2])
            us = 1:2 |> TrajectoryGamesBase.to_vector_of_blockvectors([1, 1])
            trajectory = (; xs, us)
            trajectory_unstacked = TrajectoryGamesBase.unstack_trajectory(trajectory)

            for (ii, player_trajectory) in pairs(trajectory_unstacked)
                @test blocklength(player_trajectory.xs[begin]) == 1
                @test blocklength(player_trajectory.us[begin]) == 1
                @test player_trajectory.xs[begin] == [1, 2] .+ (ii - 1) * 2
                @test player_trajectory.us[begin] == [1] .+ (ii - 1)
            end

            re_stacked = TrajectoryGamesBase.stack_trajectories(trajectory_unstacked)
            @test re_stacked == trajectory
        end

        @testset "flatten and unflatten trajectory" begin
            flat_trajectory = [1:60;]
            unflattened_trajectory = TrajectoryGamesBase.unflatten_trajectory(flat_trajectory, 4, 2)

            @test length(unflattened_trajectory.xs) == 10
            @test length(unflattened_trajectory.us) == 10

            re_flattened = TrajectoryGamesBase.flatten_trajectory(unflattened_trajectory)
            @test re_flattened == flat_trajectory
        end
    end
end
