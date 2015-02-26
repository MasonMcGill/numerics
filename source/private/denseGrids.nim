import macros
import abstractGrids
import numericsInternals

proc `+=`[E](p: var ptr E, i: int) =
  p = cast[ptr E](cast[int](p) + i * sizeOf(E))

type DenseGrid* {.shallow.} [nDim: static[int]; Element] = object
  ## [doc]
  size, strides: array[nDim, int]
  buffer: seq[Element]
  data: ptr Element
  typeClassTag_InputGrid*: byte
  typeClassTag_OutputGrid*: byte

proc newDenseGrid*[R](Element: typedesc, size: array[R, int]): auto =
  ## [doc]
  const n = size.len
  var result: DenseGrid[n, Element]
  for i in countDown(<n, 0):
    result.strides[i] =
      if i < n - 1: size[i+1] * result.strides[i+1]
      else: 1
  var nElements = 1
  for i in 0 .. <n:
    nElements *= size[i]
  result.size = size
  result.buffer = newSeq[Element](nElements)
  result.data = if nElements > 0: addr(result.buffer[0]) else: nil
  result

macro newDenseGrid*(Element: expr, size: varargs[int]): expr =
  ## [doc]
  if size.len == 0:
    newCall(bindSym"newDenseGrid", Element, bindSym"emptyIntArray")
  else:
    var sizeArray = newBracket()
    for i in 0 .. <size.len:
      sizeArray.add(size[i])
    newCall(bindSym"newDenseGrid", Element, sizeArray)

proc sizeAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.len
  else: a[0].sizeAlongDim(dim - 1)

proc lowAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.low
  else: a[0].lowAlongDim(dim - 1)

proc highAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.high
  else: a[0].highAlongDim(dim - 1)

proc copyArrayToGridStmt(aNDim: int, elementType, arrayExpr: PNimrodNode):
                         PNimrodNode {.compileTime.} =
  let constrExpr = newCall(bindSym"newDenseGrid", elementType)
  for i in 0 .. <aNDim:
    constrExpr.add(newCall(bindSym"sizeAlongDim", arrayExpr, newLit(i)))
  let indicesExpr = newBracket()
  for dim in 0 .. <aNDim:
    let lowExpr = newCall(bindSym"lowAlongDim", arrayExpr, newLit(dim))
    indicesExpr.add(newCall("-", ident("i" & $dim), lowExpr))
  var getExpr = arrayExpr
  for dim in 0 .. <aNDim:
    getExpr = newBracketExpr(getExpr, ident("i" & $dim))
  var putStmt = newCall("put", ident"result", indicesExpr, getExpr)
  for dim in countDown(<aNDim, 0):
    let lowExpr = newCall(bindSym"lowAlongDim", arrayExpr, newLit(dim))
    let highExpr = newCall(bindSym"highAlongDim", arrayExpr, newLit(dim))
    let boundsExpr = newCall("..", lowExpr, highExpr)
    putStmt = newForStmt(ident("i" & $dim), boundsExpr, putStmt)
  newStmtList(newAssignment(ident"result", constrExpr), putStmt)

proc `@@`*[R, E](a: array[R, E]): auto =
  ## [doc]
  template BaseElement(x: expr): expr  =
    when x[0] is array: BaseElement(x[0])
    else: (type(x[0]))
  template nestLevel(x: expr): expr =
    when x[0] is array: 1 + nestLevel(x[0])
    else: 1
  type ABaseElement = a.BaseElement
  const aNDim = a.nestLevel
  macro initResult: stmt =
    copyArrayToGridStmt(aNDim, ident"ABaseElement", ident"a")
  initResult()

proc `@@`*[E](element: E): DenseGrid[0, E] =
  ## [doc]
  result = newDenseGrid(E)
  result.put(emptyIntArray, element)

proc size*[n, E](grid: DenseGrid[n, E]): array =
  ## [doc]
  grid.size

proc strides*[n, E](grid: DenseGrid[n, E]): array =
  ## [doc]
  grid.strides

proc data*[n, E](grid: DenseGrid[n, E]): auto =
  ## [doc]
  grid.data

proc get*[n, E](grid: DenseGrid[n, E], indices: array): auto =
  ## [doc]
  var data = grid.data
  forStatic dim, 0 .. <indices.len:
    assert indices[dim] < grid.size[dim]
    data += grid.strides[dim] * indices[dim]
  data[]

proc put*[n, E](grid: DenseGrid[n, E], indices: array, element: E) =
  ## [doc]
  var data = grid.data
  forStatic dim, 0 .. <indices.len:
    assert indices[dim] < grid.size[dim]
    data += grid.strides[dim] * indices[dim]
  data[] = element

proc view*[n, E](grid: DenseGrid[n, E], slices: array): DenseGrid[n, E] =
  ## [doc]
  result.data = grid.data
  forStatic dim, 0 .. <n:
    assert slices[dim].first <= slices[dim].last + 1
    assert slices[dim].first >= 0 and slices[dim].last < grid.size[dim]
    result.size[dim] = slices[dim].len
    result.strides[dim] = slices[dim].stride * grid.strides[dim]
    result.data += slices[dim].first * grid.strides[dim]

proc box*[n, E](grid: DenseGrid[n, E], dim: static[int]): auto =
  ## [doc]
  static: assert dim >= 0 and dim <= n
  var result {.noInit.}: DenseGrid[n + 1, E]
  result.size[dim] = 1
  result.size[0 .. <dim] = grid.size[0 .. <dim]
  result.size[dim + 1 .. <n + 1] = grid.size[dim .. <n]
  result.strides[dim] = 0
  result.strides[0 .. <dim] = grid.strides[0 .. <dim]
  result.strides[dim + 1 .. <n + 1] = grid.strides[dim .. <n]
  result.buffer.shallowCopy grid.buffer
  result.data = grid.data
  result

proc unbox*[n, E](grid: DenseGrid[n, E], dim: static[int]): auto =
  ## [doc]
  static: assert n > 0
  static: assert dim >= 0 and dim < n
  var result {.noInit.}: DenseGrid[n - 1, E]
  result.size[0 .. <dim] = grid.size[0 .. <dim]
  result.size[dim .. <n - 1] = grid.size[dim + 1 .. <n]
  result.strides[0 .. <dim] = grid.strides[0 .. <dim]
  result.strides[dim .. <n - 1] = grid.strides[dim + 1 .. <n]
  result.buffer.shallowCopy grid.buffer
  result.data = grid.data
  result

proc `==`*[n, E](grid0, grid1: DenseGrid[n, E]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[n, E](grid: DenseGrid[n, E]): string =
  ## [doc]
  abstractGrids.`$`(grid)
