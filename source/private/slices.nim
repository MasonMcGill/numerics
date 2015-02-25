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

proc view*[E](slice0: StridedSlice[E], slice1: array[1, StridedSlice[int]]):
              StridedSlice[E] =
  ## [doc]
  result.first = slice0.first + slice1[0].first * slice0.stride
  result.last = slice0.first + slice1[0].last * slice0.stride
  result.stride = slice0.stride * slice1[0].stride

proc `$`*[E](slice: StridedSlice[E]): string =
  ## [doc]
  "(" & $slice.first & ".." & $slice.last & ").by(" & $slice.stride & ")"

proc `$`*[E](slice: Slice[E]): string =
  ## [doc]
  $slice.a & ".." & $slice.b
