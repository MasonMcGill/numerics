
#===============================================================================
# Folding Grids

template fold*(grid: InputGrid, pred, init: expr, dim: static[int]): expr =
  discard

template fold*(grid: InputGrid, pred, init: expr): expr =
  discard

#===============================================================================
# Tests

# test "grid.fold(pred, init, dim)":
#   discard
#
# test "grid.fold(pred, init)":
#   discard
