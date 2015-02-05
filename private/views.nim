#===============================================================================
# Definitions

type View*[Grid: InputGrid|OutputGrid] = object
  ## [doc]
  grid: Grid
  lens: array[maxNDim, int]
  when Grid is InputGrid:
    typeClassTag_InputGrid: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid: byte

proc view*(grid: InputGrid|OutputGrid, indices: array): auto =
  ## [doc]
  static: assert grid.nDim <= maxNDim
  static: assert grid.nDim == indices.len
  result = View[type(grid)](grid: grid)
  result.lens[0 .. <indices.len] = indices

proc size*[G](view: View[G]): auto =
  ## [doc]
  var result {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <result.len:
    result[dim] = view.lens[dim].len
  result

proc get*[G](view: View[G], indices: array): auto =
  ## [doc]
  static: assert view is InputGrid
  var adjustedIndices {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    let slice = view.lens[dim]
    adjustedIndices[dim] = slice.first + slice.stride * indices[dim]
  view.grid.get(adjustedIndices)

proc put*[G](view: View[G], indices: array, value: any) =
  ## [doc]
  static: assert view is OutputGrid
  var adjustedIndices {.noInit.}: view.grid.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    let slice = view.lens[dim]
    adjustedIndices[dim] = slice.first + slice.stride * indices[dim]
  view.grid.put(adjustedIndices, value)

proc view*[G](view: View[G], slices: array): View[G] =
  ## [doc]
  result.grid = view.grid
  forStatic dim, 0 .. <view.grid.nDim:
    let slice0 = view.lens[dim]
    let slice1 = slices[dim]
    result.lens[dim].first = slice0.first + slice1[0].first * slice0.stride
    result.lens[dim].last = slice0.first + slice1[0].last * slice0.stride
    result.lens[dim].stride = slice0.stride * slice1[0].stride

#===============================================================================
# Tests
