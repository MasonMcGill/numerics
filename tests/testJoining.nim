import unittest
import numerics

test "grids.join()":
  block:
    let g0 = @@[0.0]
    let g1 = @@[1.0, 2.0]
    let g2 = @@[3.0, 4.0]
    let g3 = @@[g0, g1, g2]
    assert g3.join() == @@[0.0, 1.0, 2.0, 3.0, 4.0]
  block:
    let g0 = @@[[0, 1]]
    let g1 = @@[[2, 3], [4, 5]]
    let g2 = @@[g0, g1]
    assert g2.join() == @@[[0, 1], [2, 3], [4, 5]]
  block:
    let g0 = @@[[0, 1]]
    let g1 = @@[[2, 3]]
    let g2 = @@[[4, 5]]
    let g3 = @@[[6, 7]]
    let g4 = @@[[g0, g1], [g2, g3]]
    assert g4.join() == @@[[0, 1, 2, 3], [4, 5, 6, 7]]

test "grid0 & grid1":
  assert(@@[0, 1] & @@[2, 3, 4] == @@[0, 1, 2, 3, 4])
  assert(@@[[0], [1]] & @@[[2]] == @@[[0], [1], [2]])
  assert(@@[[0, 1]] & @@[[2, 3]] == @@[[0, 1], [2, 3]])

test "grid.collect()":
  assert((0 .. 3).collect() == @@[0, 1, 2, 3])
  assert(newDenseGrid(int).collect() == newDenseGrid(int))
  assert(@@[[0, 1], [2, 3]].collect() == @@[[0, 1], [2, 3]])
