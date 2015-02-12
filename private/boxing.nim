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

proc get*[G, m](grid: Boxed[G, m], indices: array): auto =
  ## [doc]
  static: assert grid is InputGrid
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    adjustedIndices[dim] = when m[dim] >= 0: indices[m[dim]] else: 0
  grid.base.get(adjustedIndices)

proc put*[G, m](grid: Boxed[G, m], indices: array, value: any) =
  ## [doc]
  static: assert grid is OutputGrid
  var adjustedIndices {.noInit.}: grid.base.Indices
  forStatic dim, 0 .. <adjustedIndices.len:
    adjustedIndices[dim] = when dim in m: indices[m.find(dim)] else: 0
  grid.base.put(adjustedIndices, value)

proc view*[G, m](grid: Boxed[G, m], slices: array): auto =
  ## [doc]
  var adjustedSlices {.noInit.}: array[grid.base.nDim, StridedSlice[int]]
  forStatic dim, 0 .. <adjustedSlices.len:
    adjustedSlices[dim] = when dim in m: slices[m.find(dim)] else: (0..0).by(1)
  grid.base.view(adjustedSlices)

proc box*[G, m](grid: Boxed[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 = m[0 .. <dim] & @[-1] & m[dim .. <m.len]
  Boxed[G, m1](base: grid.base)

proc unbox*[G, m](grid: Boxed[G, m], dim: static[int]): auto =
  ## [doc]
  const m1 = m[0 .. <dim] & m[dim + 1 .. <m.len]
  Boxed[G, m1](base: grid.base)

#===============================================================================
# Tests

# test "inputGrid.box(dim)":
#   discard
#
# test "outputGrid.box(dim)":
#   discard
#
# test "inputGrid.unbox(dim)":
#   discard
#
# test "inputGrid.unbox(dim)":
#   discard
#
# test "boxedGrid.get(indices)":
#   discard
#
# test "boxedGrid.put(indices, value)":
#   discard
#
# test "boxedGrid.view(slices)":
#   discard
#
# test "boxedGrid.box(dim)":
#   discard
#
# test "boxedGrid.unbox(dim)":
#   discard
