import unittest
import numerics

test "grid.items":
  block:
    var i = 0
    for e in @@["0", "1", "2"]:
      check e == $i
      i += 1
    check i == 3
  block:
    var i = 0
    for e in @@[["0", "1"], ["2", "3"]]:
      check e == $i
      i += 1
    check i == 4

test "grid.pairs":
  block:
    var i = 0
    for j, e in @@["0", "1", "2"]:
      check j == [i]
      check e == $i
      i += 1
    check i == 3
  block:
    var i = 0
    for j, e in @@[["0", "1"], ["2", "3"]]:
      check j == [i div 2, i mod 2]
      check e == $i
      i += 1
    check i == 4

test "grid0 == grid1":
  check(@@[0.0, 1.0, 2.0] == @@[0.0, 1.0, 2.0])
  check(@@[0.0, 1.0, 2.0] != @@[0.0, 2.0, 4.0])
  check(@@[[0, 1], [2, 3]] == @@[[0, 1], [2, 3]])
  check(@@[[0, 1], [2, 3]] != @@[[2, 1], [2, 3]])
  check(@@[[["0"]], [["1"]]] == @@[[["0"]], [["1"]]])
  check(@@[[["0"]], [["1"]]] != @@[[["0"]], [["0"]]])

test "$grid":
  block:
    let grid = newDenseGrid(int)
    check($grid == "0")
  block:
    check($(@@[0.0, 1.0, 2.0]) == "[0.0, 1.0, 2.0]")
    check($(@@[[0], [1], [2]]) == "[[0],\n [1],\n [2]]")
