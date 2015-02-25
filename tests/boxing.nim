import numerics
import testing

test "inputGrid.box(dim)":
  block:
    let grid = newTestInputGrid2D(2, 2).box(0)
    assert grid.size == [1, 2, 2]
    assert grid.get([0, 0, 0]) == "0,0"
    assert grid.get([0, 0, 1]) == "0,1"
    assert grid.get([0, 1, 0]) == "1,0"
    assert grid.get([0, 1, 1]) == "1,1"
  block:
    let grid = newTestInputGrid2D(2, 2).box(1)
    assert grid.size == [2, 1, 2]
    assert grid.get([0, 0, 0]) == "0,0"
    assert grid.get([0, 0, 1]) == "0,1"
    assert grid.get([1, 0, 0]) == "1,0"
    assert grid.get([1, 0, 1]) == "1,1"

test "outputGrid.box(dim)":
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.box(0)
    grid1.put([0, 0, 0], 5)
    grid1.put([0, 0, 1], 6)
    grid1.put([0, 1, 0], 7)
    grid1.put([0, 1, 1], 8)
    assert grid0.record[].len == 4
    assert "0,0 -> 5" in grid0.record[]
    assert "0,1 -> 6" in grid0.record[]
    assert "1,0 -> 7" in grid0.record[]
    assert "1,1 -> 8" in grid0.record[]
    assert grid1.size == [1, 2, 2]
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.box(1)
    grid1.put([0, 0, 0], 5)
    grid1.put([0, 0, 1], 6)
    grid1.put([1, 0, 0], 7)
    grid1.put([1, 0, 1], 8)
    assert grid0.record[].len == 4
    assert "0,0 -> 5" in grid0.record[]
    assert "0,1 -> 6" in grid0.record[]
    assert "1,0 -> 7" in grid0.record[]
    assert "1,1 -> 8" in grid0.record[]
    assert grid1.size == [2, 1, 2]

test "inputGrid.unbox(dim)":
  block:
    let grid = newTestInputGrid2D(2, 2).unbox(0)
    assert grid.size == [2]
    assert grid.get([0]) == "0,0"
    assert grid.get([1]) == "0,1"
  block:
    let grid = newTestInputGrid2D(2, 2).unbox(1)
    assert grid.size == [2]
    assert grid.get([0]) == "0,0"
    assert grid.get([1]) == "1,0"

test "inputGrid.unbox(dim)":
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.unbox(0)
    grid1.put([0], 5)
    grid1.put([1], 6)
    assert grid0.record[].len == 2
    assert "0,0 -> 5" in grid0.record[]
    assert "0,1 -> 6" in grid0.record[]
    assert grid1.size == [2]
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.unbox(1)
    grid1.put([0], 5)
    grid1.put([1], 6)
    assert grid0.record[].len == 2
    assert "0,0 -> 5" in grid0.record[]
    assert "1,0 -> 6" in grid0.record[]
    assert grid1.size == [2]

test "boxedGrid.view(slices)":
  block:
    let grid0 = newTestInputGrid2D(2, 3).box(0)
    let grid1 = grid0.view([(0..0).by(1), (1..1).by(1), (0..2).by(2)])
    assert grid1.size == [1, 1, 2]
    assert grid1.get([0, 0, 0]) == "1,0"
    assert grid1.get([0, 0, 1]) == "1,2"
  block:
    let grid0 = newTestInputGrid2D(2, 3).box(2)
    let grid1 = grid0.view([(1..1).by(1), (0..2).by(2), (0..0).by(1)])
    assert grid1.size == [1, 2, 1]
    assert grid1.get([0, 0, 0]) == "1,0"
    assert grid1.get([0, 1, 0]) == "1,2"
  block:
    let grid0 = newTestInputGrid2D(2, 3).unbox(0)
    let grid1 = grid0.view([(0..2).by(2)])
    assert grid1.size == [2]
    assert grid1.get([0]) == "0,0"
    assert grid1.get([1]) == "0,2"

test "boxedGrid.box(dim)":
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(0)
    let grid1 = grid0.box(0)
    assert grid1.size == [1, 1, 2, 2]
    assert grid1.get([0, 0, 0, 0]) == "0,0"
    assert grid1.get([0, 0, 0, 1]) == "0,1"
    assert grid1.get([0, 0, 1, 0]) == "1,0"
    assert grid1.get([0, 0, 1, 1]) == "1,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(1)
    let grid1 = grid0.box(2)
    assert grid1.size == [2, 1, 1, 2]
    assert grid1.get([0, 0, 0, 0]) == "0,0"
    assert grid1.get([0, 0, 0, 1]) == "0,1"
    assert grid1.get([1, 0, 0, 0]) == "1,0"
    assert grid1.get([1, 0, 0, 1]) == "1,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).unbox(0)
    let grid1 = grid0.box(0)
    assert grid1.size == [1, 2]
    assert grid1.get([0, 0]) == "0,0"
    assert grid1.get([0, 1]) == "0,1"

test "boxedGrid.unbox(dim)":
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(0)
    let grid1 = grid0.unbox(1)
    assert grid1.size == [1, 2]
    assert grid1.get([0, 0]) == "0,0"
    assert grid1.get([0, 1]) == "0,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(1)
    let grid1 = grid0.unbox(2)
    assert grid1.size == [2, 1]
    assert grid1.get([0, 0]) == "0,0"
    assert grid1.get([1, 0]) == "1,0"
  block:
    let grid0 = newTestInputGrid2D(2, 2).unbox(0)
    let grid1 = grid0.unbox(0)
    assert grid1.size == emptyIntArray
    assert grid1.get(emptyIntArray) == "0,0"
