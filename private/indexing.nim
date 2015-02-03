#===============================================================================
# Definitions

type View*[Grid: InputGrid|OutputGrid, Lens] = object
  ## [doc]
  grid: Grid
  lens: Lens
  when Grid is InputGrid:
    typeClassTag_InputGrid: type(())
  when Grid is OutputGrid:
    typeClassTag_OutputGrid: type(())

proc view*(grid: InputGrid|OutputGrid, indices: tuple): auto =
  ## [doc]
  let upgradedIndices = indices.map(upgradeSlice)
  View[type(grid), type(upgradedIndices)](grid: grid, lens: upgradedIndices)

proc size*[Grid, Lens](grid: View[Grid, Lens]): auto =
  ## [doc]
  macro buildResult: expr =
    result = newNimNode nnkPar
    forStatic i, 0 .. <grid.grid.nDim:
      when grid.lens[i] is StridedSlice[int]:
        result.add(newNimNode(nnkExprColonExpr).add(
          ident("field" & $(grid.lens.get(0 .. <i).nSlices)),
          newCall(
            bindSym"len",
            newNimNode(nnkBracketExpr).add(
              newDotExpr(ident"grid", ident"lens"),
              newLit(i)))))
  buildResult()

proc get*[Grid, Lens](view: View[Grid, Lens], indices: tuple): auto =
  ## [doc]
  static: assert view is InputGrid
  var adjustedIndices {.noinit.}: view.grid.Indices
  forStatic dim, 0 .. <view.grid.nDim:
    adjustedIndices[dim] =
      when view.lens[dim] is int:
        view.lens[dim]
      else:
        (let index = indices[view.lens.get(0 .. <dim).nSlices];
         view.lens[dim].first + view.lens[dim].stride * index)
  view.grid.get(adjustedIndices)

proc put*[Grid, Lens](view: View[Grid, Lens], indices: tuple, value: any) =
  ## [doc]
  static: assert view is OutputGrid
  var adjustedIndices {.noinit.}: view.grid.Indices
  forStatic dim, 0 .. <view.grid.nDim:
    adjustedIndices[dim] =
      when view.lens[dim] is int:
        view.lens[dim]
      else:
        (let index = indices[view.lens.get(0 .. <dim).nSlices];
         view.lens[dim].first + view.lens[dim].stride * index)
  view.grid.put(adjustedIndices, value)

proc view*[Grid, Lens](grid: View[Grid, Lens], indices: tuple): auto =
  ## [doc]
  template adjustedLens(dim: int): expr =
    when grid.lens[dim] is int: grid.lens[dim]
    else: grid.lens[dim][indices[grid.lens.get(0 .. <dim).nSlices]]
  macro buildAdjustedLens: expr =
    result = newNimNode nnkPar
    for dim in 0 .. <grid.grid.nDim:
      result.add(newColonExpr(
        ident("field" & $dim), newCall("adjustedLens", newLit(dim))))
  grid.grid.view(buildAdjustedLens())

proc `[]`*(grid: InputGrid, indices: tuple): auto =
  ## [doc]
  when indices.len < grid.nDim:
    template getSlice(dim: int): expr = 0 .. <grid.size[dim]
    let slices = (indices.len .. <grid.nDim).staticMap(getSlice)
    grid[indices & slices]
  elif indices.nSlices == 0:
    grid.get(indices)
  else:
    grid.view(indices.map(upgradeSlice))

macro `[]`*(grid: InputGrid, indices: varargs[expr]): expr =
  ## [doc]
  newCall(bindSym"[]", grid, pack(indices))

proc `[]=`*(grid: OutputGrid, indices: tuple, value: any) =
  ## [doc]
  when indices.len < grid.nDim:
    template getSlice(dim: int): expr = 0 .. <grid.size[dim]
    let slices = (indices.len .. <grid.nDim).staticMap(getSlice)
    grid[indices & slices] = value
  elif indices.nSlices == 0:
    grid.put(indices, value)
  else:
    let gridView = grid.view(indices.map(upgradeSlice))
    for i in gridView.indices:
      when value is InputGrid:
        gridView[i] = value[i.get(0 .. <value.nDim)]
      else:
        gridView[i] = value

