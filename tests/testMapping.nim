import future
import unittest
import numerics

test "grid.map(op)":
  block:
    let grid = @@[0, 1, 2].map((e: int) => e + 1)
    check grid.size == [3]
    check grid.get([0]) == 1
    check grid.get([1]) == 2
    check grid.get([2]) == 3
  block:
    let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map((e: float) => $e)
    check grid.size == [2, 3]
    check grid.get([0, 0]) == "0.0"
    check grid.get([0, 1]) == "1.0"
    check grid.get([0, 2]) == "2.0"
    check grid.get([1, 0]) == "3.0"
    check grid.get([1, 1]) == "4.0"
    check grid.get([1, 2]) == "5.0"
  block:
    let grid = @@[[["0"]], [["1"]], [["2"]]].map((e: string) => e & "!")
    check grid.size == [3, 1, 1]
    check grid.get([0, 0, 0]) == "0!"
    check grid.get([1, 0, 0]) == "1!"
    check grid.get([2, 0, 0]) == "2!"

test "grid.map(op).view(slices)":
  let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map(`$`)
  let slices = [(1..1).by(1), (0..2).by(2)]
  let gridView = @@[["3.0", "5.0"]]
  check grid.view(slices) == gridView

test "grid.map(op).box(dim)":
  let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map(`$`)
  check grid.box(0) == @@[[["0.0", "1.0", "2.0"], ["3.0", "4.0", "5.0"]]]
  check grid.box(1) == @@[[["0.0", "1.0", "2.0"]], [["3.0", "4.0", "5.0"]]]

test "grid.map(op).unbox(dim)":
  let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map(`$`)
  check grid.unbox(0) == @@["0.0", "1.0", "2.0"]
  check grid.unbox(1) == @@["0.0", "3.0"]
