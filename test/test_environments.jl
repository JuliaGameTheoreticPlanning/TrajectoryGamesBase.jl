@testset "environments" begin
    @testset "CircleEnvironment" begin
        rng = MersenneTwister(1)
        radius = 2
        env = CircleEnvironment(; radius, center = zeros(2))

        for i in 1:10
            p = randn(rng, 2)
            dist = distance_to_point(env, p)
            if norm(p) > radius
                @test dist > 0
            else
                @test dist <= 0
            end
        end
    end

    @testset "geometry" begin
        for env in (CircleEnvironment(), PolygonEnvironment(), CirclePolygonEnvironment())
            geometry(env)
        end
    end
end
