#===============================================================================
# Definitions

type Zipped*[Inputs: tuple] = object
  ## [doc]
  inputs: Inputs
  size: array[maxNDim, int]
  strides: array[maxNZippedGrids, array[maxNDim, int]]
  typeClassTag_InputGrid: byte

proc zip(inputs: tuple): auto =
  result = Zipped[type(inputs)](inputs: inputs)

proc zip*(input0: InputGrid0): auto =
  ## [doc]
  zip((field0: input0))

proc zip*(input0: InputGrid0, input1: InputGrid1): auto =
  ## [doc]
  zip((input0, input1))

proc zip*(input0: InputGrid0, input1: InputGrid1, input2: InputGrid2): auto =
  ## [doc]
  zip((input0, input1, input2))

proc zip*(input0: InputGrid0, input1: InputGrid1,
          input2: InputGrid2, input3: InputGrid3): auto =
  ## [doc]
  zip((input0, input1, input2, input3))

proc size*[Inputs](grid: Zipped[Inputs]): auto =
  ## [doc]
  proc maxNDim: int =
    result = 0
    forStatic i, 0 .. <grid.inputs.len:
      result = max(result, grid.inputs[i].nDim)
  var result {.noInit.}: array[maxNDim(), int]
  result[0 .. result.high] = grid.size[0 .. result.high]
  result

proc get*[Inputs](grid: Zipped[Inputs], indices: tuple): auto =
  ## [doc]
  template resultElement(i: int): expr =
    let input = grid.inputs[i]
    input.get(indices.get(0 .. <input.nDim))
  (0 .. <grid.inputs.len).staticMap(resultElement)

# proc zeros(n: static[int]): auto =
#   macro buildResult: expr =
#     result = newNimNode nnkPar
#     forStatic i in 0 .. <n:
#       result.add(newNimNode(nnkExprColonExpr).add(
#         ident("field" & $i), newLit(0)))
#   buildResult()
#
# type Zipped*[Inputs: tuple, Meta] = object
#   inputs: Inputs
#   meta: Meta
#   typeClassTag_InputGrid: type(())
#
# proc zipProc(inputs: tuple): auto =
#   proc maxNDim(i: static[int]): int =
#     when i < inputs.len:
#       max(inputs[i].nDim, maxNDim(i + 1))
#     else:
#       0
#   var size: type(zeros(maxNDim(0)))
#   var strides: array[inputs.len, array[maxNDim(0), int]]
#   forStatic iAndDim in 0 .. <(inputs.len * maxNDim(0)):
#     const i = iAndDim div maxNDim(0)
#     const dim = iAndDim mod maxNDim(0)
#     when dim < inputs[i].nDim:
#       size[dim] = max(size[dim], inputs[i].size[dim])
#       strides[i][dim] = int(inputs[i].size[dim] > 1)
#   let meta = (size: size, strides: strides)
#   result = Zipped[type(inputs), type(meta)](inputs: inputs, meta: meta)
#
# macro zip*(grid0: InputGrid, others: varargs[expr]): expr =
#   others.insert 0, grid0
#   result = newCall(bindSym"zipProc", pack(others))
#
# proc size*[Inputs, Meta](grid: Zipped[Inputs, Meta]): auto =
#   grid.meta.size
#
# proc get*[Inputs, Meta](grid: Zipped[Inputs, Meta], indices: tuple): auto =
#   macro buildResult: expr =
#     result = newNimNode nnkPar
#     forStatic i in 0 .. <grid.inputs.len:
#       let adjustedIndices = newNimNode nnkPar
#       for dim in 0 .. <grid.inputs[i].nDim:
#         adjustedIndices.add(newNimNode(nnkExprColonExpr).add(
#           ident("field" & $dim),
#           newCall("*",
#             newNimNode(nnkBracketExpr).add(
#               newNimNode(nnkBracketExpr).add(
#                 newDotExpr(
#                   newDotExpr(ident"grid", ident"meta"),
#                   ident"strides"),
#                 newLit(i)),
#               newLit(dim)),
#             newNimNode(nnkBracketExpr).add(
#               ident"indices", newLit(dim)))))
#       result.add(newNimNode(nnkExprColonExpr).add(
#         ident("field" & $i),
#         newNimNode(nnkBracketExpr).add(
#           newNimNode(nnkBracketExpr).add(
#             newDotExpr(ident"grid", ident"inputs"),
#             newLit(i)),
#           adjustedIndices)))
#   result = buildResult()

# proc view*[Inputs, Meta](grid: Zipped[Inputs, Meta], indices: tuple): auto =
#   # TODO: support broadcasting.
#   template viewInput(i: int): expr =
#     grid.inputs[i].view(indices.get(0 .. <grid.inputs[i].nDim))
#   zipProc((0 .. <grid.inputs.len).staticMap(viewInput))

#===============================================================================
# Tests

# test "zip(grid0)":
#   assert zip(@@[0, 1]).collect == @@[(field0: 0), (field0: 1)]
#   assert zip(@@[[0], [1]]).collect == @@[[(field0: 0)], [(field0: 1)]]
#
# test "zip(grid0, grid1)":
#   assert zip(@@[0, 1], @@[2, 3]).collect == @@[(0, 2), (1, 3)]
#   assert zip(@@[[0], [1]], @@[[2], [3]]).collect == @@[[(0, 2)], [(1, 3)]]
#   assert zip(@@[[0], [1]], @@2).collect == @@[[(0, 2)], [(1, 2)]]
#   assert zip(@@[[0], [1]], @@[2]).collect == @@[[(0, 2)], [(1, 2)]]
#   assert zip(@@[[0], [1]], @@[[2]]).collect == @@[[(0, 2)], [(1, 2)]]
#
# test "zip(grid0, grid1, grid2)":
#   assert zip(@@[0], @@[1], @@[2]).collect == @@[(0, 1, 2)]
#   assert zip(@@[[0, 1]], @@2, @@3).collect == @@[[(0, 2, 3), (1, 2, 3)]]
