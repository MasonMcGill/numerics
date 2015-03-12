import complex
import slices
import numericsInternals

type PointGrid*[Element] = object
  ## [doc]
  element: Element
  typeclassTag_InputGrid*: byte
  typeclassTag_OutputGrid*: byte

proc `@@`*[E](element: E): PointGrid[E] =
  ## [doc]
  PointGrid[E](element: element)

converter toPointGrid*(e: bool): PointGrid[bool] = @@e
converter toPointGrid*(e: int): PointGrid[int] = @@e
converter toPointGrid*(e: int8): PointGrid[int8] = @@e
converter toPointGrid*(e: int16): PointGrid[int16] = @@e
converter toPointGrid*(e: int32): PointGrid[int32] = @@e
converter toPointGrid*(e: int64): PointGrid[int64] = @@e
converter toPointGrid*(e: uint): PointGrid[uint] = @@e
converter toPointGrid*(e: uint8): PointGrid[uint8] = @@e
converter toPointGrid*(e: uint16): PointGrid[uint16] = @@e
converter toPointGrid*(e: uint32): PointGrid[uint32] = @@e
converter toPointGrid*(e: uint64): PointGrid[uint64] = @@e
converter toPointGrid*(e: float32): PointGrid[float32] = @@e
converter toPointGrid*(e: float64): PointGrid[float64] = @@e
converter toPointGrid*(e: Complex): PointGrid[Complex] = @@e

proc size*[E](grid: PointGrid[E]): array[0, int] =
  ## [doc]
  emptyIntArray

proc get*[E](grid: PointGrid[E], indices: array[0, int]): E =
  ## [doc]
  grid.element

proc put*[E](grid: PointGrid[E], indices: array[0, int], value: E) =
  ## [doc]
  grid.element = value

proc view*[E](grid: PointGrid[E], slices: array[0, StridedSlice[int]]):
              PointGrid[E] =
  ## [doc]
  grid

proc `$`*[E](grid: PointGrid[E]): string =
  ## [doc]
  $grid.element

proc `==`*[E](grid0, grid1: PointGrid[E]): bool =
  ## [doc]
  grid0.element == grid1.element
