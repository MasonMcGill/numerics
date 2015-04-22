import unittest
import numerics

test "sum(grid, dim)":
  check sum(@@[1, 2, 3], 0) == @@6
  check sum(@@[[1, 2, 3], [4, 5, 6]], 1) == @@[6, 15]
  check sum(@@[[1.0, 2.0], [3.0, 4.0]], 0) == @@[4.0, 6.0]

test "sum(grid)":
  check sum(@@[1, 2, 3]) == 6
  check sum(@@[[1, 2, 3], [4, 5, 6]]) == 21
  check sum(@@[[1.0, 2.0], [3.0, 4.0]]) == 10.0

test "product(grid, dim)":
  check product(@@[1, 2, 3], 0) == @@6
  check product(@@[[1, 2, 3], [4, 5, 6]], 1) == @@[6, 120]
  check product(@@[[1.0, 2.0], [3.0, 4.0]], 0) == @@[3.0, 8.0]

test "product(grid)":
  check product(@@[1, 2, 3]) == 6
  check product(@@[[1, 2, 3], [4, 5, 6]]) == 720
  check product(@@[[1.0, 2.0], [3.0, 4.0]]) == 24.0

test "min(grid, dim)":
  check min(@@[1, 2, 3], 0) == @@1
  check min(@@[[1, 2, 3], [4, 5, 6]], 1) == @@[1, 4]
  check min(@@[[1.0, 2.0], [3.0, 4.0]], 0) == @@[1.0, 2.0]

test "min(grid)":
  check min(@@[1, 2, 3]) == 1
  check min(@@[[1, 2, 3], [4, 5, 6]]) == 1
  check min(@@[[1.0, 2.0], [3.0, 4.0]]) == 1.0

test "max(grid, dim)":
  check max(@@[1, 2, 3], 0) == @@3
  check max(@@[[1, 2, 3], [4, 5, 6]], 1) == @@[3, 6]
  check max(@@[[1.0, 2.0], [3.0, 4.0]], 0) == @@[3.0, 4.0]

test "max(grid)":
  check max(@@[1, 2, 3]) == 3
  check max(@@[[1, 2, 3], [4, 5, 6]]) == 6
  check max(@@[[1.0, 2.0], [3.0, 4.0]]) == 4.0

# test "argmin(grid, dim)":
#   check argmin(@@[1, 2, 3], 0)[] == [0]
#   check argmin(@@[[1, 2, 3], [4, 5, 6]], 1)[0] == [0, 0]
#   check argmin(@@[[1, 2, 3], [4, 5, 6]], 1)[1] == [1, 0]
#   check argmin(@@[[1.0, 2.0], [3.0, 4.0]], 0)[0] == [0, 0]
#   check argmin(@@[[1.0, 2.0], [3.0, 4.0]], 0)[1] == [0, 1]

test "argmin(grid)":
  check argmin(@@[1, 2, 3]) == [0]
  check argmin(@@[[1, 2, 3], [4, 5, 6]]) == [0, 0]
  check argmin(@@[[1.0, 2.0], [3.0, 4.0]]) == [0, 0]

# test "argmax(grid, dim)":
#   check argmax(@@[1, 2, 3], 0)[] == [2]
#   check argmax(@@[[1, 2, 3], [4, 5, 6]], 1)[0] == [0, 2]
#   check argmax(@@[[1, 2, 3], [4, 5, 6]], 1)[1] == [1, 2]
#   check argmax(@@[[1.0, 2.0], [3.0, 4.0]], 0)[0] == [1, 0]
#   check argmax(@@[[1.0, 2.0], [3.0, 4.0]], 0)[1] == [1, 1]

test "argmax(grid)":
  check argmax(@@[1, 2, 3]) == [2]
  check argmax(@@[[1, 2, 3], [4, 5, 6]]) == [1, 2]
  check argmax(@@[[1.0, 2.0], [3.0, 4.0]]) == [1, 1]
