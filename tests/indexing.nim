import numerics
import testing

test "inputGrid[]":
  let grid = newTestInputGrid2D(2, 2)[]
  assert grid.size == [2, 2]
  assert grid.get([0, 0]) == "0,0"
  assert grid.get([0, 1]) == "0,1"
  assert grid.get([1, 0]) == "1,0"
  assert grid.get([1, 1]) == "1,1"

test "inputGrid[index0]":
  block:
    let grid = newTestInputGrid2D(3, 2)[2]
    assert grid.size == [2]
    assert grid.get([0]) == "2,0"
    assert grid.get([1]) == "2,1"
  block:
    let grid = newTestInputGrid2D(3, 2)[1..0]
    assert grid.size == [0, 2]

test "grid[index0, index1]":
  block:
    let element = newTestInputGrid2D(3, 4)[2, 0]
    assert element == "2,0"
  block:
    let view = newTestInputGrid2D(3, 4)[1..2, 2]
    assert view.size == [2]
    assert view.get([0]) == "1,2"
    assert view.get([1]) == "2,2"
  block:
    let view = newTestInputGrid2D(3, 4)[0..2, 1..2]
    assert view.size == [3, 2]
    assert view.get([0, 0]) == "0,1"
    assert view.get([0, 1]) == "0,2"
    assert view.get([1, 0]) == "1,1"
    assert view.get([1, 1]) == "1,2"
    assert view.get([2, 0]) == "2,1"
    assert view.get([2, 1]) == "2,2"

test "grid[index0, index1, index2]":
  block:
    let element = newTestInputGrid3D(2, 1, 1)[1, 0, 0]
    assert element == "1,0,0"
  block:
    let view = newTestInputGrid3D(2, 1, 1)[1, 0, 0..0]
    assert view.size == [1]
    assert view.get([0]) == "1,0,0"
  block:
    let view = newTestInputGrid3D(2, 1, 1)[0..1, 0, 0]
    assert view.size == [2]
    assert view.get([0]) == "0,0,0"
    assert view.get([1]) == "1,0,0"
  block:
    let view = newTestInputGrid3D(2, 1, 1)[1..1, 0..(-1), 0]
    assert view.size == [1, 0]
  block:
    let view = newTestInputGrid3D(2, 1, 1)[0..1, 0..0, 0..0]
    assert view.size == [2, 1, 1]
    assert view.get([0, 0, 0]) == "0,0,0"
    assert view.get([1, 0, 0]) == "1,0,0"

test "grid[index0][index1, index2]":
  block:
    let element = newTestInputGrid3D(2, 1, 1)[1][0, 0]
    assert element == "1,0,0"
  block:
    let view = newTestInputGrid3D(2, 1, 1)[1][0, 0..0]
    assert view.size == [1]
    assert view.get([0]) == "1,0,0"

test "grid[index0][index1, index2, index3]":
  block:
    let view = newTestInputGrid3D(2, 1, 1)[0..1][0..1, 0, 0]
    assert view.size == [2]
    assert view.get([0]) == "0,0,0"
    assert view.get([1]) == "1,0,0"
  block:
    let view = newTestInputGrid3D(2, 1, 1)[1..1][0..0, 0..(-1), 0]
    assert view.size == [1, 0]
  block:
    let view = newTestInputGrid3D(2, 1, 1)[0..1][0..1, 0..0, 0..0]
    assert view.size == [2, 1, 1]
    assert view.get([0, 0, 0]) == "0,0,0"
    assert view.get([1, 0, 0]) == "1,0,0"

test "grid[indices]":
  block:
    let element = newTestInputGrid2D(3, 4)[(2, 0)]
    assert element == "2,0"
  block:
    let view = newTestInputGrid2D(3, 4)[(1..2, 2)]
    assert view.size == [2]
    assert view.get([(field0: 0)]) == "1,2"
    assert view.get([(field0: 1)]) == "2,2"
  block:
    let view = newTestInputGrid2D(3, 4)[0..2, 1..2]
    assert view.size == [3, 2]
    assert view.get([(0, 0)]) == "0,1"
    assert view.get([(0, 1)]) == "0,2"
    assert view.get([(1, 0)]) == "1,1"
    assert view.get([(1, 1)]) == "1,2"
    assert view.get([(2, 0)]) == "2,1"
    assert view.get([(2, 1)]) == "2,2"

test "grid[] = value":
    let grid = newTestOutputGrid2D(3, 2)
    grid[] = 5
    assert grid.record[].len == 6
    assert "0,0 -> 5" in grid.record[]
    assert "0,1 -> 5" in grid.record[]
    assert "1,0 -> 5" in grid.record[]
    assert "1,1 -> 5" in grid.record[]
    assert "2,0 -> 5" in grid.record[]
    assert "2,1 -> 5" in grid.record[]

test "grid[index0] = value":
  let grid = newTestOutputGrid2D(3, 4)
  grid[2] = 5
  assert grid.record[].len == 4
  assert "2,0 -> 5" in grid.record[]
  assert "2,1 -> 5" in grid.record[]
  assert "2,2 -> 5" in grid.record[]
  assert "2,3 -> 5" in grid.record[]

test "grid[index0, index1] = value":
  let grid = newTestOutputGrid2D(3, 4)
  grid[1..2, 0] = @@[5, 6]
  assert grid.record[].len == 2
  assert "1,0 -> 5" in grid.record[]
  assert "2,0 -> 6" in grid.record[]

test "grid[index0, index1, index2] = value":
  let grid = newTestOutputGrid3D(2, 1, 1)
  grid[0..0, 0, 0] = 5
  assert grid.record[].len == 1
  assert "0,0,0 -> 5" in grid.record[]

test "grid[indices] = value":
  let grid = newTestOutputGrid2D(3, 4)
  grid[(1..2, 0..2)] = @@[5, 6]
  assert grid.record[].len == 6
  assert "1,0 -> 5" in grid.record[]
  assert "2,0 -> 6" in grid.record[]
  assert "1,1 -> 5" in grid.record[]
  assert "2,1 -> 6" in grid.record[]
  assert "1,2 -> 5" in grid.record[]
  assert "2,2 -> 6" in grid.record[]
