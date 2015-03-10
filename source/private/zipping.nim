import macros
import abstractGrids
import numericsInternals

type Zipped*[Inputs: tuple] = object
  ## [doc]
  inputs: Inputs
  size: array[maxNDim, int]
  strides: array[maxNZippedGrids, array[maxNDim, int]]
  typeClassTag_InputGrid*: byte

proc zip(inputs: tuple): auto =
  proc getResultNDim: int =
    result = 0
    forStatic i, 0 .. <inputs.len:
      result = max(result, inputs[i].nDim)
  const resultNDim = getResultNDim()
  result = Zipped[type(inputs)](inputs: inputs)
  forStatic iAndDim, 0 .. <(inputs.len * resultNDim):
    const i = iAndDim div resultNDim
    const dim = iAndDim mod resultNDim
    when dim < inputs[i].nDim:
      result.size[dim] = max(result.size[dim], inputs[i].size[dim])
      result.strides[i][dim] = int(inputs[i].size[dim] > 1)

proc zip*(input0: InputGrid): auto =
  ## [doc]
  zip((field0: input0))

proc zip*(input0: InputGrid, input1: any): auto =
  ## [doc]
  zip((input0, input1))

proc zip*(input0: InputGrid, input1: any, input2: any): auto =
  ## [doc]
  zip((input0, input1, input2))

proc zip*(input0: InputGrid, input1: any, input2: any, input3: any): auto =
  ## [doc]
  zip((input0, input1, input2, input3))

proc size*[Inputs](grid: Zipped[Inputs]): auto =
  ## [doc]
  proc getGridNDim: int =
    result = 0
    forStatic i, 0 .. <grid.inputs.len:
      result = max(result, grid.inputs[i].nDim)
  var res {.noInit.}: array[getGridNDim(), int]
  forStatic dim, 0 .. <res.len:
    res[dim] = grid.size[dim]
  res

proc getBroadcast(grid: InputGrid, strides: array[maxNDim, int],
                  indices: array): auto =
  var adjustedIndices {.noInit.}: array[grid.nDim, int]
  forStatic dim, 0 .. <grid.nDim:
    adjustedIndices[dim] = strides[dim] * indices[dim]
  grid.get(adjustedIndices)

proc getExpr(n: int): NimNode {.compileTime.} =
  result = newPar()
  for i in 0 .. <n:
    result.add(
      newColonExpr(
        ident("field" & $i),
        newCall(
          bindSym"getBroadcast",
          newBracketExpr(
            newDotExpr(ident"grid", ident"inputs"),
            newLit(i)),
          newBracketExpr(
            newDotExpr(ident"grid", ident"strides"),
            newLit(i)),
          ident"indices")))

proc get*[Inputs](grid: Zipped[Inputs], indices: array): auto =
  ## [doc]
  macro buildResult: expr =
    getExpr(grid.inputs.len)
  buildResult()

proc viewBroadcast(grid: InputGrid, slices: array): auto =
  var adjustedSlices {.noInit.}: array[grid.nDim, int]
  forStatic dim, 0 .. <grid.nDim:
    adjustedSlices[dim] = slices[dim]
  grid.view(adjustedSlices)

proc viewExpr(n: int): NimNode {.compileTime.} =
  result = newCall(bindSym"zip")
  for i in 0 .. <n:
    result.add(
      newCall(
        bindSym"viewBroadcast",
        newBracketExpr(
          newDotExpr(ident"grid", ident"inputs"),
          newLit(i)),
        ident"slices"))

proc view*[Inputs](grid: Zipped[Inputs], slices: array): auto =
  ## [doc]
  macro buildResult: expr =
    viewExpr(grid.inputs.len)
  buildResult()

proc boxBroadcast(grid: InputGrid, dim: static[int]): auto =
  when dim <= grid.nDim:
    grid.box(dim)
  else:
    grid

proc boxExpr(n: int): NimNode {.compileTime.} =
  result = newCall(bindSym"zip")
  for i in 0 .. <n:
    result.add(
      newCall(
        bindSym"boxBroadcast",
        newBracketExpr(
          newDotExpr(ident"grid", ident"inputs"),
          newLit(i)),
        ident"dim"))

proc box*[Inputs](grid: Zipped[Inputs], dim: static[int]): auto =
  ## [doc]
  macro buildResult: expr =
    boxExpr(grid.inputs.len)
  buildResult()

proc unboxBroadcast(grid: InputGrid, dim: static[int]): auto =
  when dim < grid.nDim:
    grid.unbox(dim)
  else:
    grid

proc unboxExpr(n: int): NimNode {.compileTime.} =
  result = newCall(bindSym"zip")
  for i in 0 .. <n:
    result.add(
      newCall(
        bindSym"unboxBroadcast",
        newBracketExpr(
          newDotExpr(ident"grid", ident"inputs"),
          newLit(i)),
        ident"dim"))

proc unbox*[Inputs](grid: Zipped[Inputs], dim: static[int]): auto =
  ## [doc]
  macro buildResult: expr =
    unboxExpr(grid.inputs.len)
  buildResult()

proc `==`*[Inputs](grid0, grid1: Zipped[Inputs]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[Inputs](grid: Zipped[Inputs]): string =
  ## [doc]
  abstractGrids.`$`(grid)
