import numerics
import testing

test "grid.indices":
  block:
    var i = 0
    for e in @@["0", "1", "2"].indices:
      assert e == [i]
      i += 1
    assert i == 3
  block:
    var i = 0
    for e in @@[["0", "1"], ["2", "3"]].indices:
      assert e == [i div 2, i mod 2]
      i += 1
    assert i == 4

test "grid.items":
  block:
    var i = 0
    for e in @@["0", "1", "2"]:
      assert e == $i
      i += 1
    assert i == 3
  block:
    var i = 0
    for e in @@[["0", "1"], ["2", "3"]]:
      assert e == $i
      i += 1
    assert i == 4

test "grid.pairs":
  block:
    var i = 0
    for j, e in @@["0", "1", "2"]:
      assert j == [i]
      assert e == $i
      i += 1
    assert i == 3
  block:
    var i = 0
    for j, e in @@[["0", "1"], ["2", "3"]]:
      assert j == [i div 2, i mod 2]
      assert e == $i
      i += 1
    assert i == 4

test "grid0 == grid1":
  assert(@@[0.0, 1.0, 2.0] == @@[0.0, 1.0, 2.0])
  assert(@@[0.0, 1.0, 2.0] != @@[0.0, 2.0, 4.0])
  assert(@@[[0, 1], [2, 3]] == @@[[0, 1], [2, 3]])
  assert(@@[[0, 1], [2, 3]] != @@[[2, 1], [2, 3]])
  assert(@@[[["0"]], [["1"]]] == @@[[["0"]], [["1"]]])
  assert(@@[[["0"]], [["1"]]] != @@[[["0"]], [["0"]]])

test "$grid":
  assert($newDenseGrid(int) == "0")
  assert($(@@[0.0, 1.0, 2.0]) == "[0.0, 1.0, 2.0]")
  assert($(@@[[0], [1], [2]]) == "[[0],\n [1],\n [2]]")
