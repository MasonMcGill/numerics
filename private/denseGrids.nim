#===============================================================================
# Definitions

type DenseGrid* {.shallow.} [nDim: static[int]; Element] = object
  ## [doc]
  sizeArray, stridesArray: array[nDim, int]
  buffer: seq[Element]
  data: ptr Element
  typeClassTag_InputGrid: bool
  typeClassTag_OutputGrid: bool

proc newDenseGrid*(Element: typedesc, size: tuple): auto =
  ## [doc]
  const n = size.len
  var result: DenseGrid[n, Element]
  when n > 0:
    result.stridesArray[n-1] = 1
  forStatic i, 0 .. <n:
    result.sizeArray[i] = size[i]
  forStatic i, 2 .. n:
    result.stridesArray[n-i] = size[n-i+1] * result.stridesArray[n-i+1]
  var nElements = 1
  for i in 0 .. <n:
    nElements *= result.sizeArray[i]
  result.buffer = newSeq[Element](nElements)
  result.data = if nElements > 0: addr(result.buffer[0]) else: nil
  result

macro newDenseGrid*(Element: expr, size: varargs[int]): expr =
  ## [doc]
  var sizeTuple = newPar()
  for i in 0 .. <size.len:
    sizeTuple.add(newColonExpr(
      ident("field" & $i), size[i]))
  newCall(bindSym"newDenseGrid", Element, sizeTuple)

converter `@@`*[Element](element: Element): DenseGrid[0, Element] =
  ## [doc]
  result = newDenseGrid(Element)
  result.put((), element)

proc sizeAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.len
  else: a[0].sizeAlongDim(dim - 1)

proc lowAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.low
  else: a[0].lowAlongDim(dim - 1)

proc highAlongDim(a: any, dim: static[int]): int =
  when dim == 0: a.high
  else: a[0].highAlongDim(dim - 1)

template nestLevel(x: array): expr =
  when x[0] is array: 1 + nestLevel(x[0])
  else: 1

template BaseElement(x: array): expr  =
  when x[0] is array: BaseElement(x[0])
  else: (type(x[0]))

converter `@@`*[Range, Element](a: array[Range, Element]): auto =
  ## [doc]
  type ABaseElement = a.BaseElement
  const aNDim = a.nestLevel
  macro initResult: stmt =
    let constrExpr = newCall(bindSym"newDenseGrid", ident"ABaseElement")
    for i in 0 .. <aNDim:
      constrExpr.add(newCall(bindSym"sizeAlongDim", ident"a", newLit(i)))
    let indicesExpr = newPar()
    for dim in 0 .. <aNDim:
      let lowExpr = newCall(ident"lowAlongDim", ident"a", newLit(dim))
      let adjIndexExpr = newCall("-", ident("i" & $dim), lowExpr)
      indicesExpr.add(newColonExpr(ident("field" & $dim), adjIndexExpr))
    var getExpr = ident"a"
    for dim in 0 .. <aNDim:
      getExpr = newBracketExpr(getExpr, ident("i" & $dim))
    var putStmt = newCall("put", ident"result", indicesExpr, getExpr)
    for dim in countDown(<aNDim, 0):
      let lowExpr = newCall(ident"lowAlongDim", ident"a", newLit(dim))
      let highExpr = newCall(ident"highAlongDim", ident"a", newLit(dim))
      let boundsExpr = newCall("..", lowExpr, highExpr)
      putStmt = newForStmt(ident("i" & $dim), boundsExpr, putStmt)
    newStmtList(newAssignment(ident"result", constrExpr), putStmt)
    newAssignment(ident"result", constrExpr)
  initResult()

proc size*[n, E](grid: DenseGrid[n, E]): auto =
  ## [doc]
  macro buildResult: expr =
    result = newPar()
    for i in 0 .. <n:
      result.add(newColonExpr(
        ident("field" & $i),
        newBracketExpr(
          newDotExpr(ident"grid", ident"sizeArray"),
          newLit(i))))
  buildResult()

proc strides*[n, E](grid: DenseGrid[n, E]): auto =
  ## [doc]
  macro buildResult: expr =
    result = newPar()
    for i in 0 .. <n:
      result.add(newColonExpr(
        ident("field" & $i),
        newBracketExpr(
          newDotExpr(ident"grid", ident"stridesArray"),
          newLit(i))))
  buildResult()

proc data*[n, E](grid: DenseGrid[n, E]): auto =
  ## [doc]
  grid.data

proc get*[n, E](grid: DenseGrid[n, E], indices: tuple): auto =
  ## [doc]
  var data = grid.data
  forStatic i, 0 .. <indices.len:
    assert indices[i] < grid.sizeArray[i]
    data += grid.stridesArray[i] * indices[i]
  data[]

proc put*[n, E](grid: DenseGrid[n, E], indices: tuple, element: any) =
  ## [doc]
  var data = grid.data
  forStatic i, 0 .. <indices.len:
    assert indices[i] < grid.sizeArray[i]
    data += grid.stridesArray[i] * indices[i]
  data[] = element

proc view*[n, E](grid: DenseGrid[n, E], indices: tuple): auto =
  ## [doc]
  var result: numerics.DenseGrid[indices.nSlices, grid.Element]
  result.data = grid.data
  forStatic i, 0 .. <indices.len:
    let index = indices[i]
    when index is int:
      assert index >= 0 and index < grid.sizeArray[i]
      result.data += grid.stridesArray[i] * index
    else:
      assert index.first <= index.last + 1
      assert index.first >= 0 and index.last < grid.sizeArray[i]
      const j = indices.nSlicesBefore(i)
      result.sizeArray[j] = index.last - index.first + 1
      result.stridesArray[j] = grid.stridesArray[i]
      result.data += grid.stridesArray[i] * index.first
  result

