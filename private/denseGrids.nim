#===============================================================================
# Private Definitions

proc sizeAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.len
  else: a[0].sizeAlongDim(dim - 1)

proc lowAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.low
  else: a[0].lowAlongDim(dim - 1)

proc highAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.high
  else: a[0].highAlongDim(dim - 1)

template nestLevel(a: array): expr =
  when a[0] is array: 1 + nestLevel(a[0])
  else: 1

template BaseElement(a: array): expr  =
  when a[0] is array: BaseElement(a[0])
  else: (type(a[0]))

proc copyArrayToGridStmt(aNDim: int, elementType, arrayExpr: PNimrodNode):
                         PNimrodNode {.compileTime.} =
  let constrExpr = newCall("newDenseGrid", elementType)
  for i in 0 .. <aNDim:
    constrExpr.add(newCall("sizeAlongDim", arrayExpr, newLit(i)))
  let indicesExpr = newBracket()
  for dim in 0 .. <aNDim:
    let lowExpr = newCall("lowAlongDim", arrayExpr, newLit(dim))
    indicesExpr.add(newCall("-", ident("i" & $dim), lowExpr))
  var getExpr = arrayExpr
  for dim in 0 .. <aNDim:
    getExpr = newBracketExpr(getExpr, ident("i" & $dim))
  var putStmt = newCall("put", ident"result", indicesExpr, getExpr)
  for dim in countDown(<aNDim, 0):
    let lowExpr = newCall("lowAlongDim", arrayExpr, newLit(dim))
    let highExpr = newCall("highAlongDim", arrayExpr, newLit(dim))
    let boundsExpr = newCall("..", lowExpr, highExpr)
    putStmt = newForStmt(ident("i" & $dim), boundsExpr, putStmt)
  newStmtList(newAssignment(ident"result", constrExpr), putStmt)

#===============================================================================
# Public Definitions

type DenseGrid* {.shallow.} [nDim: static[int]; Element] = object
  ## [doc]
  size, strides: array[nDim, int]
  buffer: seq[Element]
  data: ptr Element
  typeClassTag_InputGrid: byte
  typeClassTag_OutputGrid: byte

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

converter `@@`*[E](element: E): DenseGrid[0, E] =
  ## [doc]
  result = newDenseGrid(E)
  result.put(emptyIntArray, element)

converter `@@`*[R, E](a: array[R, E]): auto =
  ## [doc]
  type ABaseElement = a.BaseElement
  const aNDim = a.nestLevel
  macro initResult: stmt =
    copyArrayToGridStmt(aNDim, ident"ABaseElement", ident"a")
  initResult()

proc size*[n, E](grid: DenseGrid[n, E]): array =
  ## [doc]
  grid.size

proc strides*[n, E](grid: DenseGrid[n, E]): array =
  ## [doc]
  grid.size

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

#===============================================================================
# Tests

test "newDenseGrid(Element)":
  let grid = newDenseGrid(int)
  assert grid.size == emptyIntArray
  assert grid.strides == emptyIntArray
  assert grid.data != nil
  assert grid.get(emptyIntArray) == 0

test "newDenseGrid(Element, size0)":
  let grid = newDenseGrid(int, 5)
  assert grid.size == [5]
  assert grid.strides == [1]
  assert grid.data != nil
  for i in 0 .. <5:
    assert grid.get([i]) == 0

test "newDenseGrid(Element, size0, size1)":
  let grid = newDenseGrid(float, 2, 3)
  assert grid.size == [2, 3]
  assert grid.strides == [3, 1]
  assert grid.data != nil
  for i in 0 .. <2:
    for j in 0 .. <3:
      assert grid.get([i, j]) == 0.0

test "newDenseGrid(Element, size0, size1, size2)":
  let grid = newDenseGrid(string, 3, 0, 1)
  assert grid.size == [3, 0, 1]
  assert grid.strides == [0, 1, 1]

test "newDenseGrid(Element, size)":
  let grid = newDenseGrid(float, [2, 3])
  assert grid.size == [2, 3]
  assert grid.strides == [3, 1]
  assert grid.data != nil
  for i in 0 .. <2:
    for j in 0 .. <3:
      assert grid.get([i, j]) == 0.0

test "@@element":
  block:
    let grid = @@0
    assert grid.size == emptyIntArray
    assert grid.get(emptyIntArray) == 0
  block:
    let grid = @@"0"
    assert grid.size == emptyIntArray
    assert grid.get(emptyIntArray) == "0"

