import unittest
import numerics

test "slice.toStridedSlice":
  let slice = 1..4
  check slice.len == 4
  check slice.size == [4]
  check slice.get([0]) == 1
  check slice.get([1]) == 2
  check slice.get([2]) == 3
  check slice.get([3]) == 4
  check ($slice == "1..4")

test "(first..last).by(stride)":
  let slice = (1..7).by(2)
  check slice.len == 4
  check slice.size == [4]
  check slice.get([0]) == 1
  check slice.get([1]) == 3
  check slice.get([2]) == 5
  check slice.get([3]) == 7
  check ($slice == "(1..7).by(2)")

test "stridedSlice.view(indices)":
  block:
    let slice = (1..7).by(2).view([(1..2).by(1)])
    check slice.len == 2
    check slice.size == [2]
    check slice.get([0]) == 3
    check slice.get([1]) == 5
    check ($slice == "(3..5).by(2)")
  block:
    let slice = (1..7).by(2).view([(0..2).by(2)])
    check slice.len == 2
    check slice.size == [2]
    check slice.get([0]) == 1
    check slice.get([1]) == 5
    check ($slice == "(1..5).by(4)")

test "element in stridedSlice":
  block:
    let slice = (1..7).by(2)
    check 1 in slice
    check 3 in slice
    check 7 in slice
    check 0 notin slice
    check 2 notin slice
    check 9 notin slice
  block:
    let slice = (1.0 .. 7.0).by(2.0)
    check 1.0 in slice
    check 3.0 in slice
    check 7.0 in slice
    check 0.0 notin slice
    check 2.0 notin slice
    check 9.0 notin slice
