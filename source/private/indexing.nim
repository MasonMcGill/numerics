import macros
import abstractGrids
import numericsInternals

proc pack(args: PNimrodNode): PNimrodNode {.compileTime.} =
  result = newNimNode nnkPar
  for i in 0 .. <args.len:
    result.add(newNimNode(nnkExprColonExpr).add(
      ident("field" & $i), args[i]))

template len*(tup: tuple): int =
  template getLen(i: static[int]): int {.genSym.} =
    when compiles(tup[i]): getLen(i + 1) else: i
  getLen 0

type NewDim* = object
type FullSlice* = object

let newDim* = NewDim()
let fullSlice* = FullSlice()

template areAllInts(indices: tuple, dim: int): bool =
  when compiles(indices[dim]):
    indices[dim] is int and indices.areAllInts(dim + 1)
  else:
    true

template areAllInts(indices: tuple): bool =
  indices.areAllInts(0)

proc describeIndices(Indices: typedesc[tuple]): seq[string] {.compileTime.} =
  result = newSeq[string]()
  var indices: Indices
  forStatic dim, 0 .. <indices.len:
    if indices[dim] is int:
      result.add "int"
    elif indices[dim] is Slice:
      result.add "Slice"
    elif indices[dim] is StridedSlice:
      result.add "StridedSlice"
    elif indices[dim] is FullSlice:
      result.add "FullSlice"
    elif indices[dim] is NewDim:
      result.add "NewDim"

proc expandedFullSliceExpr(gridExpr: PNimrodNode, dim: int):
                           PNimrodNode {.compileTime.} =
  let lenExpr = newBracketExpr(newDotExpr(gridExpr, ident"size"), newLit(dim))
  newCall("by", newCall("..", newLit(0), newCall("<", lenExpr)), newLit(1))

proc subgridExpr(gridExpr, indicesExpr: PNimrodNode,
                 nDim: int, indexTypes: seq[string]):
                 PNimrodNode {.compileTime.} =
  result = gridExpr
  if "int" in indexTypes or "Slice" in indexTypes or
     "StridedSlice" in indexTypes:
    let slicesExpr = newBracket()
    for indexType in indexTypes:
      let indexExpr = newBracketExpr(indicesExpr, newLit(slicesExpr.len))
      if indexType == "int":
        let boundsExpr = newCall("..", indexExpr, indexExpr)
        slicesExpr.add(newCall("by", boundsExpr, newLit(1)))
      elif indexType == "Slice":
        slicesExpr.add(newCall("by", indexExpr, newLit(1)))
      elif indexType == "StridedSlice":
        slicesExpr.add(indexExpr)
      elif indexType == "FullSlice":
        slicesExpr.add(expandedFullSliceExpr(gridExpr, slicesExpr.len))
    while slicesExpr.len < nDim:
      slicesExpr.add(expandedFullSliceExpr(gridExpr, slicesExpr.len))
    result = newCall("view", result, slicesExpr)
  for dim in countDown(<indexTypes.len, 0):
    if indexTypes[dim] == "NewDim":
      result = newCall("box", result, newLit(dim))
    elif indexTypes[dim] == "int":
      result = newCall("unbox", result, newLit(dim))

proc `[]`*(grid: InputGrid|OutputGrid, indices: tuple): auto =
  ## [doc]:
  when indices.areAllInts and indices.len == grid.nDim:
    var indicesArray {.noInit.}: array[indices.len, int]
    forStatic i, 0 .. <indices.len:
      indicesArray[i] = indices[i]
    grid.get(indicesArray)
  else:
    type Indices = type(indices)
    const indicesDesc = describeIndices(Indices)
    macro buildResult: expr =
      subgridExpr(ident"grid", ident"indices", grid.nDim, indicesDesc)
    buildResult()

macro `[]`*(grid: InputGrid|OutputGrid, indices: varargs[expr]): expr =
  ## [doc]
  newCall(bindSym"[]", grid, pack(indices))

proc `[]=`*(grid: OutputGrid, indices: tuple, value: any) =
  ## [doc]
  when indices.areAllInts and indices.len == grid.nDim:
    var indicesArray {.noInit.}: array[indices.len, int]
    forStatic i, 0 .. <indices.len:
      indicesArray[i] = indices[i]
    grid.put(indicesArray, value)
  else:
    let gridView = grid[indices]
    for i in gridView.indices:
      when value is InputGrid:
        var subindices {.noInit.}: array[value.nDim, int]
        subindices[0 .. <subindices.len] = i[0 .. <subindices.len]
        gridView.put(i, value.get(subindices))
      else:
        gridView.put(i, value)

macro `[]=`*(grid: OutputGrid, indicesAndValue: varargs[expr]): stmt =
  ## [doc]
  let value = indicesAndValue[indicesAndValue.len - 1]
  var indices = indicesAndValue
  indices.del(indices.len - 1)
  newCall(bindSym"[]=", grid, pack(indices), value)