test "@@nestedArrays":
  block:
    let grid = @@[0, 1, 2]
    assert grid.size == [3]
    assert grid.strides == [1]
    assert grid.data != nil
    assert grid.get([0]) == 0
    assert grid.get([1]) == 1
    assert grid.get([2]) == 2
  block:
    let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]
    assert grid.size == [2, 3]
    assert grid.strides == [3, 1]
    assert grid.data != nil
    assert grid.get([0, 0]) == 0.0
    assert grid.get([0, 1]) == 1.0
    assert grid.get([0, 2]) == 2.0
    assert grid.get([1, 0]) == 3.0
    assert grid.get([1, 1]) == 4.0
    assert grid.get([1, 2]) == 5.0
  block:
    let grid = @@[[["0"]], [["1"]], [["2"]]]
    assert grid.size == [3, 1, 1]
    assert grid.strides == [1, 1, 1]
    assert grid.data != nil
    assert grid.get([0, 0, 0]) == "0"
    assert grid.get([1, 0, 0]) == "1"
    assert grid.get([2, 0, 0]) == "2"

test "denseGrid.put(indices, value)":
  block:
    let grid = newDenseGrid(int)
    grid.put(emptyIntArray, 1)
    assert grid.size == emptyIntArray
    assert grid.strides == emptyIntArray
    assert grid.data != nil
    assert grid.get(emptyIntArray) == 1
  block:
    let grid = newDenseGrid(float, 2)
    grid.put([0], 0.0)
    grid.put([1], 1.0)
    assert grid.size == [2]
    assert grid.strides == [1]
    assert grid.data != nil
    assert grid.get([0]) == 0.0
    assert grid.get([1]) == 1.0
  block:
    let grid = newDenseGrid(string, 3, 2)
    grid.put([0, 0], "0")
    grid.put([0, 1], "1")
    grid.put([1, 0], "2")
    grid.put([1, 1], "3")
    grid.put([2, 0], "4")
    grid.put([2, 1], "5")
    assert grid.size == [3, 2]
    assert grid.strides == [2, 1]
    assert grid.data != nil
    assert grid.get([0, 0]) == "0"
    assert grid.get([0, 1]) == "1"
    assert grid.get([1, 0]) == "2"
    assert grid.get([1, 1]) == "3"
    assert grid.get([2, 0]) == "4"
    assert grid.get([2, 1]) == "5"

test "denseGrid.view(indices)":
  block:
    let grid0 = newDenseGrid(int)
    let grid1 = grid0.view(emptySliceArray)
    grid0.put(emptyIntArray, 1)
    assert grid1.size == emptyIntArray
    assert grid1.strides == emptyIntArray
    assert grid1.data != nil
    assert grid1.get(emptyIntArray) == 1
  block:
    let grid0 = newDenseGrid(float, 2)
    let grid1 = grid0.view([(1..1).by(1)])
    grid0.put([1], 1.0)
    assert grid1.size == [1]
    assert grid1.strides == [1]
    assert grid1.data != nil
    assert grid1.get([0]) == 1.0
  block:
    let grid0 = newDenseGrid(string, 3, 2)
    let grid1 = grid0.view([(0..2).by(2), (1..1).by(1)])
    grid0.put([0, 1], "3")
    grid0.put([2, 1], "5")
    assert grid1.size == [2, 1]
    assert grid1.strides == [4, 1]
    assert grid1.data != nil
    assert grid1.get([0, 0]) == "3"
    assert grid1.get([1, 0]) == "5"

test "denseGrid.box(dim)":
  block:
    let grid0 = newDenseGrid(int)
    let grid1 = grid0.box(0)
    assert grid1.size == [1]
    assert grid1.strides == [0]
    assert grid1.data == grid0.data
  block:
    let grid0 = newDenseGrid(int, 3, 2)
    let grid1 = grid0.box(1)
    assert grid1.size == [3, 1, 2]
    assert grid1.strides == [2, 0, 1]
    assert grid1.data == grid0.data

test "denseGrid.unbox(dim)":
  block:
    let grid0 = newDenseGrid(int, 3)
    let grid1 = grid0.unbox(0)
    assert grid1.size == emptyIntArray
    assert grid1.strides == emptyIntArray
    assert grid1.data == grid0.data
  block:
    let grid0 = newDenseGrid(int, 3, 2)
    let grid1 = grid0.unbox(1)
    assert grid1.size == [3]
    assert grid1.strides == [2]
    assert grid1.data == grid0.data
