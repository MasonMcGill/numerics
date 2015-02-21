#===============================================================================
# Definitions

type Boxed[Grid: InputGrid|OutputGrid, metaIndices: static[seq[int]]] = object
  ## [doc]
  base: Grid
  when Grid is InputGrid:
    typeClassTag_InputGrid: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid: byte

proc box*(grid: InputGrid|OutputGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & @[-1] & toSeq(dim .. <grid.nDim)
  Boxed[type(grid), metaIndices](base: grid)

proc unbox*(grid: InputGrid|OutputGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & toSeq(dim + 1 .. <grid.nDim)
  Boxed[type(grid), metaIndices](base: grid)

proc size*[G, m](grid: Boxed[G, m]): auto =
  ## [doc]
  const m1 = m
  var result {.noInit.}: array[m.len, int]
  forStatic dim, 0 .. <m1.len:
    result[dim] = when m1[dim] != -1: grid.base.size[m1[dim]] else: 1
  result

proc get*[G, m](grid: Boxed[G, m], indices: array): auto =
  ## [doc]
  static: assert grid is InputGrid
  const m1 = m
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    adjustedIndices[dim] = when dim in m: indices[m1.find(dim)] else: 0
  grid.base.get(adjustedIndices)

proc put*[G, m](grid: Boxed[G, m], indices: array, value: any) =
  ## [doc]
  static: assert grid is OutputGrid
  const m1 = m
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    adjustedIndices[dim] = when dim in m: indices[m1.find(dim)] else: 0
  grid.base.put(adjustedIndices, value)

proc view*[G, m](grid: Boxed[G, m], slices: array): auto =
  ## [doc]
  const m1 = m
  var adjustedSlices {.noInit.}: array[grid.base.nDim, StridedSlice[int]]
  forStatic dim, 0 .. <adjustedSlices.len:
    adjustedSlices[dim] = when dim in m: slices[m1.find(dim)] else: (0..0).by(1)
  let baseView = grid.base.view(adjustedSlices)
  Boxed[type(baseView), m1](base: baseView)

proc box*[G, m](grid: Boxed[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 =
    when dim == 0: @[-1] & m
    else: m[0 .. <dim] & @[-1] & m[dim .. <m.len]
  Boxed[G, m1](base: grid.base)

proc unbox*[G, m](grid: Boxed[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 =
    when dim == 0: m[1 .. <m.len]
    else: m[0 .. <dim] & m[dim + 1 .. <m.len]
  Boxed[G, m1](base: grid.base)

#===============================================================================
# Tests

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
