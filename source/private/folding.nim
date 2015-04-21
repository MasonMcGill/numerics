import macros
import abstractGrids
import denseGrids
import numericsInternals

proc foldProc(grid: InputGrid, op: static[string],
              init: any, dim: static[int]): auto =
  macro evalOp(a, b: expr): expr =
    newCall(derefExpr(op), a, b)
  static: assert type(evalOp(init, grid.Element.new[])) is type(init)
  static: assert dim >= 0 and dim < grid.nDim
  var resultSize {.noInit.}: array[grid.nDim - 1, int]
  for d in 0 .. <dim:
    resultSize[d] = grid.size[d]
  for d in dim .. <resultSize.len:
    resultSize[d] = grid.size[d + 1]
  result = newDenseGrid(type(init), resultSize)
  for i in result.indices:
    var element = init
    var i1 {.noInit.}: grid.Indices
    for d in 0 .. <dim:
      i1[d] = i[d]
    for d in dim .. <i.len:
      i1[d + 1] = i[d]
    for j in 0 .. <grid.size[dim]:
      i1[dim] = j
      element = evalOp(element, grid.get(i1))
    result[i] = element

macro fold*(grid: InputGrid, op, init: expr, dim: int): expr =
  ## [doc]
  newCall(bindSym"foldProc", grid, newLit(refExpr(op)), init, dim)

proc foldProc(grid: InputGrid, op: static[string], init: any): auto =
  when grid.nDim == 0: grid[]
  else: foldProc(foldProc(grid, op, init, 0), op, init)

macro fold*(grid: InputGrid, op, init: expr): expr =
  ## [doc]
  newCall(bindSym"foldProc", grid, newLit(refExpr(op)), init)
