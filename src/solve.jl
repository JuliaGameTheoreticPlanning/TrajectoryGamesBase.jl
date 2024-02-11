"""
    solve_trajectory_game!(solver, game, initial_state; context, kwargs...)

Computes a joint strategy `γ` for all players for the given `game` for game-play starting at
`initial_state`. This call may modify the `solver` itself; e.g., due to learning of parameters,
updates of initial guesses, or advancing RNG states. That is, a subsequent call of
`solve_trajectory_game!` on the *same* `initial_state` may result in a *different* strategy.
"""
function solve_trajectory_game! end
