#===============================================================================
# Definitions

type View*[Grid: InputGrid|OutputGrid, metaIndices: static[seq[int]]] = object
  ## [doc]
  grid: Grid
  slices: array[maxNDim, StridedSlice[int]]
  when Grid is InputGrid:
    typeClassTag_InputGrid: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid: byte

proc view*(grid: InputGrid|OutputGrid, slices: array): auto =
  ## [doc]
  static: assert grid.nDim <= maxNDim
  static: assert grid.nDim == slices.len
  const metaIndices = toSeq(0 .. <grid.nDim)
  result = View[type(grid), metaIndices](grid: grid)
  result.slices[0 .. <slices.len] = slices

proc addDim*(grid: InputGrid|OutputGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & toSeq(dim + 1 .. grid.nDim)
  result = View[type(grid), metaIndices](grid: grid)
  for dim in 0 .. <grid.nDim:
    result.strides[dim] = 0 .. <grid.size[dim]

proc delDim*(grid: InputGrid|OutputGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & [-1] & toSeq(dim + 1 .. <grid.nDim)
  result = View[type(grid), metaIndices](grid: grid)
  for dim in 0 .. <grid.nDim:
    result.strides[dim] = 0 .. <grid.size[dim]

proc get*[G, m](view: View[G, m], indices: array): auto =
  ## [doc]
  static: assert view is InputGrid
  var adjustedIndices {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    const metaIndex = view.metaIndices[dim]
    let index = when metaIndex >= 0: indices[metaIndex] else: 0
    let slice = view.slices[dim]
    adjustedIndices[dim] = slice.first + slice.stride * index
  view.grid.get(adjustedIndices)

proc size*[G, m](view: View[G, m]): auto =
  ## [doc]
  var result {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <result.len:
    result[dim] = view.slices[dim].len
  result

proc put*[G, m](view: View[G, m], indices: array, value: any) =
  ## [doc]
  static: assert view is OutputGrid
  var adjustedIndices {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    const metaIndex = view.metaIndices[dim]
    let index = when metaIndex >= 0: indices[metaIndex] else: 0
    let slice = view.slices[dim]
    adjustedIndices[dim] = slice.first + slice.stride * index
  view.grid.put(adjustedIndices, value)

proc view*[G, m](view: View[G, m], slices: array): auto =
  ## [doc]
  result = view
  forStatic dim, 0 .. <view.grid.nDim:
    let slice0 = view.slices[dim]
    let slice1 = slices[dim]
    result.slices[dim].first = slice0.first + slice1[0].first * slice0.stride
    result.slices[dim].last = slice0.first + slice1[0].last * slice0.stride
    result.slices[dim].stride = slice0.stride * slice1[0].stride

proc addDim*[G, m](view: View[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 = m[0 .. <dim] & m[dim + 1 .. view.grid.nDim]
  View[G, m1](grid: view.grid, strides: view.strides)

proc delDim*[G, m](view: View[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 = m[0 .. <dim] & [-1] & m[dim + 1 .. <view.grid.nDim]
  View[G, m1](grid: view.grid, strides: view.strides)

#===============================================================================
# Tests

test "inputGrid.view(slices)":
  type CustomGrid = object
    typeClassTag_InputGrid: byte
  proc size(grid: CustomGrid): array[2, int] =
    [3, 4]
  proc get(grid: CustomGrid, indices: array[2, int]): array[2, string] =
    [$indices[0], $indices[1]]
  block:
    let gridView = CustomGrid().view([(1..0).by(1), (0..2).by(2)])
    assert gridView.size == [0, 2]
  block:
    let gridView = CustomGrid().view([(1..2).by(1), (1..0).by(1)])
    assert gridView.size == [2, 0]
  block:
    let gridView = CustomGrid().view([(1..2).by(1), (0..2).by(2)])
    assert gridView.size == [2, 2]
    assert gridView.get([0, 0]) == ["1", "0"]
    assert gridView.get([0, 1]) == ["1", "2"]
    assert gridView.get([1, 0]) == ["2", "0"]
    assert gridView.get([1, 1]) == ["2", "2"]

test "inputGrid.addDim(dim)":
  discard

test "inputGrid.delDim(dim)":
  discard

test "outputGrid.view(slices)":
  type CustomGrid = object
    record: ref seq[string]
    typeClassTag_OutputGrid: byte
  proc size(grid: CustomGrid): array[2, int] =
    [3, 4]
  proc put(grid: CustomGrid, indices: array[2, int], value: int) =
    grid.record[].add("[" & $indices[0] & ", " & $indices[1] & "]: " & $value)
  block:
    let gridView = CustomGrid().view([(1..0).by(1), (0..2).by(2)])
    assert gridView.size == [0, 2]
  block:
    let gridView = CustomGrid().view([(1..2).by(1), (1..0).by(1)])
    assert gridView.size == [2, 0]
  block:
    let grid = CustomGrid(record: new(seq[string]))
    grid.record[] = newSeq[string]()
    let gridView = grid.view([(1..2).by(1), (0..2).by(2)])
    gridView.put([0, 0], 4)
    gridView.put([0, 1], 5)
    gridView.put([1, 0], 6)
    gridView.put([1, 1], 7)
    assert gridView.size == [2, 2]
    assert grid.record[].len == 4
    assert "[1, 0]: 4" in grid.record[]
    assert "[1, 2]: 5" in grid.record[]
    assert "[2, 0]: 6" in grid.record[]
    assert "[2, 2]: 7" in grid.record[]

test "outputGrid.addDim(dim)":
  discard

test "outputGrid.delDim(dim)":
  discard

test "gridView.view(slices)":
  discard

test "gridView.addDim(dim)":
  discard

test "gridView.delDim(dim)":
  discard
