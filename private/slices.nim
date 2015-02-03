#===============================================================================
# Definitions

type StridedSlice*[T] = object
  ## [doc]
  first*, last*, stride*: T
  typeClassTag_InputGrid: type(())

converter toStridedSlice*[T](slice: Slice[T]): StridedSlice[T] =
  ## [doc]
  result.first = slice.a
  result.last = slice.b
  result.stride = T(1)

proc by*[T](slice: StridedSlice[T], stride: T): StridedSlice[T] =
  ## [doc]
  result.first = slice.first
  result.last = slice.last
  result.stride = stride * slice.stride

proc len*[T](slice: StridedSlice[T]): int =
  ## [doc]
  (slice.last - slice.first) div slice.stride + 1

proc contains*[T](slice: StridedSlice[T], element: T): bool =
  (element >= slice.first and element <= slice.last and
   (element - slice.first) mod slice.stride == 0)

proc size*[T](slice: StridedSlice[T]): tuple[field0: int] =
  ## [doc]
  (field0: slice.len)

proc get*[T](slice: StridedSlice[T], indices: tuple): T =
  ## [doc]
  slice.first + slice.stride * indices[0]

proc view*[T](slice: StridedSlice[T], indices: tuple): StridedSlice[T] =
  ## [doc]
  result.first = slice.first + indices[0].first * slice.stride
  result.last = slice.first + indices[0].last * slice.stride
  result.stride = slice.stride * indices[0].stride

proc `$`*[T](slice: StridedSlice[T]): string =
  ## [doc]
  "(" & $slice.first & ".." & $slice.last & ").by(" & $slice.stride & ")"

proc `$`*[T](slice: Slice[T]): string =
  ## [doc]
  $slice.a & ".." & $slice.b

#===============================================================================
# Tests

# test "slice.toStridedSlice":
#   let slice = 1..4
#   assert slice.len == 4
#   assert slice.size == (field0: 4)
#   assert slice.get((field0: 0)) == 1
#   assert slice.get((field0: 1)) == 2
#   assert slice.get((field0: 2)) == 3
#   assert slice.get((field0: 3)) == 4
#   assert ($slice == "1..4")
#
# test "(first..last).by(stride)":
#   let slice = (1..7).by(2)
#   assert slice.len == 4
#   assert slice.size == (field0: 4)
#   assert slice.get((field0: 0)) == 1
#   assert slice.get((field0: 1)) == 3
#   assert slice.get((field0: 2)) == 5
#   assert slice.get((field0: 3)) == 7
#   assert ($slice == "(1..7).by(2)")
#
# test "stridedSlice.view(indices)":
#   block:
#     let slice = (1..7).by(2).view((field0: (1..2).by(1)))
#     assert slice.len == 2
#     assert slice.size == (field0: 2)
#     assert slice.get((field0: 0)) == 3
#     assert slice.get((field0: 1)) == 5
#     assert ($slice == "(3..5).by(2)")
#   block:
#     let slice = (1..7).by(2).view((field0: (0..2).by(2)))
#     assert slice.len == 2
#     assert slice.size == (field0: 2)
#     assert slice.get((field0: 0)) == 1
#     assert slice.get((field0: 1)) == 5
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
