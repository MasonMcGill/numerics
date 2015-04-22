import unittest
import numerics

test "indices(size)":
  block:
    var i = 0
    var g = indices([3])
    check g.size == [3]
    for e in g:
      check e == [i]
      i += 1
    check i == 3
  block:
    var i = 0
    var g = indices([2, 2])
    check g.size == [2, 2]
    for e in g:
      check e == [i div 2, i mod 2]
      i += 1
    check i == 4

test "indices(grid)":
  block:
    var i = 0
    var g = indices(@@["0", "1", "2"])
    check g.size == [3]
    for e in g:
      check e == [i]
      i += 1
    check i == 3
  block:
    var i = 0
    var g = indices(@@[["0", "1"], ["2", "3"]])
    check g.size == [2, 2]
    for e in g:
      check e == [i div 2, i mod 2]
      i += 1
    check i == 4
