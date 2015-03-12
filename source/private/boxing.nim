import abstractGrids
import numericsInternals
import slices

type Boxed*[Grid: SomeGrid, metaIndices: static[seq[int]]] = object
  ## [doc]
  base: Grid
  when Grid is InputGrid:
    typeClassTag_InputGrid*: byte
  when Grid is OutputGrid:
    typeClassTag_OutputGrid*: byte

proc box*(grid: SomeGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & @[-1] & toSeq(dim .. <grid.nDim)
  Boxed[type(grid), metaIndices](base: grid)

proc unbox*(grid: SomeGrid, dim: static[int]): auto =
  ## [doc]
  const metaIndices = toSeq(0 .. <dim) & toSeq(dim + 1 .. <grid.nDim)
  Boxed[type(grid), metaIndices](base: grid)

proc size*[G, m](grid: Boxed[G, m]): auto =
  ## [doc]
  const m1 = m
  var res {.noInit.}: array[m.len, int]
  forStatic dim, 0 .. <m1.len:
    res[dim] = when m1[dim] != -1: grid.base.size[m1[dim]] else: 1
  res

proc get*[G, m](grid: Boxed[G, m], indices: array): auto =
  ## [doc]
  static: assert grid is InputGrid
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    const m1 = m
    adjustedIndices[dim] = when dim in m1: indices[m1.find(dim)] else: 0
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

proc `==`*[G, m](grid0, grid1: Boxed[G, m]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[G, m](grid: Boxed[G, m]): string =
  ## [doc]
  abstractGrids.`$`(grid)
