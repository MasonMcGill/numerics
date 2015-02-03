#===============================================================================
# Definitions

type InputGrid* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_InputGrid)

type OutputGrid* = generic X
  ## [doc]
  var x: X; compiles(x.typeClassTag_OutputGrid)

type InputGrid0* = generic X
  ## [doc]
  X is InputGrid

type InputGrid1* = generic X
  ## [doc]
  X is InputGrid

type InputGrid2* = generic X
  ## [doc]
  X is InputGrid

type InputGrid3* = generic X
  ## [doc]
  X is InputGrid

type OutputGrid0* = generic X
  ## [doc]
  X is OutputGrid

type OutputGrid1* = generic X
  ## [doc]
  X is OutputGrid

type OutputGrid2* = generic X
  ## [doc]
  X is OutputGrid

type OutputGrid3* = generic X
  ## [doc]
  X is OutputGrid

template nDim*(Grid: typedesc[InputGrid|OutputGrid]): int =
  ## [doc]
  Grid.new[].size.len

template nDim*(grid: InputGrid|OutputGrid): int =
  ## [doc]
  grid.size.len

template Indices*(Grid: typedesc[InputGrid|OutputGrid]): typedesc[tuple] =
  ## [doc]
  type(Grid.new[].size)

template Indices*(grid: InputGrid|OutputGrid): typedesc[tuple] =
  ## [doc]
  type(grid.size)

template Element*(Grid: typedesc[InputGrid]): typedesc =
  ## [doc]
  type(Grid.new[].get(Grid.Indices.new[]))

template Element*(grid: InputGrid): typedesc =
  ## [doc]
  type(grid.get(grid.Indices.new[]))

iterator indices*(grid: InputGrid|OutputGrid): auto =
  ## [doc]
  macro buildAction: stmt =
    assert true
    result = newYieldStmt(newNimNode(nnkPar))
    for i in 0 .. <grid.nDim:
      let indexExpr = ident("i" & $i)
      result[0].add(newColonExpr(ident("field" & $i), indexExpr))
    for i in countDown(<grid.nDim, 0):
      let lenExpr = newBracketExpr(
        newDotExpr(ident"grid", ident"size"),
        newLit(i))
      result = newForStmt(
        ident("i" & $i),
        newCall("..", newLit(0), newCall("<", lenExpr)),
        result)
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
  assert grid0.size == grid1.size
  for i in grid0.indices:
    when compiles(system.`==`(grid0.get(i), grid1.get(i))):
      if not (system.`==`(grid0.get(i), grid1.get(i))):
        return false
    else:
      if grid0.get(i) != grid1.get(i):
        return false
  return true

proc `$`*(grid: InputGrid): string =
  ## [doc]
  proc describeGrid(indices: tuple): string =
    when indices.len == grid.nDim:
      result = $(grid.get(indices))
    else:
      const delim = "," & repeatStr(grid.nDim - indices.len - 1, "\n") & " "
      result = "["
      for i in 0 .. <grid.size[indices.len]:
        if i > 0: result &= delim
        result &= describeGrid(indices & (field0: i)).replace("\n", "\n ")
      result &= "]"
  describeGrid(())

#===============================================================================
# Tests

# test "grid.indices":
#   block:
#     var i = 0
#     for e in @@["0", "1", "2"].indices:
#       assert e == (field0: i)
#       i += 1
#     assert i == 3
#   block:
#     var i = 0
#     for e in @@[["0", "1"], ["2", "3"]].indices:
#       assert e == (i div 2, i mod 2)
#       i += 1
#     assert i == 4
#
# test "grid.items":
#   block:
#     var i = 0
#     for e in @@["0", "1", "2"]:
#       assert e == $i
#       i += 1
#     assert i == 3
#   block:
#     var i = 0
#     for e in @@[["0", "1"], ["2", "3"]]:
#       assert e == $i
#       i += 1
#     assert i == 4
#
# test "grid.pairs":
#   block:
#     var i = 0
#     for j, e in @@["0", "1", "2"]:
#       assert j == (field0: i)
#       assert e == $i
#       i += 1
#     assert i == 3
#   block:
#     var i = 0
#     for j, e in @@[["0", "1"], ["2", "3"]]:
#       assert j == (i div 2, i mod 2)
#       assert e == $i
#       i += 1
#     assert i == 4
#
# test "grid0 == grid1":
#   assert(@@[0.0, 1.0, 2.0] == @@[0.0, 1.0, 2.0])
#   assert(@@[0.0, 1.0, 2.0] != @@[0.0, 2.0, 4.0])
#   assert(@@[[0, 1], [2, 3]] == @@[[0, 1], [2, 3]])
#   assert(@@[[0, 1], [2, 3]] != @@[[2, 1], [2, 3]])
#   assert(@@[[["0"]], [["1"]]] == @@[[["0"]], [["1"]]])
#   assert(@@[[["0"]], [["1"]]] != @@[[["0"]], [["0"]]])
#
# test "$grid":
#   assert($newDenseGrid(int) == "0")
#   assert($(@@[0.0, 1.0, 2.0]) == "[0.0, 1.0, 2.0]")
#   assert($(@@[[0], [1], [2]]) == "[[0],\n [1],\n [2]]")
