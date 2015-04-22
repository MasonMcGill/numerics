import unittest
import numerics

test "grid.indices":
  block:
    var i = 0
    for e in @@["0", "1", "2"].indices:
      check e == [i]
      i += 1
    check i == 3
  block:
    var i = 0
    for e in @@[["0", "1"], ["2", "3"]].indices:
      check e == [i div 2, i mod 2]
      i += 1
    check i == 4
