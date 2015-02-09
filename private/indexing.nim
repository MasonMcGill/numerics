#===============================================================================
# Definitions

template areAllInts(indices: tuple, dim: 0): bool =
  when compiles(indices[dim]):
    indices[dim] is int and indices.areAllInts(dim + 1)
  else:
    true

template areAllInts(indices: tuple): bool =
  indices.areAllInts(0)

proc `[]`*(grid: InputGrid, indices: tuple): auto =
  ## [doc]
  when indices.areAllInts == indices.len:
    grid.get(indices)
  else:
    var slices {.noInit.}: array[grid.nDim, StridedSlice[int]]
    forStatic dim, 0 .. <indices.len:
      slices[dim] = indices[dim]
    forStatic dim, indices.len .. <grid.nDim:
      slices[dim] = (0 .. grid.size[dim]).by(1)
    grid.view(slices)

macro `[]`*(grid: InputGrid, indices: varargs[expr]): expr =
  ## [doc]
  newCall(bindSym"[]", grid, pack(indices))

proc `[]=`*(grid: OutputGrid, indices: tuple, value: any) =
  ## [doc]
  when indices.areAllInts == indices.len:
    grid.put(indices, value)
  else:
    var slices {.noInit.}: array[grid.nDim, StridedSlice[int]]
    forStatic dim, 0 .. <indices.len:
      slices[dim] = indices[dim]
    forStatic dim, indices.len .. <grid.nDim:
      slices[dim] = (0 .. grid.size[dim]).by(1)
    let gridView = grid.view(slices)
    for i in gridView.indices:
      when value is InputGrid:
        gridView.put(i, value.get(i[0 .. <value.nDim]))
      else:
        gridView.put(i, value)

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
