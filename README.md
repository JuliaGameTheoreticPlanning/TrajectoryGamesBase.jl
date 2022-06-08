# TrajectoryGamesBase

[![CI](https://github.com/lassepe/TrajectoryGamesBase.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/lassepe/TrajectoryGamesBase.jl/actions/workflows/ci.yml)

A package that contains the problem interface and related types for trajectory games. That is, games that are played over continuous action spaces. This package considers only *discrete-time* problems; not differential games!

Note that this package does not contain any solver code. It merely serves as abstraction to share the same problem between different solvers.
