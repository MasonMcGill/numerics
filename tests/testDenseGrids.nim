import unittest
import numerics

const emptyIntArray = (block: (var x: array[0, int]; x))
const emptySliceArray = (block: (var x: array[0, StridedSlice[int]]; x))

test "newDenseGrid(Element)":
  let grid = newDenseGrid(int)
  check grid.size == emptyIntArray
  check grid.strides == emptyIntArray
  check grid.data != nil
  check grid.get(emptyIntArray) == 0

test "newDenseGrid(Element, size0)":
  let grid = newDenseGrid(int, 5)
  check grid.size == [5]
  check grid.strides == [1]
  check grid.data != nil
  for i in 0 .. <5:
    check grid.get([i]) == 0

test "newDenseGrid(Element, size0, size1)":
  let grid = newDenseGrid(float, 2, 3)
  check grid.size == [2, 3]
  check grid.strides == [3, 1]
  check grid.data != nil
  for i in 0 .. <2:
    for j in 0 .. <3:
      check grid.get([i, j]) == 0.0

test "newDenseGrid(Element, size0, size1, size2)":
  let grid = newDenseGrid(string, 3, 0, 1)
  check grid.size == [3, 0, 1]
  check grid.strides == [0, 1, 1]

test "newDenseGrid(Element, size)":
  let grid = newDenseGrid(float, [2, 3])
  check grid.size == [2, 3]
  check grid.strides == [3, 1]
  check grid.data != nil
  for i in 0 .. <2:
    for j in 0 .. <3:
      check grid.get([i, j]) == 0.0

test "@@element":
  block:
    let grid = @@0
    check grid.size == emptyIntArray
    check grid.get(emptyIntArray) == 0
  block:
    let grid = @@"0"
    check grid.size == emptyIntArray
    check grid.get(emptyIntArray) == "0"

test "@@nestedArrays":
  block:
    let grid = @@[0, 1, 2]
    check grid.size == [3]
    check grid.strides == [1]
    check grid.data != nil
    check grid.get([0]) == 0
    check grid.get([1]) == 1
    check grid.get([2]) == 2
  block:
    let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]
    check grid.size == [2, 3]
    check grid.strides == [3, 1]
    check grid.data != nil
    check grid.get([0, 0]) == 0.0
    check grid.get([0, 1]) == 1.0
    check grid.get([0, 2]) == 2.0
    check grid.get([1, 0]) == 3.0
    check grid.get([1, 1]) == 4.0
    check grid.get([1, 2]) == 5.0
  block:
    let grid = @@[[["0"]], [["1"]], [["2"]]]
    check grid.size == [3, 1, 1]
    check grid.strides == [1, 1, 1]
    check grid.data != nil
    check grid.get([0, 0, 0]) == "0"
    check grid.get([1, 0, 0]) == "1"
    check grid.get([2, 0, 0]) == "2"

test "denseGrid.put(indices, value)":
  block:
    let grid = newDenseGrid(int)
    grid.put(emptyIntArray, 1)
    check grid.size == emptyIntArray
    check grid.strides == emptyIntArray
    check grid.data != nil
    check grid.get(emptyIntArray) == 1
  block:
    let grid = newDenseGrid(float, 2)
    grid.put([0], 0.0)
    grid.put([1], 1.0)
    check grid.size == [2]
    check grid.strides == [1]
    check grid.data != nil
    check grid.get([0]) == 0.0
    check grid.get([1]) == 1.0
  block:
    let grid = newDenseGrid(string, 3, 2)
    grid.put([0, 0], "0")
    grid.put([0, 1], "1")
    grid.put([1, 0], "2")
    grid.put([1, 1], "3")
    grid.put([2, 0], "4")
    grid.put([2, 1], "5")
    check grid.size == [3, 2]
    check grid.strides == [2, 1]
    check grid.data != nil
    check grid.get([0, 0]) == "0"
    check grid.get([0, 1]) == "1"
    check grid.get([1, 0]) == "2"
    check grid.get([1, 1]) == "3"
    check grid.get([2, 0]) == "4"
    check grid.get([2, 1]) == "5"

test "denseGrid.view(indices)":
  block:
    let grid0 = newDenseGrid(int)
    let grid1 = grid0.view(emptySliceArray)
    grid0.put(emptyIntArray, 1)
    check grid1.size == emptyIntArray
    check grid1.strides == emptyIntArray
    check grid1.data != nil
    check grid1.get(emptyIntArray) == 1
  block:
    let grid0 = newDenseGrid(float, 2)
    let grid1 = grid0.view([(1..1).by(1)])
    grid0.put([1], 1.0)
    check grid1.size == [1]
    check grid1.strides == [1]
    check grid1.data != nil
    check grid1.get([0]) == 1.0
  block:
    let grid0 = newDenseGrid(string, 3, 2)
    let grid1 = grid0.view([(0..2).by(2), (1..1).by(1)])
    grid0.put([0, 1], "3")
    grid0.put([2, 1], "5")
    check grid1.size == [2, 1]
    check grid1.strides == [4, 1]
    check grid1.data != nil
    check grid1.get([0, 0]) == "3"
    check grid1.get([1, 0]) == "5"

test "denseGrid.box(dim)":
  block:
    let grid0 = newDenseGrid(int)
    let grid1 = grid0.box(0)
    check grid1.size == [1]
    check grid1.strides == [0]
    check grid1.data == grid0.data
  block:
    let grid0 = newDenseGrid(int, 3, 2)
    let grid1 = grid0.box(1)
    check grid1.size == [3, 1, 2]
    check grid1.strides == [2, 0, 1]
    check grid1.data == grid0.data

test "denseGrid.unbox(dim)":
  block:
    let grid0 = newDenseGrid(int, 3)
    let grid1 = grid0.unbox(0)
    check grid1.size == emptyIntArray
    check grid1.strides == emptyIntArray
    check grid1.data == grid0.data
  block:
    let grid0 = newDenseGrid(int, 3, 2)
    let grid1 = grid0.unbox(1)
    check grid1.size == [3]
    check grid1.strides == [2]
    check grid1.data == grid0.data
