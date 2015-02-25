import numerics
import testing

test "inputGrid.view(slices)":
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..0).by(1), (0..2).by(2)])
    assert grid.size == [0, 2]
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..2).by(1), (1..0).by(1)])
    assert grid.size == [2, 0]
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..2).by(2)])
    assert grid.size == [2, 2]
    assert grid.get([0, 0]) == "1,0"
    assert grid.get([0, 1]) == "1,2"
    assert grid.get([1, 0]) == "2,0"
    assert grid.get([1, 1]) == "2,2"

test "outputGrid.view(slices)":
  block:
    let grid = newTestOutputGrid2D(3, 4).view([(1..0).by(1), (0..2).by(2)])
    assert grid.size == [0, 2]
  block:
    let grid = newTestOutputGrid2D(3, 4).view([(1..2).by(1), (1..0).by(1)])
    assert grid.size == [2, 0]
  block:
    let grid0 = newTestOutputGrid2D(3, 4)
    let grid1 = grid0.view([(1..2).by(1), (0..2).by(2)])
    grid1.put([0, 0], 4)
    grid1.put([0, 1], 5)
    grid1.put([1, 0], 6)
    grid1.put([1, 1], 7)
    assert grid1.size == [2, 2]
    assert grid0.record[].len == 4
    assert "1,0 -> 4" in grid0.record[]
    assert "1,2 -> 5" in grid0.record[]
    assert "2,0 -> 6" in grid0.record[]
    assert "2,2 -> 7" in grid0.record[]

test "gridView.view(slices)":
  let grid0 = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..3).by(1)])
  let grid1 = grid0.view([(0..1).by(1), (1..3).by(2)])
  assert grid1.size == [2, 2]
  assert grid1.get([0, 0]) == "1,1"
  assert grid1.get([0, 1]) == "1,3"
  assert grid1.get([1, 0]) == "2,1"
  assert grid1.get([1, 1]) == "2,3"
