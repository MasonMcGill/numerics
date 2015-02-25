import abstractGrids

template fold*(grid: InputGrid, pred, init: expr, dim: static[int]): expr =
  discard

template fold*(grid: InputGrid, pred, init: expr): expr =
  discard
