import unittest
import numerics

test "zip(grid0)":
  check zip(@@[0, 1]) == @@[(field0: 0), (field0: 1)]
  check zip(@@[[0], [1]]) == @@[[(field0: 0)], [(field0: 1)]]

test "zip(grid0, grid1)":
  check zip(@@[0, 1], @@[2, 3]) == @@[(0, 2), (1, 3)]
  check zip(@@[[0], [1]], @@[[2], [3]]) == @@[[(0, 2)], [(1, 3)]]
  check zip(@@[[0], [1]], @@2) == @@[[(0, 2)], [(1, 2)]]
  check zip(@@[[0], [1]], @@[2]) == @@[[(0, 2)], [(1, 2)]]
  check zip(@@[[0], [1]], @@[[2]]) == @@[[(0, 2)], [(1, 2)]]

test "zip(grid0, grid1, grid2)":
  check zip(@@[0], @@[1], @@[2]) == @@[(0, 1, 2)]
  check zip(@@[[0, 1]], @@2, @@3) == @@[[(0, 2, 3), (1, 2, 3)]]

test "zip(grid0, grid1).view(slices)":
  block:
    let grid = zip(@@[[0], [1]], @@[[2], [3]])
    let slices = [(1..1).by(1), (0..0).by(1)]
    let gridView = @@[[(1, 3)]]
    check grid.view(slices) == gridView
  block:
    let grid = zip(@@[[0], [1]], @@2)
    let slices = [(0..1).by(1), (0..0).by(1)]
    let gridView = @@[[(0, 2)], [(1, 2)]]
    check grid.view(slices) == gridView

test "zip(grid0, grid1).box(dim)":
  check zip(@@[0, 1], @@[2, 3]).box(0) == @@[[(0, 2), (1, 3)]]
  check zip(@@[0, 1], @@[2, 3]).box(1) == @@[[(0, 2)], [(1, 3)]]
  check zip(@@[[0], [1]], @@2).box(0) == @@[[[(0, 2)], [(1, 2)]]]
  check zip(@@[[0], [1]], @@2).box(2) == @@[[[(0, 2)]], [[(1, 2)]]]

test "zip(grid0, grid1).unbox(dim)":
  check zip(@@[0, 1], @@[2, 3]).unbox(0) == @@(0, 2)
  check zip(@@[[0], [1]], @@[2]).unbox(0) == @@[(0, 2)]
  check zip(@@[[0], [1]], @@[2]).unbox(1) == @@[(0, 2), (1, 2)]
