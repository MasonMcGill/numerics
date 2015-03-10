import abstractGrids
import numericsInternals
import slices

type View*[Grid: SomeGrid] = object
  ## [doc]
  base: Grid
  slices: array[maxNDim, StridedSlice[int]]
  when Grid is InputGrid:
    typeClassTag_InputGrid*: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid*: byte

proc view*(grid: SomeGrid, slices: array): auto =
  ## [doc]
  static: assert grid.nDim <= maxNDim
  static: assert grid.nDim == slices.len
  result = View[type(grid)](base: grid)
  result.slices[0 .. <slices.len] = slices

proc size*[G](grid: View[G]): auto =
  ## [doc]
  var res {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <res.len:
    res[dim] = grid.slices[dim].len
  res

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

proc `==`*[G](grid0, grid1: View[G]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[G](grid: View[G]): string =
  ## [doc]
  abstractGrids.`$`(grid)
