import numerics
import testing

test "slice.toStridedSlice":
  let slice = 1..4
  assert slice.len == 4
  assert slice.size == [4]
  assert slice.get([0]) == 1
  assert slice.get([1]) == 2
  assert slice.get([2]) == 3
  assert slice.get([3]) == 4
  assert ($slice == "1..4")

test "(first..last).by(stride)":
  let slice = (1..7).by(2)
  assert slice.len == 4
  assert slice.size == [4]
  assert slice.get([0]) == 1
  assert slice.get([1]) == 3
  assert slice.get([2]) == 5
  assert slice.get([3]) == 7
  assert ($slice == "(1..7).by(2)")

test "stridedSlice.view(indices)":
  block:
    let slice = (1..7).by(2).view([(1..2).by(1)])
    assert slice.len == 2
    assert slice.size == [2]
    assert slice.get([0]) == 3
    assert slice.get([1]) == 5
    assert ($slice == "(3..5).by(2)")
  block:
    let slice = (1..7).by(2).view([(0..2).by(2)])
    assert slice.len == 2
    assert slice.size == [2]
    assert slice.get([0]) == 1
    assert slice.get([1]) == 5
    assert ($slice == "(1..5).by(4)")

test "element in stridedSlice":
  block:
    let slice = (1..7).by(2)
    assert 1 in slice
    assert 3 in slice
    assert 7 in slice
    assert 0 notin slice
    assert 2 notin slice
    assert 9 notin slice
  block:
    let slice = (1.0 .. 7.0).by(2.0)
    assert 1.0 in slice
    assert 3.0 in slice
    assert 7.0 in slice
    assert 0.0 notin slice
    assert 2.0 notin slice
    assert 9.0 notin slice