macro `[]=`*(grid: OutputGrid, indicesAndValue: varargs[expr]): stmt =
  ## [doc]
  let value = indicesAndValue[indicesAndValue.len - 1]
  var indices = indicesAndValue
  indices.del(indices.len - 1)
  newCall(bindSym"[]=", grid, pack(indices), value)

#===============================================================================
# Tests

# test "grid[]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1])
#   block:
#     let view = CustomGrid()[]
#     assert view.size == (3, 4)
#     for i in 0 .. <3:
#       for j in 0 .. <4:
#         assert view[i, j] == ($i, $j)
#
# test "grid[index0]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1])
#   block:
#     let view = CustomGrid()[2]
#     assert view.size == (field0: 4)
#     assert view[0] == ("2", "0")
#     assert view[1] == ("2", "1")
#     assert view[2] == ("2", "2")
#     assert view[3] == ("2", "3")
#   block:
#     let view = CustomGrid()[1..0]
#     assert view.size == (0, 4)
#
# test "grid[index0, index1]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1])
#   block:
#     let element = CustomGrid()[2, 0]
#     assert element == ("2", "0")
#   block:
#     let view = CustomGrid()[1..2, 2]
#     assert view.size == (field0: 2)
#     assert view[0] == ("1", "2")
#     assert view[1] == ("2", "2")
#   block:
#     let view = CustomGrid()[0..2, 1..2]
#     assert view.size == (3, 2)
#     assert view[0, 0] == ("0", "1")
#     assert view[0, 1] == ("0", "2")
#     assert view[1, 0] == ("1", "1")
#     assert view[1, 1] == ("1", "2")
#     assert view[2, 0] == ("2", "1")
#     assert view[2, 1] == ("2", "2")
#
# test "grid[index0, index1, index2]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (2, 1, 1)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1], $indices[2])
#   block:
#     let element = CustomGrid()[1, 0, 0]
#     assert element == ("1", "0", "0")
#   block:
#     let view = CustomGrid()[1, 0, 0..0]
#     assert view.size == (field0: 1)
#     assert view[0] == ("1", "0", "0")
#   block:
#     let view = CustomGrid()[0..1, 0, 0]
#     assert view.size == (field0: 2)
#     assert view[0] == ("0", "0", "0")
#     assert view[1] == ("1", "0", "0")
#   block:
#     let view = CustomGrid()[1..1, 0..(-1), 0]
#     assert view.size == (1, 0)
#   block:
#     let view = CustomGrid()[0..1, 0..0, 0..0]
#     assert view.size == (2, 1, 1)
#     assert view[0, 0, 0] == ("0", "0", "0")
#     assert view[1, 0, 0] == ("1", "0", "0")
#
# test "grid[index0][index1, index2]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (2, 1, 1)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1], $indices[2])
#   block:
#     let element = CustomGrid()[1][0, 0]
#     assert element == ("1", "0", "0")
#   block:
#     let view = CustomGrid()[1][0, 0..0]
#     assert view.size == (field0: 1)
#     assert view[0] == ("1", "0", "0")
#
# test "grid[index0][index1, index2, index3]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (2, 1, 1)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1], $indices[2])
#   block:
#     let view = CustomGrid()[0..1][0..1, 0, 0]
#     assert view.size == (field0: 2)
#     assert view[0] == ("0", "0", "0")
#     assert view[1] == ("1", "0", "0")
#   block:
#     let view = CustomGrid()[1..1][0..0, 0..(-1), 0]
#     assert view.size == (1, 0)
#   block:
#     let view = CustomGrid()[0..1][0..1, 0..0, 0..0]
#     assert view.size == (2, 1, 1)
#     assert view[0, 0, 0] == ("0", "0", "0")
#     assert view[1, 0, 0] == ("1", "0", "0")
#
# test "grid[indices]":
#   type CustomGrid = object
#     typeClassTag_InputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc get(grid: CustomGrid, indices: tuple): auto =
#     ($indices[0], $indices[1])
#   block:
#     let element = CustomGrid()[(2, 0)]
#     assert element == ("2", "0")
#   block:
#     let view = CustomGrid()[(1..2, 2)]
#     assert view.size == (field0: 2)
#     assert view[(field0: 0)] == ("1", "2")
#     assert view[(field0: 1)] == ("2", "2")
#   block:
#     let view = CustomGrid()[0..2, 1..2]
#     assert view.size == (3, 2)
#     assert view[(0, 0)] == ("0", "1")
#     assert view[(0, 1)] == ("0", "2")
#     assert view[(1, 0)] == ("1", "1")
#     assert view[(1, 1)] == ("1", "2")
#     assert view[(2, 0)] == ("2", "1")
#     assert view[(2, 1)] == ("2", "2")
#
# test "grid[] = value":
#   type CustomGrid = object
#     record: ref seq[string]
#     typeClassTag_OutputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc put(grid: CustomGrid, indices: tuple, value: int) =
#     grid.record[].add("(" & $indices[0] & ", " & $indices[1] & "): " & $value)
#   block:
#     let grid = CustomGrid(record: new(seq[string]))
#     grid.record[] = newSeq[string]()
#     grid[] = 5
#     assert "(0, 0): 5" in grid.record[]
#     assert "(1, 1): 5" in grid.record[]
#     assert "(2, 3): 5" in grid.record[]
#
# test "grid[index0] = value":
#   type CustomGrid = object
#     record: ref seq[string]
#     typeClassTag_OutputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc put(grid: CustomGrid, indices: tuple, value: int) =
#     grid.record[].add("(" & $indices[0] & ", " & $indices[1] & "): " & $value)
#   block:
#     let grid = CustomGrid(record: new(seq[string]))
#     grid.record[] = newSeq[string]()
#     grid[2] = 5
#     assert "(2, 0): 5" in grid.record[]
#     assert "(2, 1): 5" in grid.record[]
#     assert "(2, 3): 5" in grid.record[]
#     assert "(0, 2): 0" notin grid.record[]
#     assert "(1, 1): 0" notin grid.record[]
#
# test "grid[index0, index1] = value":
#   type CustomGrid = object
#     record: ref seq[string]
#     typeClassTag_OutputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc put(grid: CustomGrid, indices: tuple, value: int) =
#     grid.record[].add("(" & $indices[0] & ", " & $indices[1] & "): " & $value)
#   block:
#     let grid = CustomGrid(record: new(seq[string]))
#     grid.record[] = newSeq[string]()
#     grid[1..2, 0] = @@[5, 6]
#     assert "(1, 0): 5" in grid.record[]
#     assert "(2, 0): 6" in grid.record[]
#     assert "(3, 0): 5" notin grid.record[]
#     assert "(2, 1): 6" notin grid.record[]
#
# test "grid[index0, index1, index2] = value":
#   type CustomGrid = object
#     record: ref seq[string]
#     typeClassTag_OutputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (2, 1, 1)
#   proc put(grid: CustomGrid, indices: tuple, value: string) =
#     grid.record[].add("" & $indices[0] & ": " & value)
#   block:
#     let grid = CustomGrid(record: new(seq[string]))
#     grid.record[] = newSeq[string]()
#     grid[0..0, 0, 0] = "entry"
#     assert "0: entry" in grid.record[]
#     assert "1: entry" notin grid.record[]
#
# test "grid[indices] = value":
#   type CustomGrid = object
#     record: ref seq[string]
#     typeClassTag_OutputGrid: type(())
#   proc size(grid: CustomGrid): auto =
#     (3, 4)
#   proc put(grid: CustomGrid, indices: tuple, value: int) =
#     grid.record[].add("(" & $indices[0] & ", " & $indices[1] & "): " & $value)
#   block:
#     let grid = CustomGrid(record: new(seq[string]))
#     grid.record[] = newSeq[string]()
#     grid[(1..2, 0..2)] = @@[5, 6]
#     assert "(1, 0): 5" in grid.record[]
#     assert "(2, 0): 6" in grid.record[]
#     assert "(1, 2): 5" in grid.record[]
#     assert "(2, 2): 6" in grid.record[]
#     assert "(3, 0): 5" notin grid.record[]
#     assert "(0, 1): 6" notin grid.record[]
#     assert "(1, 3): 5" notin grid.record[]
#     assert "(2, 3): 6" notin grid.record[]
