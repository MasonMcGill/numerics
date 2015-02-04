#===============================================================================
# Definitions

type StridedSlice*[Element] = object
  ## [doc]
  first*, last*, stride*: Element
  typeClassTag_InputGrid: byte

converter toStridedSlice*[E](slice: Slice[E]): StridedSlice[E] =
  ## [doc]
  result.first = slice.a
  result.last = slice.b
  result.stride = E(1)

proc by*[E](slice: StridedSlice[E], stride: E): StridedSlice[E] =
  ## [doc]
  result.first = slice.first
  result.last = slice.last
  result.stride = stride * slice.stride

proc len*[E](slice: StridedSlice[E]): int =
  ## [doc]
  (slice.last - slice.first) div slice.stride + 1

proc contains*[E](slice: StridedSlice[E], element: E): bool =
  (element >= slice.first and element <= slice.last and
   (element - slice.first) mod slice.stride == 0)

proc size*[E](slice: StridedSlice[E]): array[1, int] =
  ## [doc]
  [slice.len]

proc get*[E](slice: StridedSlice[E], indices: array[1, int]): E =
  ## [doc]
  slice.first + slice.stride * indices[0]

proc view*[E](slice: StridedSlice[E], indices: array[1, StridedSlice[int]]):
              StridedSlice[E] =
  ## [doc]
  result.first = slice.first + indices[0].first * slice.stride
  result.last = slice.first + indices[0].last * slice.stride
  result.stride = slice.stride * indices[0].stride

proc `$`*[E](slice: StridedSlice[E]): string =
  ## [doc]
  "(" & $slice.first & ".." & $slice.last & ").by(" & $slice.stride & ")"

proc `$`*[E](slice: Slice[E]): string =
  ## [doc]
  $slice.a & ".." & $slice.b

const emptyIntArray = (block: (var x: array[0, int]; x))
const emptySliceArray = (block: (var x: array[0, StridedSlice[int]]; x))

#===============================================================================
# Tests

# test "slice.toStridedSlice":
#   let slice = 1..4
#   assert slice.len == 4
#   assert slice.size == [4]
#   assert slice.get([0]) == 1
#   assert slice.get([1]) == 2
#   assert slice.get([2]) == 3
#   assert slice.get([3]) == 4
#   assert ($slice == "1..4")
#
# test "(first..last).by(stride)":
#   let slice = (1..7).by(2)
#   assert slice.len == 4
#   assert slice.size == [4]
#   assert slice.get([0]) == 1
#   assert slice.get([1]) == 3
#   assert slice.get([2]) == 5
#   assert slice.get([3]) == 7
#   assert ($slice == "(1..7).by(2)")
#
# test "stridedSlice.view(indices)":
#   block:
#     let slice = (1..7).by(2).view([(1..2).by(1)])
#     assert slice.len == 2
#     assert slice.size == [2]
#     assert slice.get([0]) == 3
#     assert slice.get([1]) == 5
#     assert ($slice == "(3..5).by(2)")
#   block:
#     let slice = (1..7).by(2).view([(0..2).by(2)])
#     assert slice.len == 2
#     assert slice.size == [2]
#     assert slice.get([0]) == 1
#     assert slice.get([1]) == 5
#     assert ($slice == "(1..5).by(4)")
#
# test "element in stridedSlice":
#   block:
#     let slice = (1..7).by(2)
#     assert 1 in slice
#     assert 3 in slice
#     assert 7 in slice
#     assert 0 notin slice
#     assert 2 notin slice
#     assert 9 notin slice
#   block:
#     let slice = (1.0 .. 7.0).by(2.0)
#     assert 1.0 in slice
#     assert 3.0 in slice
#     assert 7.0 in slice
#     assert 0.0 notin slice
#     assert 2.0 notin slice
#     assert 9.0 notin slice
