import complex
import slices
import numericsInternals

type PointGrid*[Element] = object
  ## [doc]
  element: Element
  typeclassTag_InputGrid*: byte

proc newPointGrid*[E](element: E): PointGrid[E] =
  ## [doc]
  PointGrid[E](element: element)

converter toPointGrid*(e: bool): PointGrid[bool] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: int): PointGrid[int] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: int8): PointGrid[int8] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: int16): PointGrid[int16] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: int32): PointGrid[int32] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: int64): PointGrid[int64] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: uint): PointGrid[uint] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: uint8): PointGrid[uint8] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: uint16): PointGrid[uint16] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: uint32): PointGrid[uint32] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: uint64): PointGrid[uint64] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: float32): PointGrid[float32] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: float64): PointGrid[float64] =
  ## [doc]
  newPointGrid(e)

converter toPointGrid*(e: Complex): PointGrid[Complex] =
  ## [doc]
  newPointGrid(e)

proc size*[E](grid: PointGrid[E]): array[0, int] =
  ## [doc]
  emptyIntArray

proc get*[E](grid: PointGrid[E], indices: array[0, int]): E =
  ## [doc]
  grid.element

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
