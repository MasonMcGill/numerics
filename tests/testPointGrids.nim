import unittest
import numerics

const emptyIntArray = (block: (var x: array[0, int]; x))
const emptySliceArray = (block: (var x: array[0, StridedSlice[int]]; x))

test "newPointGrid(element)":
  let grid = newPointGrid("5")
  check grid.size == emptyIntArray
  check grid.get(emptyIntArray) == "5"

test "pointGrid.view(slices)":
  let grid = newPointGrid("5").view(emptySliceArray)
  check grid.size == emptyIntArray
  check grid.get(emptyIntArray) == "5"
