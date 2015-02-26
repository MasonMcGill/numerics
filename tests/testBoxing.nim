import unittest
import numerics

const emptyIntArray = (block: (var x: array[0, int]; x))

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

test "inputGrid.box(dim)":
  block:
    let grid = newTestInputGrid2D(2, 2).box(0)
    check grid.size == [1, 2, 2]
    check grid.get([0, 0, 0]) == "0,0"
    check grid.get([0, 0, 1]) == "0,1"
    check grid.get([0, 1, 0]) == "1,0"
    check grid.get([0, 1, 1]) == "1,1"
  block:
    let grid = newTestInputGrid2D(2, 2).box(1)
    check grid.size == [2, 1, 2]
    check grid.get([0, 0, 0]) == "0,0"
    check grid.get([0, 0, 1]) == "0,1"
    check grid.get([1, 0, 0]) == "1,0"
    check grid.get([1, 0, 1]) == "1,1"

test "outputGrid.box(dim)":
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.box(0)
    grid1.put([0, 0, 0], 5)
    grid1.put([0, 0, 1], 6)
    grid1.put([0, 1, 0], 7)
    grid1.put([0, 1, 1], 8)
    check grid0.record[].len == 4
    check "0,0 -> 5" in grid0.record[]
    check "0,1 -> 6" in grid0.record[]
    check "1,0 -> 7" in grid0.record[]
    check "1,1 -> 8" in grid0.record[]
    check grid1.size == [1, 2, 2]
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.box(1)
    grid1.put([0, 0, 0], 5)
    grid1.put([0, 0, 1], 6)
    grid1.put([1, 0, 0], 7)
    grid1.put([1, 0, 1], 8)
    check grid0.record[].len == 4
    check "0,0 -> 5" in grid0.record[]
    check "0,1 -> 6" in grid0.record[]
    check "1,0 -> 7" in grid0.record[]
    check "1,1 -> 8" in grid0.record[]
    check grid1.size == [2, 1, 2]

test "inputGrid.unbox(dim)":
  block:
    let grid = newTestInputGrid2D(2, 2).unbox(0)
    check grid.size == [2]
    check grid.get([0]) == "0,0"
    check grid.get([1]) == "0,1"
  block:
    let grid = newTestInputGrid2D(2, 2).unbox(1)
    check grid.size == [2]
    check grid.get([0]) == "0,0"
    check grid.get([1]) == "1,0"

test "inputGrid.unbox(dim)":
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.unbox(0)
    grid1.put([0], 5)
    grid1.put([1], 6)
    check grid0.record[].len == 2
    check "0,0 -> 5" in grid0.record[]
    check "0,1 -> 6" in grid0.record[]
    check grid1.size == [2]
  block:
    let grid0 = newTestOutputGrid2D(2, 2)
    let grid1 = grid0.unbox(1)
    grid1.put([0], 5)
    grid1.put([1], 6)
    check grid0.record[].len == 2
    check "0,0 -> 5" in grid0.record[]
    check "1,0 -> 6" in grid0.record[]
    check grid1.size == [2]

test "boxedGrid.view(slices)":
  block:
    let grid0 = newTestInputGrid2D(2, 3).box(0)
    let grid1 = grid0.view([(0..0).by(1), (1..1).by(1), (0..2).by(2)])
    check grid1.size == [1, 1, 2]
    check grid1.get([0, 0, 0]) == "1,0"
    check grid1.get([0, 0, 1]) == "1,2"
  block:
    let grid0 = newTestInputGrid2D(2, 3).box(2)
    let grid1 = grid0.view([(1..1).by(1), (0..2).by(2), (0..0).by(1)])
    check grid1.size == [1, 2, 1]
    check grid1.get([0, 0, 0]) == "1,0"
    check grid1.get([0, 1, 0]) == "1,2"
  block:
    let grid0 = newTestInputGrid2D(2, 3).unbox(0)
    let grid1 = grid0.view([(0..2).by(2)])
    check grid1.size == [2]
    check grid1.get([0]) == "0,0"
    check grid1.get([1]) == "0,2"

test "boxedGrid.box(dim)":
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(0)
    let grid1 = grid0.box(0)
    check grid1.size == [1, 1, 2, 2]
    check grid1.get([0, 0, 0, 0]) == "0,0"
    check grid1.get([0, 0, 0, 1]) == "0,1"
    check grid1.get([0, 0, 1, 0]) == "1,0"
    check grid1.get([0, 0, 1, 1]) == "1,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(1)
    let grid1 = grid0.box(2)
    check grid1.size == [2, 1, 1, 2]
    check grid1.get([0, 0, 0, 0]) == "0,0"
    check grid1.get([0, 0, 0, 1]) == "0,1"
    check grid1.get([1, 0, 0, 0]) == "1,0"
    check grid1.get([1, 0, 0, 1]) == "1,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).unbox(0)
    let grid1 = grid0.box(0)
    check grid1.size == [1, 2]
    check grid1.get([0, 0]) == "0,0"
    check grid1.get([0, 1]) == "0,1"

test "boxedGrid.unbox(dim)":
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(0)
    let grid1 = grid0.unbox(1)
    check grid1.size == [1, 2]
    check grid1.get([0, 0]) == "0,0"
    check grid1.get([0, 1]) == "0,1"
  block:
    let grid0 = newTestInputGrid2D(2, 2).box(1)
    let grid1 = grid0.unbox(2)
    check grid1.size == [2, 1]
    check grid1.get([0, 0]) == "0,0"
    check grid1.get([1, 0]) == "1,0"
  block:
    let grid0 = newTestInputGrid2D(2, 2).unbox(0)
    let grid1 = grid0.unbox(0)
    check grid1.size == emptyIntArray
    check grid1.get(emptyIntArray) == "0,0"
