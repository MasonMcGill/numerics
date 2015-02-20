#===============================================================================
# Definitions

type View*[Grid: InputGrid|OutputGrid] = object
  ## [doc]
  base: Grid
  slices: array[maxNDim, StridedSlice[int]]
  when Grid is InputGrid:
    typeClassTag_InputGrid: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid: byte

proc view*(grid: InputGrid|OutputGrid, slices: array): auto =
  ## [doc]
  static: assert grid.nDim <= maxNDim
  static: assert grid.nDim == slices.len
  result = View[type(grid)](base: grid)
  result.slices[0 .. <slices.len] = slices

proc size*[G](grid: View[G]): auto =
  ## [doc]
  var result {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <result.len:
    result[dim] = grid.slices[dim].len
  result

proc get*[G](grid: View[G], indices: array): auto =
  ## [doc]
  static: assert grid is InputGrid
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    let slice = grid.slices[dim]
    adjustedIndices[dim] = slice.first + slice.stride * indices[dim]
  grid.base.get(adjustedIndices)

proc put*[G](grid: View[G], indices: array, value: any) =
  ## [doc]
  static: assert grid is OutputGrid
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    let slice = grid.slices[dim]
    adjustedIndices[dim] = slice.first + slice.stride * indices[dim]
  grid.base.put(adjustedIndices, value)

proc view*[G](grid: View[G], slices: array): auto =
  ## [doc]
  result = grid
  forStatic dim, 0 .. <grid.base.nDim:
    let slice0 = grid.slices[dim]
    let slice1 = slices[dim]
    result.slices[dim].first = slice0.first + slice1.first * slice0.stride
    result.slices[dim].last = slice0.first + slice1.last * slice0.stride
    result.slices[dim].stride = slice0.stride * slice1.stride

proc box*[G](grid: View[G], dim: static[int]): auto =
  ## [doc]
  static: assert dim >= 0 and dim < grid.base.nDim
  static: assert grid.base.nDim < maxNDim
  const gridNDim = grid.base.nDim
  let boxedBase = grid.base.box(dim)
  result = View[type(boxedBase)](base: boxedBase)
  result.slices[0 .. <dim] = grid.slices[0 .. <dim]
  result.slices[dim] = (0..0).by(1)
  result.slices[dim + 1 .. gridNDim] = grid.slices[dim .. <gridNDim]

proc unbox*[G](grid: View[G], dim: static[int]): auto =
  ## [doc]
  static: assert dim >= 0 and dim < grid.base.nDim
  const gridNDim = grid.base.nDim
  let unboxedBase = grid.base.unbox(dim)
  result = View[type(unboxedBase)](base: unboxedBase)
  result.slices[0 .. <dim] = grid.slices[0 .. <dim]
  result.slices[dim .. <gridNDim - 1] = grid.slices[dim + 1 .. <gridNDim]

#===============================================================================
# Tests

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
    assert grid.get([0, 0]) == ["1", "0"]
    assert grid.get([0, 1]) == ["1", "2"]
    assert grid.get([1, 0]) == ["2", "0"]
    assert grid.get([1, 1]) == ["2", "2"]

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
    assert "[1, 0]: 4" in grid0.record[]
    assert "[1, 2]: 5" in grid0.record[]
    assert "[2, 0]: 6" in grid0.record[]
    assert "[2, 2]: 7" in grid0.record[]

test "gridView.view(slices)":
  let grid0 = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..3).by(1)])
  let grid1 = grid0.view([(0..1).by(1), (1..3).by(2)])
  assert grid1.size == [2, 2]
  assert grid1.get([0, 0]) == ["1", "1"]
  assert grid1.get([0, 1]) == ["1", "3"]
  assert grid1.get([1, 0]) == ["2", "1"]
  assert grid1.get([1, 1]) == ["2", "3"]

test "gridView.box(dim)":
  proc box(grid: TestInputGrid2D, dim: static[int]): auto =
    newDenseGrid(int, 3, 1, 4)
  let grid0 = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..3).by(1)])
  let grid1 = grid0.box(1)
  assert grid1.size == [2, 1, 4]

test "gridView.unbox(dim)":
  proc unbox(grid: TestInputGrid2D, dim: static[int]): auto =
    newDenseGrid(int, 3)
  let grid0 = newTestInputGrid2D(3, 4).view([(1..2).by(1), (0..3).by(1)])
  let grid1 = grid0.unbox(1)
  assert grid1.size == [2]
