"""
    strategy(state, time)

Computes an `action` for the given `state` and `time`. Note that the `strategy` may be \
non-deterministic. Hence, unless it is seeded to the same pseudo-random state, it subsequent calls \
of `strategy` may yield different actions.
"""
abstract type AbstractStrategy end
