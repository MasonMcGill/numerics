#===============================================================================
# Definitions

proc join*(inputs: InputGrid): auto =
  ## [doc]
  static: assert inputs.nDim <= inputs.Element.nDim
  template stepAt(dim, i: int): int =
    var indices: inputs.Indices; indices[dim] = i
    inputs.get(indices).size[dim]
  template sizeAlong(dim: int): int =
    when inputs.nDim > dim:
      var result = 0
      for i in 0 .. <inputs.size[dim]:
        result += dim.stepAt(i)
      result
    else:
      var indices: inputs.Indices
      inputs.get(indices).size[dim]
  let resultSize = (0 .. <inputs.Element.nDim).staticMap(sizeAlong)
  result = newDenseGrid(inputs.Element.Element, resultSize)
  proc copyGrids(iGrid: InputGrid, oGrid: OutputGrid, dim: static[int]) =
    template zero(dim: int): int = 0
    let zeros = (0 .. <iGrid.nDim).staticMap(zero)
    when dim >= iGrid.nDim:
      oGrid[] = iGrid[zeros]
    else:
      when dim > 0:
        template iGridSlice(dim: int): Slice[int] = 0 .. <iGrid.size[dim]
        template oGridSlice(dim: int): Slice[int] = 0 .. <oGrid.size[dim]
      var oIndex = 0
      for iIndex in 0 .. <iGrid.size[dim]:
        let iSlices = (0 .. <dim).staticMap(iGridSlice)
        let iView = iGrid[iSlices & (field0: iIndex .. iIndex)]
        let oSlices = (0 .. <dim).staticMap(oGridSlice)
        let oStep = iView[zeros].size[dim]
        let oView = oGrid[oSlices & (field0: oIndex .. oIndex + <oStep)]
        copyGrids(iView, oView, dim + 1)
        oIndex += oStep
  copyGrids(inputs, result, 0)

proc `&`*(input0, input1: InputGrid): auto =
  ## [doc]
  @@[input0, input1].join()

proc collect*(input: InputGrid): auto =
  ## [doc]
  result = newDenseGrid(input.Element, input.size)
  for i, e in input:
    result.put(i, e)

#===============================================================================
# Tests

# test "grids.join()":
#   block:
#     let g0 = @@[0.0]
#     let g1 = @@[1.0, 2.0]
#     let g2 = @@[3.0, 4.0]
#     let g3 = @@[g0, g1, g2]
#     assert g3.join() == @@[0.0, 1.0, 2.0, 3.0, 4.0]
#   block:
#     let g0 = @@[[0, 1]]
#     let g1 = @@[[2, 3], [4, 5]]
#     let g2 = @@[g0, g1]
#     assert g2.join() == @@[[0, 1], [2, 3], [4, 5]]
#   block:
#     let g0 = @@[[0, 1]]
#     let g1 = @@[[2, 3]]
#     let g2 = @@[[4, 5]]
#     let g3 = @@[[6, 7]]
#     let g4 = @@[[g0, g1], [g2, g3]]
#     assert g4.join() == @@[[0, 1, 2, 3], [4, 5, 6, 7]]
#
# test "grid0 & grid1":
#   assert(@@[0, 1] & @@[2, 3, 4] == @@[0, 1, 2, 3, 4])
#   assert(@@[[0], [1]] & @@[[2]] == @@[[0], [1], [2]])
#   assert(@@[[0, 1]] & @@[[2, 3]] == @@[[0, 1], [2, 3]])
#
# test "grid.collect()":
#   assert((0 .. 3).collect() == @@[0, 1, 2, 3])
#   assert(newDenseGrid(int).collect() == newDenseGrid(int))
#   assert(@@[[0, 1], [2, 3]].collect() == @@[[0, 1], [2, 3]])
