# TrajectoryGamesBase

[![CI](https://github.com/JuliaGameTheoreticPlanning/TrajectoryGamesBase.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaGameTheoreticPlanning/TrajectoryGamesBase.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaGameTheoreticPlanning/TrajectoryGamesBase.jl/branch/main/graph/badge.svg?token=BkJUwW6V1K)](https://codecov.io/gh/JuliaGameTheoreticPlanning/TrajectoryGamesBase.jl)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://opensource.org/licenses/MIT)

A package that contains the problem interface and related types for trajectory games. The trajectory games considered here are played over continuous action spaces in *discrete time*. That is, this package currently does not support differential games.

Note that this package does not contain any solver code. It merely serves as abstraction to share problem description and solvers.

## Eco-System

- [MCPTrajectoryGameSolver.jl](https://github.com/JuliaGameTheoreticPlanning/MCPTrajectoryGameSolver.jl): A solver for trajectory games by casting them as mixed complementarity problems. See that package for a complete usage demo of the `TrajectoryGamesBase` interface.
- [TrajectoryGamesExamples.jl](https://github.com/JuliaGameTheoreticPlanning/TrajectoryGamesExamples.jl): A package that provides examples of trajectory games and tools for modeling and visualization.
- [LiftedTrajectoryGames.jl](https://github.com/JuliaGameTheoreticPlanning/LiftedTrajectoryGames.jl): A package for learning mixed strategy solutions of trajectory games.

If you have a package that uses `TrajectoryGamesBase` and would like to have it listed here, please open an issue or a pull request.

## Usage

This README will be expanded to include more concrete usage instructions. Until then, please refer to the `test/runtests.jl` file as a source of implicit documentation as well as
[this demo](https://github.com/JuliaGameTheoreticPlanning/MCPTrajectoryGameSolver.jl/blob/main/test/Demo.jl) from [MCPTrajectoryGameSolver.jl](https://github.com/JuliaGameTheoreticPlanning/MCPTrajectoryGameSolver.jl).
