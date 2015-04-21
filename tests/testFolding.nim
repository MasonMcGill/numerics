import unittest
import numerics

test "grid.fold(op, init, dim)":
  block:
    let grid = newDenseGrid(int, 0).fold(`+`, 0, 0)
    assert grid[] == 0
  block:
    let grid = @@[0, 1, 2].fold(`+`, 0, 0)
    assert grid[] == 3
  block:
    let grid = @@[[0, 1], [2, 3]].fold(`+`, 0, 0)
    assert grid == @@[2, 4]
  block:
    let grid = @@[[0, 1], [2, 3]].fold(`+`, 0, 1)
    assert grid == @@[1, 5]

test "grid.fold(op, init)":
  assert((@@7).fold(`*`, 1) == 7)
  assert((@@[1, 2, 3]).fold(`*`, 1) == 6)
  assert((@@[[1, 2], [3, 4]]).fold(`*`, 1) == 24)
