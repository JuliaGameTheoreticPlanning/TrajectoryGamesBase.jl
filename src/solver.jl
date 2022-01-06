"""
    solve_trajectory_game!(solver, game, state)

Computes a collection of strategies `γs`, one for each player of the game. This call may modify \
the `solver` itself; e.g., due to learning of parameters or updates of initial guesses for \
repeated calls. That is, a subsequent call of `solve_trajectory_game!` on the same `state` \
may result in a different strategy.
"""
function solve_trajectory_game! end
