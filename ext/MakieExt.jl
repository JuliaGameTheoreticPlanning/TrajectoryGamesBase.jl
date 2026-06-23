module MakieExt
using TrajectoryGamesBase: TrajectoryGamesBase
using Makie: Makie, @recipe
using Colors: @colorant_str
using GeometryBasics: GeometryBasics

Makie.plottype(::TrajectoryGamesBase.PolygonEnvironment) = Makie.Poly

function Makie.convert_arguments(
    ::Type{<:Makie.Poly},
    environment::TrajectoryGamesBase.PolygonEnvironment,
)
    geometry = GeometryBasics.Polygon(GeometryBasics.Point{2}.(environment.set.vertices))
    (geometry,)
end

function TrajectoryGamesBase.visualize!(
    canvas,
    environment::TrajectoryGamesBase.PolygonEnvironment;
    color = :lightgray,
    kwargs...,
)
    Makie.poly!(canvas, environment; color, kwargs...)
end

function TrajectoryGamesBase.visualize!(
    canvas,
    strategy::Makie.Observable{<:TrajectoryGamesBase.JointStrategy};
    colors = range(colorant"red", colorant"blue", length = length(strategy[].substrategies)),
    weight_offset = 0.0,
)
    for player_i in 1:length(strategy[].substrategies)
        color = colors[player_i]
        γ = Makie.@lift $strategy.substrategies[player_i]
        TrajectoryGamesBase.visualize!(canvas, γ; color, weight_offset)
    end
end

@recipe(OpenLoopStrategyViz) do scene
    Makie.Attributes(;
        color = :black,
        position_subsampling = 1,
        trajectory_point_size = 5,
        starttime = nothing,
        endtime = nothing,
        visible = true,
        scale_factor = 1.0,
        extra_attributes = nothing,
        dimensionality = 2,
    )
end

Makie.plottype(::TrajectoryGamesBase.OpenLoopStrategy) = OpenLoopStrategyViz

function Makie.plot!(viz::OpenLoopStrategyViz{<:Tuple{TrajectoryGamesBase.OpenLoopStrategy}})
    strategy = viz[1]
    strategy_points = Makie.@lift(
        begin
            starttime = something($(viz.starttime), firstindex($strategy.xs))
            endtime = something($(viz.endtime), lastindex($strategy.xs))
            subsampled_states = $strategy.xs[starttime:($(viz.position_subsampling)):endtime]
            if $(viz.dimensionality) == 2
                [Makie.Point2f(xi[1], xi[2]) for xi in subsampled_states]
            elseif $(viz.dimensionality) == 3
                [Makie.Point3f(xi[1], xi[2], xi[3]) for xi in subsampled_states]
            else
                throw(ArgumentError("Unsupported vizualisation dimensionality: $(viz.dimensionality)"))
            end
        end
    )
    if isnothing(viz.extra_attributes[])
        kwargs = (;)
    else
        kwargs = map(keys(viz.extra_attributes[])) do key
            key => Makie.@lift($(viz.extra_attributes)[key])
        end |> NamedTuple
    end

    Makie.lines!(viz, strategy_points; viz.color, viz.visible, kwargs...)
    Makie.scatter!(
        viz,
        strategy_points;
        color = viz.color,
        markersize = Makie.@lift($(viz.trajectory_point_size) * $(viz.scale_factor)),
        viz.visible,
        kwargs...,
    )
    viz
end

#=== Joint Strategy Visualization ===#

@recipe(JointStrategyViz) do scene
    Makie.Attributes(; substrategy_attributes = nothing)
end

Makie.plottype(::TrajectoryGamesBase.JointStrategy) = JointStrategyViz

function Makie.plot!(viz::JointStrategyViz{<:Tuple{TrajectoryGamesBase.JointStrategy}})
    joint_strategy = viz[1]
    # assuming that the number of players does not change between calls
    for substrategy_index in eachindex(joint_strategy[].substrategies)
        substrategy = Makie.Observable{Any}(nothing)
        Makie.on(joint_strategy) do joint_strategy
            substrategy[] = joint_strategy.substrategies[substrategy_index]
        end
        if isnothing(viz.substrategy_attributes[])
            kwargs = (;)
        else
            kwargs =
                map(keys(viz.substrategy_attributes[][substrategy_index])) do key
                    key => Makie.@lift($(viz.substrategy_attributes)[substrategy_index][key])
                end |> NamedTuple
        end
        joint_strategy[] = joint_strategy[]
        Makie.plot!(viz, substrategy; kwargs...)
    end

    viz
end

end
