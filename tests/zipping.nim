import numerics
import testing

test "zip(grid0)":
  assert zip(@@[0, 1]).collect == @@[(field0: 0), (field0: 1)]
  assert zip(@@[[0], [1]]).collect == @@[[(field0: 0)], [(field0: 1)]]

test "zip(grid0, grid1)":
  assert zip(@@[0, 1], @@[2, 3]).collect == @@[(0, 2), (1, 3)]
  assert zip(@@[[0], [1]], @@[[2], [3]]).collect == @@[[(0, 2)], [(1, 3)]]
  assert zip(@@[[0], [1]], @@2).collect == @@[[(0, 2)], [(1, 2)]]
  assert zip(@@[[0], [1]], @@[2]).collect == @@[[(0, 2)], [(1, 2)]]
  assert zip(@@[[0], [1]], @@[[2]]).collect == @@[[(0, 2)], [(1, 2)]]

test "zip(grid0, grid1, grid2)":
  assert zip(@@[0], @@[1], @@[2]).collect == @@[(0, 1, 2)]
  assert zip(@@[[0, 1]], @@2, @@3).collect == @@[[(0, 2, 3), (1, 2, 3)]]
