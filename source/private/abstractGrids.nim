import macros
import strutils
import numericsInternals

type InputGrid* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type InputGrid0* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type InputGrid1* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type InputGrid2* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type InputGrid3* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type OutputGrid* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type OutputGrid0* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type OutputGrid1* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type OutputGrid2* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type OutputGrid3* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type StatefulGrid* = InputGrid and OutputGrid
  ## [doc]

type StatefulGrid0* = InputGrid and OutputGrid
  ## [doc]

type StatefulGrid1* = InputGrid and OutputGrid
  ## [doc]

type StatefulGrid2* = InputGrid and OutputGrid
  ## [doc]

type StatefulGrid3* = InputGrid and OutputGrid
  ## [doc]

type SomeGrid* = InputGrid or OutputGrid
  ## [doc]

type SomeGrid0* = InputGrid or OutputGrid
  ## [doc]

type SomeGrid1* = InputGrid or OutputGrid
  ## [doc]

type SomeGrid2* = InputGrid or OutputGrid
  ## [doc]

type SomeGrid3* = InputGrid or OutputGrid
  ## [doc]

template nDim*(Grid: typedesc[SomeGrid]): int =
  ## [doc]
  Grid.new[].size.len

template nDim*(grid: SomeGrid): int =
  ## [doc]
  grid.size.len

template Indices*(Grid: typedesc[SomeGrid]): typedesc =
  ## [doc]
  type(Grid.new[].size)

template Indices*(grid: SomeGrid): typedesc =
  ## [doc]
  type(grid.size)

template Element*(Grid: typedesc[InputGrid]): typedesc =
  ## [doc]
  type(Grid.new[].get(Grid.Indices.new[]))

template Element*(grid: InputGrid): typedesc =
  ## [doc]
  type(grid.get(grid.Indices.new[]))

proc yieldIndicesStmt(nDim: int): NimNode {.compileTime.} =
  if nDim == 0:
    result = newYieldStmt(bindSym"emptyIntArray")
  else:
    let indicesExpr = newBracket()
    for dim in 0 .. <nDim:
      indicesExpr.add(ident("i" & $dim))
    result = newYieldStmt(indicesExpr)
    for dim in countDown(<nDim, 0):
      let lenExpr = newBracketExpr(
        newDotExpr(ident"grid", ident"size"),
        newLit(dim))
      result = newForStmt(
        ident("i" & $dim),
        newCall("..", newLit(0), newCall("<", lenExpr)),
        result)

iterator indices*(grid: SomeGrid): auto =
  ## [doc]
  macro buildAction: stmt =
    yieldIndicesStmt(grid.nDim)
  buildAction()

iterator items*(grid: InputGrid): auto =
  ## [doc]
  for i in grid.indices:
    yield grid.get(i)

iterator pairs*(grid: InputGrid): auto =
  ## [doc]
  for i in grid.indices:
    yield (i, grid.get(i))

proc `==`*(grid0: InputGrid0, grid1: InputGrid1): bool =
  ## [doc]
  if grid0.size != grid1.size:
    return false
  for i in grid0.indices:
    if grid0.get(i) != grid1.get(i):
      return false
  return true

proc describeGrid[R](grid: InputGrid, indices: array[R, int]): string =
  when indices.len == grid.nDim:
    result = $(grid.get(indices))
  else:
    const delim = "," & "\n".repeat(grid.nDim - indices.len - 1) & " "
    result = "["
    for i in 0 .. <grid.size[indices.len]:
      var adjustedIndices: array[indices.len + 1, int]
      adjustedIndices[0 .. <indices.len] = indices
      adjustedIndices[indices.len] = i
      if i > 0: result &= delim
      result &= describeGrid(grid, adjustedIndices).replace("\n", "\n ")
    result &= "]"

proc `$`*(grid: InputGrid): string =
  ## [doc]
  describeGrid(grid, emptyIntArray)
