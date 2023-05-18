module MakieVizExt
using TrajectoryGamesBase: TrajectoryGamesBase
using Makie: Makie, @recipe
using Colors: @colorant_str
using GeometryBasics: GeometryBasics

Makie.plottype(::TrajectoryGamesBase.PolygonEnvironment) = Makie.Poly

function Makie.convert_arguments(::Type{<:Makie.Poly}, environment)
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
    Makie.Attributes(; line_attributes = nothing, scatter_attributes = nothing)
end

Makie.plottype(::TrajectoryGamesBase.OpenLoopStrategy) = OpenLoopStrategyViz

function Makie.plot!(viz::OpenLoopStrategyViz{<:Tuple{TrajectoryGamesBase.OpenLoopStrategy}})
    strategy = viz[1]

    points = Makie.@lift [Makie.Point2f(x[1:2]) for x in $strategy.xs]

    if isnothing(viz.line_attributes[])
        line_kwargs = (;)
    else
        line_kwargs = map(keys(viz.line_attributes[])) do key
            key => Makie.@lift($(viz.line_kwargs)[key])
        end |> NamedTuple
    end

    if isnothing(viz.scatter_attributes[])
        scatter_kwargs = (;)
    else
        scatter_kwargs = map(keys(viz.scatter_attributes[])) do key
            key => Makie.@lift($(viz.scatter_kwargs)[key])
        end |> NamedTuple
    end

    Makie.lines!(viz, points; line_kwargs...)
    Makie.scatter!(viz, points; scatter_kwargs...)
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
