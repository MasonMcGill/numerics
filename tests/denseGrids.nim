import numerics
import testing

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