#===============================================================================
# Tests

# test "newDenseGrid(Element)":
#   let grid = newDenseGrid(int)
#   assert grid.size == ()
#   assert grid.strides == ()
#   assert grid.data != nil
#   assert grid.get(()) == 0
#
# test "newDenseGrid(Element, size0)":
#   let grid = newDenseGrid(int, 5)
#   assert grid.size == (field0: 5)
#   assert grid.strides == (field0: 1)
#   assert grid.data != nil
#   for i in 0 .. <5:
#     assert grid.get((field0: i)) == 0
#
# test "newDenseGrid(Element, size0, size1)":
#   let grid = newDenseGrid(float, 2, 3)
#   assert grid.size == (2, 3)
#   assert grid.strides == (3, 1)
#   assert grid.data != nil
#   for i in 0 .. <2:
#     for j in 0 .. <3:
#       assert grid.get((i, j)) == 0.0
#
# test "newDenseGrid(Element, size0, size1, size2)":
#   let grid = newDenseGrid(string, 3, 0, 1)
#   assert grid.size == (3, 0, 1)
#   assert grid.strides == (0, 1, 1)
#
# test "newDenseGrid(Element, size)":
#   let grid = newDenseGrid(float, (2, 3))
#   assert grid.size == (2, 3)
#   assert grid.strides == (3, 1)
#   assert grid.data != nil
#   for i in 0 .. <2:
#     for j in 0 .. <3:
#       assert grid.get((i, j)) == 0.0
# 
# test "@@element":
#   block:
#     let grid = @@0
#     assert grid.size == ()
#     assert grid.get(()) == 0
#   block:
#     let grid = @@"0"
#     assert grid.size == ()
#     assert grid.get(()) == "0"
#
# test "@@nestedArrays":
#   block:
#     let grid = @@[0, 1, 2]
#     assert grid.size == (field0: 3)
#     assert grid.strides == (field0: 1)
#     assert grid.data != nil
#     assert grid.get((field0: 0)) == 0
#     assert grid.get((field0: 1)) == 1
#     assert grid.get((field0: 2)) == 2
#   block:
#     let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]
#     assert grid.size == (2, 3)
#     assert grid.strides == (3, 1)
#     assert grid.data != nil
#     assert grid.get((0, 0)) == 0.0
#     assert grid.get((0, 1)) == 1.0
#     assert grid.get((0, 2)) == 2.0
#     assert grid.get((1, 0)) == 3.0
#     assert grid.get((1, 1)) == 4.0
#     assert grid.get((1, 2)) == 5.0
#   block:
#     let grid = @@[[["0"]], [["1"]], [["2"]]]
#     assert grid.size == (3, 1, 1)
#     assert grid.strides == (1, 1, 1)
#     assert grid.data != nil
#     assert grid.get((0, 0, 0)) == "0"
#     assert grid.get((1, 0, 0)) == "1"
#     assert grid.get((2, 0, 0)) == "2"
#
# test "denseGrid.put(indices, value)":
#   block:
#     let grid = newDenseGrid(int)
#     grid.put((), 1)
#     assert grid.size == ()
#     assert grid.strides == ()
#     assert grid.data != nil
#     assert grid.get(()) == 1
#   block:
#     let grid = newDenseGrid(float, 2)
#     grid.put((field0: 0), 0.0)
#     grid.put((field0: 1), 1.0)
#     assert grid.size == (field0: 2)
#     assert grid.strides == (field0: 1)
#     assert grid.data != nil
#     assert grid.get((field0: 0)) == 0.0
#     assert grid.get((field0: 1)) == 1.0
#   block:
#     let grid = newDenseGrid(string, 3, 2)
#     grid.put((0, 0), "0")
#     grid.put((0, 1), "1")
#     grid.put((1, 0), "2")
#     grid.put((1, 1), "3")
#     grid.put((2, 0), "4")
#     grid.put((2, 1), "5")
#     assert grid.size == (3, 2)
#     assert grid.strides == (2, 1)
#     assert grid.data != nil
#     assert grid.get((0, 0)) == "0"
#     assert grid.get((0, 1)) == "1"
#     assert grid.get((1, 0)) == "2"
#     assert grid.get((1, 1)) == "3"
#     assert grid.get((2, 0)) == "4"
#     assert grid.get((2, 1)) == "5"
#
# test "denseGrid.view(indices)":
#   block:
#     let grid0 = newDenseGrid(int)
#     let grid1 = grid0.view(())
#     grid0.put((), 1)
#     assert grid1.size == ()
#     assert grid1.strides == ()
#     assert grid1.data != nil
#     assert grid1.get(()) == 1
#   block:
#     let grid0 = newDenseGrid(float, 2)
#     let grid1 = grid0.view((field0: 1))
#     grid0.put((field0: 1), 1.0)
#     assert grid1.size == ()
#     assert grid1.strides == ()
#     assert grid1.data != nil
#     assert grid1.get(()) == 1.0
#   block:
#     let grid0 = newDenseGrid(float, 2)
#     let grid1 = grid0.view((field0: (1..1).by(1)))
#     grid0.put((field0: 1), 1.0)
#     assert grid1.size == (field0: 1)
#     assert grid1.strides == (field0: 1)
#     assert grid1.data != nil
#     assert grid1.get((field0: 0)) == 1.0
#   block:
#     let grid0 = newDenseGrid(string, 3, 2)
#     let grid1 = grid0.view(((1..2).by(1), 1))
#     grid0.put((1, 1), "3")
#     grid0.put((2, 1), "5")
#     assert grid1.size == (field0: 2)
#     assert grid1.strides == (field0: 2)
#     assert grid1.data != nil
#     assert grid1.get((field0: 0)) == "3"
#     assert grid1.get((field0: 1)) == "5"
