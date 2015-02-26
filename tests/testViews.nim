import unittest
import numerics

type TestInputGrid2D = object
  size: array[2, int]
  typeClassTag_InputGrid: byte

proc newTestInputGrid2D(size0, size1: int): TestInputGrid2D =
  TestInputGrid2D(size: [size0, size1])

proc get(grid: TestInputGrid2D, indices: array[2, int]): string =
  $indices[0] & "," & $indices[1]

type TestOutputGrid2D = object
  size: array[2, int]
  record: ref seq[string]
  typeClassTag_OutputGrid: byte

proc newTestOutputGrid2D(size0, size1: int): TestOutputGrid2D =
  result.size = [size0, size1]
  result.record = new(seq[string])
  result.record[] = newSeq[string]()

proc put(grid: TestOutputGrid2D, indices: array[2, int], value: int) =
  grid.record[].add($indices[0] & "," & $indices[1] & " -> " & $value)

test "inputGrid.view(slices)":
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..0).by(1), (0..2).by(2)])
    check grid.size == [0, 2]
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..2).by(1), (1..0).by(1)])
    check grid.size == [2, 0]
  block:
    let grid = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..2).by(2)])
    check grid.size == [2, 2]
    check grid.get([0, 0]) == "1,0"
    check grid.get([0, 1]) == "1,2"
    check grid.get([1, 0]) == "2,0"
    check grid.get([1, 1]) == "2,2"

test "outputGrid.view(slices)":
  block:
    let grid = newTestOutputGrid2D(3, 4).view([(1..0).by(1), (0..2).by(2)])
    check grid.size == [0, 2]
  block:
    let grid = newTestOutputGrid2D(3, 4).view([(1..2).by(1), (1..0).by(1)])
    check grid.size == [2, 0]
  block:
    let grid0 = newTestOutputGrid2D(3, 4)
    let grid1 = grid0.view([(1..2).by(1), (0..2).by(2)])
    grid1.put([0, 0], 4)
    grid1.put([0, 1], 5)
    grid1.put([1, 0], 6)
    grid1.put([1, 1], 7)
    check grid1.size == [2, 2]
    check grid0.record[].len == 4
    check "1,0 -> 4" in grid0.record[]
    check "1,2 -> 5" in grid0.record[]
    check "2,0 -> 6" in grid0.record[]
    check "2,2 -> 7" in grid0.record[]

test "gridView.view(slices)":
  let grid0 = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..3).by(1)])
  let grid1 = grid0.view([(0..1).by(1), (1..3).by(2)])
  check grid1.size == [2, 2]
  check grid1.get([0, 0]) == "1,1"
  check grid1.get([0, 1]) == "1,3"
  check grid1.get([1, 0]) == "2,1"
  check grid1.get([1, 1]) == "2,3"
