import abstractGrids
import numericsInternals
import slices

type Boxed*[Grid: InputGrid|OutputGrid, metaIndices: static[seq[int]]] = object
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
