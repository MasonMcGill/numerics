import unittest
import numerics

test "repeat(element, size)":
  let grid = repeat(7, [2, 1])
  assert grid.Element is int
  assert grid == @@[[7], [7]]

test "zeros(size)":
  let grid = zeros([3])
  assert grid.Element is float
  assert grid == @@[0.0, 0.0, 0.0]

test "zeros(Element, size)":
  let grid = zeros(int, [3])
  assert grid.Element is int
  assert grid == @@[0, 0, 0]

test "ones(size)":
  let grid = ones([3])
  assert grid.Element is float
  assert grid == @@[1.0, 1.0, 1.0]

test "ones(Element, size)":
  let grid = ones(int, [3])
  assert grid.Element is int
  assert grid == @@[1, 1, 1]

test "falses(size)":
  let grid = falses ([3])
  assert grid.Element is bool
  assert grid == @@[false, false, false]

test "trues(size)":
  let grid = trues([3])
  assert grid.Element is bool
  assert grid == @@[true, true, true]

test "rand(size)":
  let grid = rand([2, 1, 3])
  assert grid.Element is float
  assert grid.size == [2, 1, 3]

test "linSpace(first, last, nSamples)":
  let grid = linSpace(2.0, 3.5, 4)
  assert grid.Element is float
  assert grid == @@[2.0, 2.5, 3.0, 3.5]

test "logSpace(first, last, nSamples)":
  let grid = logSpace(2.0, 4.0, 3)
  assert grid.Element is float
  assert grid == @@[100.0, 1000.0, 10000.0]

test "reshape(grid, size)":
  let grid0 = @@[['0', '1', '2'], ['3', '4', '5']]
  let grid1 = grid0.reshape([6])
  assert grid1.Element is char
  assert grid1 == @@['0', '1', '2', '3', '4', '5']
